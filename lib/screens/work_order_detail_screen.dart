import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core/api/api_exception.dart';
import '../core/utils/logger.dart';
import '../widgets/in_app_camera_screen.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_header.dart';
import '../widgets/material_entry_form.dart';
import '../features/orders/models/fsm_order.dart';
import '../features/orders/models/fsm_recurring.dart';
import '../features/orders/models/fsm_frequency_set.dart';
import '../features/orders/services/orders_service.dart';
import '../core/database/isar_service.dart';
import 'package:isar_community/isar.dart';
import '../features/orders/services/recurring_service.dart';
import '../features/stock/services/stock_service.dart';
import '../features/stock/models/product.dart';
import '../features/work_order/services/work_order_service.dart';

class _MaterialResult {
  final Product? product;
  final int qty;
  const _MaterialResult(this.product, this.qty);
}

class WorkOrderDetailScreen extends StatefulWidget {
  final FsmOrder order;
  const WorkOrderDetailScreen({super.key, required this.order});

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen>
    with WidgetsBindingObserver {
  late SignatureController _signatureController;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _workDoneController = TextEditingController();
  final List<Map<String, dynamic>> _materialsUsed = [];
  final List<String> _photoPaths = [];
  FsmOrder? _freshOrder;
  bool _isProcessing = false;

  bool get _isClosed {
    final currentOrder = _freshOrder ?? widget.order;
    return currentOrder.stage == FsmOrderStage.done ||
        currentOrder.stage == FsmOrderStage.cancelled ||
        currentOrder.isSkipped ||
        currentOrder.isRecurringProcessed;
  }

  String _repeatText = '(Không lặp)';

  Future<void> _initRepeatText() async {
    if (widget.order.recurringId == null || widget.order.recurringId! <= 0) {
      if (mounted) setState(() => _repeatText = '(Không lặp)');
      return;
    }
    try {
      final isar = IsarService.instance.db;
      final rec = await isar.fsmRecurrings
          .filter()
          .odooIdEqualTo(widget.order.recurringId!)
          .findFirst();
      if (rec == null) {
        if (mounted) setState(() => _repeatText = '(Định kỳ)');
        return;
      }
      final freq = await isar.fsmFrequencySets
          .filter()
          .odooIdEqualTo(rec.frequencySetId)
          .findFirst();
      if (freq == null) {
        if (mounted) setState(() => _repeatText = '(Định kỳ)');
        return;
      }

      final unit = freq.intervalType == FrequencyIntervalType.daily
          ? 'ngày'
          : freq.intervalType == FrequencyIntervalType.weekly
              ? 'tuần'
              : freq.intervalType == FrequencyIntervalType.monthly
                  ? 'tháng'
                  : 'năm';
      final text = freq.interval == 1
          ? '(Lặp mỗi $unit)'
          : '(Lặp mỗi ${freq.interval} $unit)';
      if (mounted) {
        setState(() => _repeatText = text);
      }
    } catch (_) {
      if (mounted) setState(() => _repeatText = '(Định kỳ)');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _signatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _loadReportDraft();
    _initRepeatText();
  }

  Future<void> _loadReportDraft() async {
    try {
      final fresh = await IsarService.instance.db.fsmOrders
          .filter()
          .odooIdEqualTo(widget.order.odooId)
          .findFirst();
      final report = await WorkOrderService.instance
          .getOrCreateReport(widget.order.odooId);
      if (mounted) {
        setState(() {
          _freshOrder = fresh;
          _workDoneController.text = report.workDone;
          _customerNameController.text = report.customerName ?? '';
          _photoPaths.addAll(report.photoPaths);
        });
      }
    } catch (e) {
      logger.w('Failed to load report draft', error: e);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _signatureController.dispose();
    _customerNameController.dispose();
    _workDoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _stripHtml(String? html) {
    if (html == null || html.isEmpty)
      return 'No general instructions provided.';
    var t = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    t = t
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.isEmpty ? 'No general instructions provided.' : t;
  }

  Future<void> _launchUrlRobust(Uri url, String errorMessage) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      _showSnackBar('$errorMessage: $e');
    }
  }

  Future<void> _onCall() async {
    final phone = widget.order.partnerPhone;
    if (phone == null || phone.trim().isEmpty) {
      _showSnackBar('Phone number not available.');
      return;
    }
    await _launchUrlRobust(Uri.parse('tel:$phone'), 'Cannot open Phone app');
  }

  Future<void> _onSms() async {
    final phone = widget.order.partnerPhone;
    if (phone == null || phone.trim().isEmpty) {
      _showSnackBar('Phone number not available.');
      return;
    }
    await _launchUrlRobust(Uri.parse('sms:$phone'), 'Cannot open SMS app');
  }

  void _onEmail() =>
      _showSnackBar('Email not available for this customer yet.');

  Future<void> _onDirections() async {
    final lat = widget.order.locationLat;
    final lng = widget.order.locationLng;
    if (lat == null || lng == null) {
      _showSnackBar('Location coordinates not available in Odoo.');
      return;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
              'GPS is off. Enable it so Maps can route you to the customer.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Later')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Open Settings')),
          ],
        ),
      );
      if (open == true) await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permission required for routing.');
    }
    await _launchUrlRobust(
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
      'Cannot open Maps',
    );
  }

  Future<void> _openInAppCamera() async {
    final path = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const InAppCameraScreen()),
    );
    if (path == null) return;
    setState(() => _photoPaths.add(path));
    await _uploadPhoto(path);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined,
                  color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined,
                  color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading:
                  Icon(Icons.camera, color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Camera (in-app)'),
              onTap: () {
                Navigator.pop(ctx);
                _openInAppCamera();
              },
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final List<XFile> picked = <XFile>[];
    if (source == ImageSource.gallery) {
      picked.addAll(
          await picker.pickMultiImage(imageQuality: 70, maxWidth: 1280));
    } else {
      final one = await picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 1280);
      if (one != null) picked.add(one);
    }
    if (picked.isEmpty) return;

    // FIX 3 — Đo kích thước ảnh thật (chẩn đoán Samsung)
    if (kDebugMode) {
      for (final x in picked) {
        try {
          final size = await File(x.path).length();
          debugPrint(
              '📸 PICKED: ${x.path.split('/').last} — ${(size / 1024 / 1024).toStringAsFixed(1)}MB');
        } catch (_) {}
      }
    }

    setState(() {
      for (final x in picked) {
        _photoPaths.add(x.path);
      }
    });
    for (final x in picked) {
      await _uploadPhoto(x.path);
    }
  }

  /// Lưu ảnh vào WorkReport (Isar) + đẩy lên Odoo Chatter.
  /// Online → upload ngay, xóa khỏi pending.
  /// Offline → giữ pending, sẽ upload batch khi submitReport.
  Future<void> _uploadPhoto(String path) async {
    try {
      final report = await WorkOrderService.instance
          .getOrCreateReport(widget.order.odooId);

      // 1. Lưu vào Isar trước (offline safety)
      if (!report.photoPaths.contains(path)) {
        report.photoPaths = [...report.photoPaths, path];
        await WorkOrderService.instance.saveReport(report);
      }

      // 2. Upload real-time lên Odoo Chatter
      await WorkOrderService.instance
          .uploadSinglePhoto(widget.order.odooId, path);
      if (kDebugMode) {
        debugPrint("📤 UPLOAD OK: ${path.split('/').last}");
      }

      // 3. Thành công → xóa khỏi pending (tránh trùng khi submit sau)
      report.photoPaths = [...report.photoPaths]..remove(path);
      await WorkOrderService.instance.saveReport(report);

      if (mounted) _showSnackBar('Photo uploaded.');
    } on OdooApiException {
      if (kDebugMode) {
        debugPrint("📤 UPLOAD OFFLINE: ${path.split('/').last}");
      }
      // Offline — ảnh đã lưu Isar, sẽ upload khi submitReport
      if (mounted) {
        _showSnackBar('Photo saved locally — will upload when online.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("📤 UPLOAD ERROR: ${path.split('/').last} -> $e");
      }
      if (mounted) _showSnackBar('Photo error: $e');
    }
  }

  void _removePhoto(int index) {
    final path = _photoPaths[index];
    setState(() => _photoPaths.removeAt(index));
    // Đồng bộ xóa trong WorkReport (nếu chưa upload lên Odoo)
    WorkOrderService.instance
        .getOrCreateReport(widget.order.odooId)
        .then((report) {
      if (report.photoPaths.contains(path)) {
        report.photoPaths = [...report.photoPaths]..remove(path);
        return WorkOrderService.instance.saveReport(report);
      }
    }).catchError((_) {});
  }

  Future<void> _onMaterialSaved(Product? product, int qty) async {
    if (product == null) return;
    try {
      await StockService.instance.recordStockOut(
        orderOdooId: widget.order.odooId,
        productId: product.odooId,
        productName: product.name,
        qty: qty.toDouble(),
        productBarcode: product.barcode,
        uomName: product.uomName,
      );
      if (!mounted) return;
      setState(() => _materialsUsed.add({'name': product.name, 'qty': qty}));
      _showSnackBar('Material added.');
    } on StockPartialAssignException {
      if (!mounted) return;
      _showSnackBar('Insufficient stock for this material. Check Odoo.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to add material: $e');
    }
  }

  // Mở sheet, đợi kết quả, ĐÓNG sheet rồi mới xử lý -> SnackBar thấy rõ.
  Future<void> _openMaterialSheet() async {
    final result = await showModalBottomSheet<_MaterialResult?>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => MaterialEntryForm(
        onSaved: (product, qty) {
          Navigator.of(sheetCtx).pop(_MaterialResult(product, qty));
        },
      ),
    );
    if (result != null) {
      await _onMaterialSaved(result.product, result.qty);
    }
  }

  Future<void> _onCheckIn() async {
    try {
      await OrdersService.instance.checkIn(widget.order.odooId);
      if (!mounted) return;
      _showSnackBar('Checked in successfully.');
    } on OdooApiException {
      if (!mounted) return;
      _showSnackBar('Checked in locally — will sync when online.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Check-in failed: $e');
    }
  }

  Future<void> _onCheckOut() async {
    try {
      await OrdersService.instance.checkOut(widget.order.odooId);
      if (!mounted) return;
      _showSnackBar('Checked out successfully.');
    } on OdooApiException {
      if (!mounted) return;
      _showSnackBar('Checked out locally — will sync when online.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Check-out failed: $e');
    }
  }

  Future<void> _onComplete() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final report = await WorkOrderService.instance
          .getOrCreateReport(widget.order.odooId);

      // X: đã ký rồi (local hoặc Odoo) thì không bắt ký lại, không chạy lại wizard.
      final alreadySigned = report.signedAt != null;

      if (widget.order.requireSignature && !alreadySigned) {
        if (_signatureController.isEmpty) {
          _showSnackBar('Signature is required before completion.');
          return;
        }
        if (_customerNameController.text.trim().isEmpty) {
          _showSnackBar('Customer name is required to sign.');
          return;
        }
      }

      // Export chữ ký ra file PNG + bơm vào report nếu người dùng đã vẽ chữ ký và nhập tên
      final hasName = _customerNameController.text.trim().isNotEmpty;
      if (_signatureController.isNotEmpty && hasName && !alreadySigned) {
        final png = await _signatureController.toPngBytes();
        if (png != null) {
          final dir = await getApplicationDocumentsDirectory();
          final f = File(
              '${dir.path}/sig_${widget.order.odooId}_${DateTime.now().millisecondsSinceEpoch}.png');
          await f.writeAsBytes(png);
          report.customerSignaturePath = f.path;
          report.customerName = _customerNameController.text.trim();
          report.signedAt = DateTime.now();
        }
      }

      final newWorkDone = _workDoneController.text.trim();
      report.workDone = newWorkDone;
      await WorkOrderService.instance.saveReport(report);

      // Đẩy báo cáo + chữ ký + ảnh pending TRƯỚC khi đổi stage.
      // isPendingSync=false nghĩa là report đã submit trọn vẹn lần trước -> skip để tránh trùng.
      if (report.isPendingSync) {
        try {
          await WorkOrderService.instance.submitReport(report);
        } on OdooApiException catch (e) {
          logger.w('Failed to submit report online (API error): $e');
        } on IOException catch (e) {
          logger.w('Failed to submit report online (network/file error): $e');
        }
      }

      await OrdersService.instance.completeOrder(widget.order.odooId);
      if (!mounted) return;
      _showSnackBar('Order completed successfully.');
      Navigator.of(context).pop(true);
    } on OdooApiException {
      if (!mounted) return;
      _showSnackBar(
          'Offline - report & signature saved locally, will sync when online.');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to complete order: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _onSkipConfirm() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final currentOrder = _freshOrder ?? widget.order;
      bool success = false;
      if (currentOrder.recurringId != null && currentOrder.recurringId! > 0) {
        success = await RecurringService.instance.skipOccurrence(currentOrder);
      } else {
        final stageId = await OrdersService.instance
            .getStageIdByKeywords(['cancel', 'huỷ', 'cancelled']);
        if (stageId == null) {
          if (!mounted) return;
          _showSnackBar('Cancelled stage not configured in Odoo.');
          return;
        }
        await OrdersService.instance.updateStage(widget.order.odooId, stageId);
        success = true;
      }
      if (!mounted) return;
      if (success) {
        _showSnackBar('Order skipped.');
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar('Order was not skipped (it may already be processed).');
      }
    } on OdooApiException {
      if (!mounted) return;
      _showSnackBar('Skipped locally — will sync when online.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to skip order: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _askSkip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Skip Order'),
        content: const Text('Mark this order as cancelled?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onSkipConfirm();
            },
            child: const Text('Yes, Skip'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not specified';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _duration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'N/A hrs';
    return '${end.difference(start).inHours} hrs';
  }

  Widget _buildStickyHeader() {
    final theme = Theme.of(context);
    final onSurfaceMuted = theme.colorScheme.onSurface.withOpacity(0.6);
    final onSurfaceFaint = theme.colorScheme.onSurface.withOpacity(0.5);
    final isClosed = _isClosed;
    final currentOrder = _freshOrder ?? widget.order;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: onSurfaceMuted),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(currentOrder.scheduledDateStart),
                            style: TextStyle(
                                fontSize: 14,
                                color: onSurfaceMuted,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentOrder.locationAddress ?? currentOrder.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentOrder.partnerName ?? 'Anonymous customer',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    QuickActionButton(
                        icon: Icons.phone_outlined, onTap: _onCall),
                    const SizedBox(height: 8),
                    QuickActionButton(
                        icon: Icons.chat_bubble_outline, onTap: _onSms),
                    const SizedBox(height: 8),
                    QuickActionButton(
                        icon: Icons.email_outlined, onTap: _onEmail),
                    const SizedBox(height: 8),
                    QuickActionButton(
                        icon: Icons.directions_outlined, onTap: _onDirections),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DUE',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceFaint)),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(currentOrder.scheduledDateStart)}\n$_repeatText',
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DURATION / PRICE',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceFaint)),
                      const SizedBox(height: 4),
                      Text(
                        '${_duration(currentOrder.scheduledDateStart, currentOrder.scheduledDateEnd)}\nPrice TBD',
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isClosed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: currentOrder.stage == FsmOrderStage.done
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currentOrder.isSkipped
                        ? 'Job skipped / Đã bỏ qua'
                        : (currentOrder.stage == FsmOrderStage.done
                            ? 'Job completed / Đã hoàn thành'
                            : 'Job cancelled / Đã huỷ'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: currentOrder.stage == FsmOrderStage.done
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const Key('btn_mark_complete'),
                      onPressed: _isProcessing ? null : _onComplete,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Mark complete',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('btn_skip'),
                      onPressed: _isProcessing ? null : _askSkip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Skip',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7))),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoThumb(int index, String path) {
    final theme = Theme.of(context);
    final isClosed = _isClosed;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              cacheWidth:
                  176, // ✅ decode ở 176px (2x Retina) thay vì full resolution
            ),
          ),
          if (!isClosed)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      color: theme.colorScheme.error, shape: BoxShape.circle),
                  child: Icon(Icons.close,
                      color: theme.colorScheme.onError, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachments() {
    final theme = Theme.of(context);
    final isClosed = _isClosed;

    return ExpandableSection(
      title: 'ATTACHMENTS',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ..._photoPaths
              .asMap()
              .entries
              .map((e) => _photoThumb(e.key, e.value)),
          if (!isClosed)
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined,
                        size: 28, color: theme.colorScheme.primary),
                    const SizedBox(height: 4),
                    Text('Add Photo',
                        style: TextStyle(
                            fontSize: 10, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentOrder = _freshOrder ?? widget.order;
    final isClosed = _isClosed;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(currentOrder.locationAddress ?? currentOrder.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {})
        ],
      ),
      body: Column(
        children: [
          _buildStickyHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ExpandableSection(
                    title: 'GENERAL INSTRUCTIONS',
                    initiallyExpanded: true,
                    child: Text(_stripHtml(currentOrder.description),
                        style: theme.textTheme.bodyMedium),
                  ),
                  ExpandableSection(
                    title: 'WORK REQUIRED',
                    child: Text(_stripHtml(currentOrder.description),
                        style: theme.textTheme.bodyMedium),
                  ),
                  _buildAttachments(),
                  ExpandableSection(
                    title: 'MATERIALS USED',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._materialsUsed.map(
                          (mat) => Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(mat['name'] as String),
                                trailing: Text('x${mat['qty']}'),
                                visualDensity: VisualDensity.compact,
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          key: const Key('btn_add_material'),
                          onPressed: isClosed ? null : _openMaterialSheet,
                          icon: const Icon(Icons.add),
                          label: const Text('Add material'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                      ],
                    ),
                  ),
                  ExpandableSection(
                    title: 'TIMESHEET',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('btn_check_in'),
                                onPressed: isClosed ? null : _onCheckIn,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Check-in'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('btn_check_out'),
                                onPressed: isClosed ? null : _onCheckOut,
                                icon: const Icon(Icons.stop),
                                label: const Text('Check-out'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Today'),
                          trailing: Text('No active timesheet entries'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  ExpandableSection(
                    title: 'WORK REPORT / BÁO CÁO CÔNG VIỆC',
                    child: TextField(
                      controller: _workDoneController,
                      enabled: !isClosed,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Work done / Nội dung công việc',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  ExpandableSection(
                    title: 'SIGNATURE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: _customerNameController,
                            enabled: !isClosed,
                            decoration: const InputDecoration(
                              labelText: 'Customer name (người ký)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AbsorbPointer(
                              absorbing: isClosed,
                              child: Signature(
                                key: const Key('signature_pad'),
                                controller: _signatureController,
                                height: 150,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: isClosed
                                  ? null
                                  : () => _signatureController.clear(),
                              child: const Text('Clear')),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
