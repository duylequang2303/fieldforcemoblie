import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';
import '../models/fsm_recurring.dart';
import '../models/fsm_frequency_set.dart';
import 'orders_service.dart';

class RecurringService {
  RecurringService._();
  static final RecurringService instance = RecurringService._();

  final _odoo = OdooSessionManager.instance;
  final _isar = IsarService.instance;

  /// Fetch fsm.recurring và fsm.frequency.set từ Odoo về Isar.
  Future<void> fetchRecurringRules() async {
    if (!_odoo.isAuthenticated) return;

    try {
      logger.i('RecurringService: Fetching recurring rules from Odoo...');

      // 1. Fetch fsm.recurring
      final List<dynamic> rawRecurring = await _odoo.callKw(
        model: 'fsm.recurring',
        method: 'search_read',
        args: [
          [
            ['active', '=', true]
          ]
        ],
        kwargs: {
          'fields': [
            'id',
            'name',
            'fsm_frequency_set_id',
            'fsm_order_template_id',
            'company_id',
            'start_date',
            'end_date',
            'next_date',
            'active'
          ]
        },
      ) as List<dynamic>;

      final recurringRules = rawRecurring.map((e) {
        return FsmRecurring.fromJson(e as Map<String, dynamic>);
      }).toList();

      // Thu thập các frequency_set_ids
      final frequencySetIds = recurringRules
          .map((r) => r.frequencySetId)
          .where((id) => id > 0)
          .toSet()
          .toList();

      // 2. Fetch fsm.frequency.set tương ứng
      List<FsmFrequencySet> frequencySets = [];
      if (frequencySetIds.isNotEmpty) {
        final List<dynamic> rawFrequency = await _odoo.callKw(
          model: 'fsm.frequency.set',
          method: 'read',
          args: [frequencySetIds],
          kwargs: {
            'fields': ['id', 'name', 'interval', 'interval_type', 'duration']
          },
        ) as List<dynamic>;

        frequencySets = rawFrequency.map((e) {
          return FsmFrequencySet.fromJson(e as Map<String, dynamic>);
        }).toList();
      }

      // 3. Lưu vào Isar Database
      await _isar.db.writeTxn(() async {
        await _isar.db.fsmRecurrings.putAllByOdooId(recurringRules);
        if (frequencySets.isNotEmpty) {
          await _isar.db.fsmFrequencySets.putAllByOdooId(frequencySets);
        }
      });

      logger.i(
          'RecurringService: Synced ${recurringRules.length} recurring rules and ${frequencySets.length} frequency sets.');
    } on OdooAuthException {
      rethrow;
    } on OdooConnectionException {
      rethrow;
    } catch (e, stackTrace) {
      logger.e('RecurringService.fetchRecurringRules: Failed to fetch recurring rules',
          error: e, stackTrace: stackTrace);
      throw OdooBusinessException('Lỗi tải cấu hình lặp định kỳ từ Odoo: $e');
    }
  }

