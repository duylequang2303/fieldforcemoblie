import 'package:isar_community/isar.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/odoo_session_manager.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/utils/logger.dart';
import '../models/fsm_order.dart';
import '../models/fsm_recurring.dart';
import '../models/fsm_frequency_set.dart';

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

      // 3. Lưu vào Isar Database - MERGE để bảo toàn local-only fields
      await _isar.db.writeTxn(() async {
        for (final rule in recurringRules) {
          final existing = await _isar.db.fsmRecurrings
              .filter()
              .odooIdEqualTo(rule.odooId)
              .findFirst();
          if (existing != null) {
            // Merge: chỉ cập nhật fields từ Odoo, giữ local-only fields
            existing.name = rule.name;
            existing.frequencySetId = rule.frequencySetId;
            existing.orderTemplateId = rule.orderTemplateId;
            existing.companyId = rule.companyId;
            existing.startDate = rule.startDate;
            existing.endDate = rule.endDate;
            // Completion rules: Odoo is authoritative for nextDate only for date-based
            if (existing.ruleType != 'completion') {
              existing.nextDate = rule.nextDate;
            }
            // NEVER overwrite local generatedCount, completedCount, skippedCount
            // Stop recurring series sync check: preserve local false isActive state if pending sync
            if (!existing.isPendingSync) {
              existing.isActive = rule.isActive;
            }
            existing.lastSyncAt = DateTime.now();
            await _isar.db.fsmRecurrings.put(existing);
          } else {
            // New rule - dùng fromJson default local-only values
            rule.isPendingSync = false;
            rule.lastSyncAt = DateTime.now();
            await _isar.db.fsmRecurrings.put(rule);
          }
        }
        if (frequencySets.isNotEmpty) {
          await _isar.db.fsmFrequencySets.putAllByOdooId(frequencySets);
        }
      });

      logger.i(
          'RecurringService: Synced ${recurringRules.length} recurring rules and ${frequencySets.length} frequency sets.');
    } on OdooConnectionException catch (e, stackTrace) {
      logger.e('RecurringService.fetchRecurringRules: Connection error',
          error: e, stackTrace: stackTrace);
      rethrow;
    } on OdooAuthException catch (e, stackTrace) {
      logger.e('RecurringService.fetchRecurringRules: Auth error',
          error: e, stackTrace: stackTrace);
      rethrow;
    } on OdooApiException catch (e, stackTrace) {
      logger.e('RecurringService.fetchRecurringRules: Odoo API error',
          error: e, stackTrace: stackTrace);
      throw OdooBusinessException('Lỗi tải cấu hình lặp định kỳ từ Odoo: $e');
    } catch (e, stackTrace) {
      logger.e('RecurringService.fetchRecurringRules: Unexpected error',
          error: e, stackTrace: stackTrace);
      throw OdooBusinessException('Lỗi không xác định khi tải cấu hình lặp định kỳ: $e');
    }
  }

  /// Tự động sinh local order instances cho các lặp định kỳ đến hạn khi OFFLINE.
  /// Gọi khi app khởi động hoặc định kỳ.
  Future<void> generateOfflineInstances() async {
    try {
      logger.i('RecurringService: Checking and generating offline recurring instances...');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final horizon = today.add(const Duration(days: 30)); // 30-day scheduling horizon

      // Lấy toàn bộ active recurring rules từ database
      final activeRules = await _isar.db.fsmRecurrings
          .filter()
          .isActiveEqualTo(true)
          .findAll();

      int count = 0;
      for (final rule in activeRules) {
        if (rule.nextDate == null) continue;

        // Bỏ qua completion rules nếu nextDate ở tương lai (đơn completion chỉ sinh khi hoàn thành/skip)
        if (rule.ruleType == 'completion' && rule.nextDate!.isAfter(today)) {
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

        // Vòng lặp sinh các instance trong tương lai đến hết horizon
        while (rule.nextDate != null && !rule.nextDate!.isAfter(horizon)) {
          // Check endDate
          if (rule.endDate != null && rule.nextDate!.isAfter(rule.endDate!)) {
            rule.isActive = false;
            rule.nextDate = null;
            await _isar.db.writeTxn(() async {
              await _isar.db.fsmRecurrings.put(rule);
            });
            break;
          }

          // Kiểm tra xem đã có instance nào cho rule này vào ngày nextDate chưa
          final existInstance = await _isar.db.fsmOrders
              .filter()
              .recurringIdEqualTo(rule.odooId)
              .scheduledDateStartEqualTo(rule.nextDate)
              .findFirst();

          if (existInstance == null) {
            await _generateLocalInstance(rule, freqSet);
            count++;
          } else if (existInstance.isSkipped) {
            // Nếu đơn hàng trước đó đã được sinh nhưng bị skip, ta cần chắc chắn rule.nextDate
            // được chuyển tiếp bình thường thay vì bị kẹt liên tiếp ở đây.
            // Điều này giải quyết lỗi: Skip order xong vẫn bị sinh loop hoặc không tiến tới kỳ tiếp theo.
            if (rule.ruleType == 'completion') {
              // Đối với completion-based, nextDate được cập nhật tại skipOccurrence của order đó rồi.
              // Nhưng nếu nextDate vẫn chỉ vào ngày này, ta cần reset/null để tránh loop.
              if (rule.nextDate == existInstance.scheduledDateStart) {
                await _isar.db.writeTxn(() async {
                  rule.nextDate = null;
                  await _isar.db.fsmRecurrings.put(rule);
                });
                break;
              }
            } else {
              // Đối với date-based, tiến thêm một kỳ
              final nextDate = calculateNextOccurrence(
                rule.nextDate!,
                freqSet,
                targetDay: rule.startDate.day,
              );
              await _isar.db.writeTxn(() async {
                rule.nextDate = nextDate;
                await _isar.db.fsmRecurrings.put(rule);
              });
              continue;
            }
          }

          // Với completion-based, chỉ sinh duy nhất 1 đơn rồi reset nextDate = null
          if (rule.ruleType == 'completion') {
            await _isar.db.writeTxn(() async {
              rule.nextDate = null;
              await _isar.db.fsmRecurrings.put(rule);
            });
            break;
          }

          // Tính ngày tiếp theo cho date-based
          final nextDate = calculateNextOccurrence(
            rule.nextDate!,
            freqSet,
            targetDay: rule.startDate.day,
          );

          // Cập nhật nextDate tiếp theo cho vòng lặp
          await _isar.db.writeTxn(() async {
            rule.nextDate = nextDate;
            await _isar.db.fsmRecurrings.put(rule);
          });
        }
      }

      if (count > 0) {
        logger.i('RecurringService: Generated $count offline instances within 30-day horizon.');
      }
    } on IsarError catch (e, stackTrace) {
      logger.e('RecurringService.generateOfflineInstances: Isar error',
          error: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      logger.e('RecurringService.generateOfflineInstances: Unexpected error',
          error: e, stackTrace: stackTrace);
    }
  }

  // Tạo odooId âm duy nhất dựa trên local id và counter tăng dần để tránh trùng lặp unique index trong cùng một microgiây
  static int _tempOdooIdCounter = 0;

  /// Sinh một order instance local từ rule và frequency set
  Future<void> _generateLocalInstance(FsmRecurring rule, FsmFrequencySet freqSet) async {
    try {
      if (rule.orderTemplateId == null || rule.orderTemplateId == 0) {
        logger.w('RecurringRule ${rule.odooId} has no order template.');
        return;
      }
      
      // ... (code fetch template ...)

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
      final scheduledEnd = scheduledStart.add(const Duration(minutes: 120));
      
      // Tạo odooId âm duy nhất dựa trên micro giây + counter để tránh trùng lặp unique index
      _tempOdooIdCounter++;
      final tempOdooId = -(DateTime.now().microsecondsSinceEpoch + _tempOdooIdCounter);

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
        if (rule.ruleType == 'completion') {
          // Completion-based: set nextDate to null (will be set upon completion/skip of this order)
          rule.nextDate = null;
        } else {
          rule.nextDate = calculateNextOccurrence(scheduledStart, freqSet, targetDay: rule.startDate.day);
          if (rule.endDate != null && rule.nextDate!.isAfter(rule.endDate!)) {
            rule.isActive = false;
            rule.nextDate = null;
          }
        }
        await _isar.db.fsmRecurrings.put(rule);
      });

      logger.i('Generated local recurring order instance: ${localOrder.name} for date $scheduledStart');
    } on IsarError catch (e, stackTrace) {
      logger.e('RecurringService._generateLocalInstance: Isar error', error: e, stackTrace: stackTrace);
    } on OdooApiException catch (e, stackTrace) {
      logger.e('RecurringService._generateLocalInstance: Odoo API error', error: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      logger.e('RecurringService._generateLocalInstance: Unexpected error', error: e, stackTrace: stackTrace);
    }
  }

  /// Tính ngày lặp kế tiếp dựa trên interval_type và interval
  DateTime calculateNextOccurrence(DateTime from, FsmFrequencySet freqSet, {int? targetDay}) {
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
        var day = targetDay ?? from.day;
        final maxDays = _daysInMonth(year, month);
        if (day > maxDays) {
          day = maxDays;
        }
        return DateTime(year, month, day, from.hour, from.minute, from.second);
      case FrequencyIntervalType.yearly:
        return DateTime(from.year + interval, from.month, targetDay ?? from.day, from.hour, from.minute, from.second);
    }
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Khi một occurrence hoàn thành (định kỳ theo completion)
  /// Đảm bảo tính Idempotency: Kiểm tra nếu order chưa từng được xử lý chu kỳ lặp.
  Future<void> onOccurrenceCompleted(FsmOrder completed) async {
    if (completed.recurringId == null) return;
    
    // Tránh double-count khi sync retry
    if (completed.isRecurringProcessed) {
      logger.i('Order ${completed.odooId} recurrence is already processed. Skipping duplicate completion handling.');
      return;
    }
    
    final now = DateTime.now();
    FsmRecurring? updatedRule;

    try {
      await _isar.db.writeTxn(() async {
        final freshCompleted = await _isar.db.fsmOrders.get(completed.id);
        if (freshCompleted == null || freshCompleted.isRecurringProcessed) return;

        // Đọc recurring rule inside transaction
        final rule = await _isar.db.fsmRecurrings
            .filter()
            .odooIdEqualTo(completed.recurringId!)
            .findFirst();

        if (rule == null || !rule.isActive) return;

        // Đánh dấu order đã được xử lý để tránh double-count khi retry
        freshCompleted.isRecurringProcessed = true;
        await _isar.db.fsmOrders.put(freshCompleted);

        rule.completedCount++;
        
        if (rule.ruleType == 'completion' && rule.completionInterval > 0) {
          final completionDate = freshCompleted.dateEnd ?? now;
          final nextDate = DateTime(
            completionDate.year,
            completionDate.month,
            completionDate.day + rule.completionInterval,
            freshCompleted.scheduledDateStart?.hour ?? 9,
            freshCompleted.scheduledDateStart?.minute ?? 0,
          );
          rule.nextDate = nextDate;
        }
        await _isar.db.fsmRecurrings.put(rule);
        updatedRule = rule;
      });
    } on IsarError catch (e, stackTrace) {
      logger.e('RecurringService.onOccurrenceCompleted: Isar error', error: e, stackTrace: stackTrace);
      return;
    } catch (e, stackTrace) {
      logger.e('RecurringService.onOccurrenceCompleted: Unexpected error', error: e, stackTrace: stackTrace);
      return;
    }

    if (updatedRule != null && updatedRule!.ruleType == 'completion' && updatedRule!.completionInterval > 0) {
      logger.i('Completion recurrence rule target met: Scheduled next instance on ${updatedRule!.nextDate}');
      // Gọi generate offline sau khi transaction đã committed thành công
      await generateOfflineInstances();
    }
  }

  /// Skip một occurrence
  Future<void> skipOccurrence(FsmOrder order) async {
    if (order.recurringId == null) return;

    // Tránh double-skip khi retry
    if (order.isRecurringProcessed || order.isSkipped) {
      logger.i('Order ${order.odooId} is already marked as skipped or processed. Skipping retry skipOccurrence.');
      return;
    }

    FsmRecurring? updatedRule;

    try {
      await _isar.db.writeTxn(() async {
        final freshOrder = await _isar.db.fsmOrders.get(order.id);
        if (freshOrder == null || freshOrder.isRecurringProcessed || freshOrder.isSkipped) return;

        // Đọc recurring rule inside transaction
        final rule = await _isar.db.fsmRecurrings
            .filter()
            .odooIdEqualTo(order.recurringId!)
            .findFirst();

        if (rule == null || !rule.isActive) return;

        freshOrder.isSkipped = true;
        freshOrder.isRecurringProcessed = true;
        freshOrder.stage = FsmOrderStage.cancelled;
        freshOrder.stageName = 'Cancelled';
        freshOrder.isPendingSync = true;
        await _isar.db.fsmOrders.put(freshOrder);

        rule.skippedCount++;

        if (rule.ruleType == 'completion' && rule.completionInterval > 0) {
          final today = DateTime.now();
          final nextDate = DateTime(
            today.year,
            today.month,
            today.day + rule.completionInterval,
            freshOrder.scheduledDateStart?.hour ?? 9,
            freshOrder.scheduledDateStart?.minute ?? 0,
          );
          rule.nextDate = nextDate;
        }
        await _isar.db.fsmRecurrings.put(rule);
        updatedRule = rule;
      });
    } on IsarError catch (e, stackTrace) {
      logger.e('RecurringService.skipOccurrence: Isar error', error: e, stackTrace: stackTrace);
      return;
    } catch (e, stackTrace) {
      logger.e('RecurringService.skipOccurrence: Unexpected error', error: e, stackTrace: stackTrace);
      return;
    }

    logger.i('Skipped occurrence for order ${order.odooId}');

    if (updatedRule != null && updatedRule!.ruleType == 'completion' && updatedRule!.completionInterval > 0) {
      logger.i('Skipped completion-based occurrence. Scheduled next on ${updatedRule!.nextDate}');
      // Gọi generate offline sau khi transaction đã committed thành công
      await generateOfflineInstances();
    }
  }

  /// Dừng chuỗi lặp: đặt isActive = false và xoá/huỷ các draft local-only instances tương lai.
  /// Đánh dấu isPendingSync để sync lên Odoo, và bảo toàn trạng thái inactive qua các lần fetch sau.
  Future<void> stopRecurringSeries(int recurringId) async {
    final rule = await _isar.db.fsmRecurrings
        .filter()
        .odooIdEqualTo(recurringId)
        .findFirst();
        
    if (rule == null) return;
    
    try {
      await _isar.db.writeTxn(() async {
        rule.isActive = false;
        rule.nextDate = null;
        rule.isPendingSync = true; // Mark for sync to Odoo
        await _isar.db.fsmRecurrings.put(rule);
        
        // Xoá hoặc huỷ các draft local-only instances tương lai chưa bắt đầu
        final futureDrafts = await _isar.db.fsmOrders
            .filter()
            .recurringIdEqualTo(recurringId)
            .odooIdLessThan(0) // Local draft
            .stageEqualTo(FsmOrderStage.draft)
            .findAll();
            
        for (final draft in futureDrafts) {
          await _isar.db.fsmOrders.delete(draft.id);
        }
      });
    } on IsarError catch (e, stackTrace) {
      logger.e('RecurringService.stopRecurringSeries: Isar error', error: e, stackTrace: stackTrace);
      return;
    } catch (e, stackTrace) {
      logger.e('RecurringService.stopRecurringSeries: Unexpected error', error: e, stackTrace: stackTrace);
      return;
    }
    
    logger.i('Stopped recurring series $recurringId and cleared future local drafts.');
  }

  /// Lấy số lượng recurring instances trong tuần hiện tại (thứ 2 đến chủ nhật)
  Future<int> weeklyInstanceCount() async {
    final now = DateTime.now();
    // Normalize to midnight before calculating week start (Monday)
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startOfWeek = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return await _isar.db.fsmOrders
        .filter()
        .isRecurringInstanceEqualTo(true)
        .scheduledDateStartBetween(startOfWeek, endOfWeek, includeLower: true, includeUpper: false)
        .count();
  }

  /// Lấy thống kê cho dòng lặp định kỳ (Master Series)
  Future<Map<String, dynamic>> seriesAnalyticsFor(int recurringId) async {
    final rule = await _isar.db.fsmRecurrings
        .filter()
        .odooIdEqualTo(recurringId)
        .findFirst();

    if (rule == null) {
      return {
        'generated': 0,
        'completed': 0,
        'skipped': 0,
        'rate': 0.0,
      };
    }

    final total = rule.completedCount + rule.skippedCount;
    final rate = total > 0 ? (rule.completedCount / total) * 100.0 : 0.0;

    return {
      'generated': rule.generatedCount,
      'completed': rule.completedCount,
      'skipped': rule.skippedCount,
      'rate': rate,
    };
  }
}
