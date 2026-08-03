import 'package:isar_community/isar.dart';

part 'product.g.dart';

/// Sản phẩm/vật tư lưu local từ Odoo product.product.
@collection
class Product {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int odooId;

  late String name;
  String? defaultCode; // Mã sản phẩm nội bộ
  String? barcode; // Barcode (EAN/QR)
  String? categoryName; // product.category.name
  String? uomName; // Đơn vị tính (Unit of Measure)
  double? standardPrice; // Giá vốn
  late DateTime lastSyncAt;

  Product();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product()
      ..odooId = json['id'] as int
      ..name = (json['name'] as String?) ?? ''
      ..defaultCode = _strOrNull(json['default_code'])
      ..barcode = _strOrNull(json['barcode'])
      ..categoryName = _nameFromMany(json['categ_id'])
      ..uomName = _nameFromMany(json['uom_id'])
      ..standardPrice = (json['standard_price'] as num?)?.toDouble()
      ..lastSyncAt = DateTime.now();
  }

  static String? _strOrNull(dynamic v) =>
      (v == null || v == false) ? null : v as String;

  static String _nameFromMany(dynamic v) =>
      (v == null || v == false) ? '' : (v as List)[1] as String;
}