  /// Tự động sinh local order instances cho các lặp định kỳ đến hạn khi OFFLINE.
  /// Gọi khi app khởi động hoặc định kỳ.
  Future<void> generateOfflineInstances() async {
    try {
      logger.i('RecurringService: Checking and generating offline recurring instances...');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Lấy toàn bộ active recurring rules từ database
      final activeRules = await _isar.db.fsmRecurrings
          .filter()
          .isActiveEqualTo(true)
          .findAll();

      int count = 0;
      for (final rule in activeRules) {
        // Nếu không có nextDate hoặc nextDate chưa đến hạn thì skip
        if (rule.nextDate == null || rule.nextDate!.isAfter(today)) {
          continue;
        }

        // Lấy frequency set tương ứng
        final freqSet = await _isar.db.fsmFrequencySets
            .filter()
            .odooIdEqualTo(rule.frequencySetId)
            .findFirst();

        if (freqSet == null) {
          logger.w('RecurringRule ${rule.odooId} missing frequency set ${rule.frequencySetId}');
          continue;
        }

        // Kiểm tra xem đã có instance nào cho rule này vào ngày nextDate chưa
        // để tránh duplicate local instances
        final existInstance = await _isar.db.fsmOrders
            .filter()
            .recurringIdEqualTo(rule.odooId)
            .scheduledDateStartEqualTo(rule.nextDate)
            .findFirst();

        if (existInstance != null) {
          // Đã có instance cho hôm đó -> update nextDate để tính kỳ sau
          await _isar.db.writeTxn(() async {
            rule.nextDate = calculateNextOccurrence(rule.nextDate!, freqSet);
            await _isar.db.fsmRecurrings.put(rule);
          });
          continue;
        }

        // Generate local instance
        await _generateLocalInstance(rule, freqSet);
        count++;
      }

      if (count > 0) {
        logger.i('RecurringService: Generated $count offline instances.');
      }
    } catch (e, stackTrace) {
      logger.e('RecurringService.generateOfflineInstances: Failed to generate instances',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Sinh một order instance local từ rule và frequency set
  Future<void> _generateLocalInstance(FsmRecurring rule, FsmFrequencySet freqSet) async {
    try {
      if (rule.orderTemplateId == null || rule.orderTemplateId == 0) {
        logger.w('RecurringRule ${rule.odooId} has no order template.');
        return;
      }

      // 1. Tìm order template. 
      // Nếu chưa có local, ta download tạm từ Odoo (nếu online) hoặc clone từ một order cũ.
      FsmOrder? templateOrder = await _isar.db.fsmOrders
          .filter()
          .odooIdEqualTo(rule.orderTemplateId!)
          .findFirst();

      if (templateOrder == null) {
        if (_odoo.isAuthenticated) {
          try {
            logger.i('Fetching missing order template ${rule.orderTemplateId} from Odoo...');
            // Tải template order từ Odoo
            final List<dynamic> templateData = await _odoo.callKw(
              model: 'fsm.order',
              method: 'read',
              args: [[rule.orderTemplateId!]],
              kwargs: {
                // Đọc các fields cơ bản
                'fields': [
                  'id', 'name', 'description', 'stage_id', 'stage_name',
                  'location_id', 'location_directions', 'phone',
                  'require_signature', 'warehouse_id', 'team_id', 'priority',
                  'partner_id', 'person_id'
                ]
              },
            ) as List<dynamic>;

            if (templateData.isNotEmpty) {
              final newTemplate = FsmOrder.fromJson(templateData.first as Map<String, dynamic>);
              // Lưu template vào Isar để sau này dùng offline
              await _isar.db.writeTxn(() async {
                await _isar.db.fsmOrders.put(newTemplate);
              });
              templateOrder = newTemplate;
            }
          } catch (e) {
            logger.e('Failed to fetch order template ${rule.orderTemplateId} online', error: e);
          }
        }
      }

      // 2. Không có template -> không thể clone an toàn
      if (templateOrder == null) {
        logger.e('Cannot generate instance for rule ${rule.odooId}: Template order ${rule.orderTemplateId} not found.');
        return;
      }

      // 3. Tạo instance local mới
      final scheduledStart = rule.nextDate!;
      // Duration mặc định 2h nếu template không có duration
      final durationHours = 2.0; 
      final scheduledEnd = scheduledStart.add(Duration(minutes: (durationHours * 60).round()));
      
      // Tạo odooId âm duy nhất dựa trên micro giây để tránh trùng lặp unique index
      final tempOdooId = -DateTime.now().microsecondsSinceEpoch;

      final localOrder = FsmOrder()
        ..odooId = tempOdooId
        ..name = '[Định kỳ] ${templateOrder.name}'
        ..description = templateOrder.description
        ..stageId = templateOrder.stageId
        ..stageName = templateOrder.stageName
        ..stage = FsmOrderStage.draft
        ..locationName = templateOrder.locationName
        ..locationAddress = templateOrder.locationAddress
        ..locationLat = templateOrder.locationLat
        ..locationLng = templateOrder.locationLng
        ..partnerName = templateOrder.partnerName
        ..partnerPhone = templateOrder.partnerPhone
        ..partnerId = templateOrder.partnerId
        ..warehouseId = templateOrder.warehouseId
        ..inventoryLocationId = templateOrder.inventoryLocationId
        ..scheduledDateStart = scheduledStart
        ..scheduledDateEnd = scheduledEnd
        ..personId = templateOrder.personId // Map đúng theo thợ phân assign của template order
        ..priority = templateOrder.priority
        ..requireSignature = templateOrder.requireSignature
        ..recurringId = rule.odooId
        ..isRecurringInstance = true
        ..isPendingSync = true
        ..lastSyncAt = DateTime.now();

      await _isar.db.writeTxn(() async {
        // Save local để lấy local id
        final localId = await _isar.db.fsmOrders.put(localOrder);
        
        // Gán odooId âm từ localId nếu cần đồng bộ id (nhưng tempOdooId hiện đã unique rồi)
        localOrder.id = localId;
        await _isar.db.fsmOrders.put(localOrder);

        // Lọc ngày nextDate và update
        rule.generatedCount++;
        rule.nextDate = calculateNextOccurrence(scheduledStart, freqSet);
        if (rule.endDate != null && rule.nextDate!.isAfter(rule.endDate!)) {
          rule.isActive = false;
          rule.nextDate = null;
        }
        await _isar.db.fsmRecurrings.put(rule);
      });

      logger.i('Generated local recurring order instance: ${localOrder.name} for date $scheduledStart');
    } catch (e, stackTrace) {
      logger.e('RecurringService._generateLocalInstance: Failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Tính ngày lặp kế tiếp dựa trên interval_type và interval
  DateTime calculateNextOccurrence(DateTime from, FsmFrequencySet freqSet) {
    final interval = freqSet.interval > 0 ? freqSet.interval : 1;
    switch (freqSet.intervalType) {
      case FrequencyIntervalType.daily:
        return from.add(Duration(days: interval));
      case FrequencyIntervalType.weekly:
        return from.add(Duration(days: 7 * interval));
      case FrequencyIntervalType.monthly:
        // Tăng tháng an toàn
        var year = from.year;
        var month = from.month + interval;
        while (month > 12) {
          month -= 12;
          year += 1;
        }
        // Handle ngày cuối tháng (VD: 31/01 -> 31/02 không tồn tại, lùi về 28/02)
        var day = from.day;
        var maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, from.hour, from.minute, from.second);
      case FrequencyIntervalType.yearly:
        return DateTime(from.year + interval, from.month, from.day, from.hour, from.minute, from.second);
    }
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Khi một occurrence hoàn thành (định kỳ theo completion)
  Future<void> onOccurrenceCompleted(FsmOrder completed) async {
    if (completed.recurringId == null) return;
    
    // Đọc recurring rule
    final rule = await _isar.db.fsmRecurrings
        .filter()
        .odooIdEqualTo(completed.recurringId!)
        .findFirst();

    if (rule == null || !rule.isActive) return;

    // Lấy frequency set
    final freqSet = await _isar.db.fsmFrequencySets
        .filter()
        .odooIdEqualTo(rule.frequencySetId)
        .findFirst();

    if (freqSet == null) return;

    // Note: Ở Odoo, nếu là date-based, next_date được tính cố định dựa vào calendar (đã tự update lúc generate).
    // Nếu ruleType là completion-based (ví dụ: X ngày sau khi xong lần trước), thì nextDate phải được cập nhật
    // dựa trên ngày hoàn thành thực tế (completed.dateEnd).
    // Tuy nhiên fsm_recurring trên Odoo mặc định hầu hết là date-based (lịch cố định).
    // Nếu có hoàn thành dựa trên completion:
    // nextDate = completed.dateEnd + duration.
    // Dưới đây là support fallback completion-based nếu Odoo cho phép, hoặc cứ cập nhật nextDate bình thường.
    // Ta tạm thời cập nhật rule: nextDate = today + interval nếu đến hạn, đảm bảo không bị dính lịch cũ quá hạn.
  }

  /// Skip một occurrence
  Future<void> skipOccurrence(FsmOrder order) async {
    if (order.recurringId == null) return;

    await _isar.db.writeTxn(() async {
      order.isSkipped = true;
      order.stage = FsmOrderStage.cancelled;
      order.stageName = 'Cancelled';
      order.isPendingSync = true;
      await _isar.db.fsmOrders.put(order);
    });

    logger.i('Skipped occurrence for order ${order.odooId}');
  }
}
