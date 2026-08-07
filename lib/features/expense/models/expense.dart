import 'package:isar_community/isar.dart';

part 'expense.g.dart';

/// Loại chi phí.
enum ExpenseCategory {
  fuel, // Nhiên liệu
  meal, // Ăn uống
  transport, // Vận chuyển
  material, // Vật liệu
  other, // Khác
}

/// Một khoản chi phí của Worker trong chuyến công tác.
/// Map với hr.expense trên Odoo.
@collection
class Expense {
  Id id = Isar.autoIncrement;

  int? odooId;

  @Index()
  late int orderOdooId;

  /// ID của user sở hữu dữ liệu offline này (cách ly dữ liệu giữa các user).
  @Index()
  int? localOwnerId;

  late String name; // Mô tả chi phí
  late double amount; // Số tiền (VND)
  late DateTime date;

  @Enumerated(EnumType.name)
  late ExpenseCategory category;

  String? receiptImagePath; // Đường dẫn ảnh hoá đơn local
  int? receiptAttachmentId; // Odoo ir.attachment.id (backup server-side)
  String? note;

  late bool isPendingSync;
  late DateTime createdAt;

  Expense();

  factory Expense.create({
    required int orderOdooId,
    required String name,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? receiptImagePath,
    int? receiptAttachmentId,
    String? note,
  }) {
    return Expense()
      ..orderOdooId = orderOdooId
      ..name = name
      ..amount = amount
      ..date = date
      ..category = category
      ..receiptImagePath = receiptImagePath
      ..receiptAttachmentId = receiptAttachmentId
      ..note = note
      ..isPendingSync = true
      ..createdAt = DateTime.now();
  }

  String get categoryLabel {
    switch (category) {
      case ExpenseCategory.fuel:
        return 'Nhiên liệu';
      case ExpenseCategory.meal:
        return 'Ăn uống';
      case ExpenseCategory.transport:
        return 'Vận chuyển';
      case ExpenseCategory.material:
        return 'Vật liệu';
      case ExpenseCategory.other:
        return 'Khác';
    }
  }
}
