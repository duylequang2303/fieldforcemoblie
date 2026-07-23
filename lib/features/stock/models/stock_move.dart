import 'package:isar_community/isar.dart';

part 'stock_move.g.dart';

/// Loại thao tác stock move.
enum MoveType {
  out,  // Xuất kho (dùng cho đơn)
  in_,  // Nhập lại (hoàn trả)
}

/// Một dòng xuất/nhập kho gắn với fsm.order.
@collection
class StockMove {
  Id id = Isar.autoIncrement;

  @Index()
  late int orderOdooId;   // ID của fsm.order

  late int productId;     // product.product.id
  late String productName;
  String? productCode;
  String? productBarcode;
  String? uomName;

  late double demandQty;   // Số lượng yêu cầu
  late double doneQty;     // Số lượng đã thực hiện

  @Enumerated(EnumType.name)
  late MoveType moveType;

  late bool isPendingSync;
  late DateTime createdAt;

  StockMove();

  factory StockMove.create({
    required int orderOdooId,
    required int productId,
    required String productName,
    String? productCode,
    String? productBarcode,
    String? uomName,
    required double demandQty,
    double doneQty = 0,
    MoveType moveType = MoveType.out,
  }) {
    return StockMove()
      ..orderOdooId = orderOdooId
      ..productId = productId
      ..productName = productName
      ..productCode = productCode
      ..productBarcode = productBarcode
      ..uomName = uomName
      ..demandQty = demandQty
      ..doneQty = doneQty
      ..moveType = moveType
      ..isPendingSync = true
      ..createdAt = DateTime.now();
  }
}
