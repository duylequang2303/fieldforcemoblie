import 'package:isar_community/isar.dart';

part 'work_report.g.dart';

/// Báo cáo nghiệm thu công việc — đính kèm với fsm.order.
@collection
class WorkReport {
  Id id = Isar.autoIncrement;

  int? odooId;

  @Index()
  late int orderOdooId;

  /// ID của user sở hữu dữ liệu offline này (cách ly dữ liệu giữa các user).
  @Index()
  int? localOwnerId;

  // Nội dung báo cáo
  late String workDone; // Công việc đã thực hiện
  String? problemsFound; // Vấn đề phát sinh
  String? recommendation; // Khuyến nghị

  // Ảnh hiện trường (paths local)
  late List<String> photoPaths;

  // Chữ ký khách hàng (base64 SVG path data)
  String? customerSignaturePath; // Path đến file ảnh chữ ký
  String? customerName; // Tên khách hàng ký

  // Timestamps
  DateTime? signedAt;
  late bool isPendingSync;
  late DateTime createdAt;

  // Trạng thái đồng bộ từng bước
  bool isResolutionSynced = false;
  bool isSignatureSynced = false;
  List<String> syncedPhotoPaths = [];

  /// Persisted "path|attachmentId" entries — saved immediately after
  /// ir.attachment.create so retries can skip re-creating duplicates.
  List<String> syncedAttachmentEntries = [];

  WorkReport();

  factory WorkReport.create({required int orderOdooId}) {
    return WorkReport()
      ..orderOdooId = orderOdooId
      ..workDone = ''
      ..photoPaths = []
      ..isResolutionSynced = false
      ..isSignatureSynced = false
      ..syncedPhotoPaths = []
      ..isPendingSync = false
      ..createdAt = DateTime.now();
  }
}
