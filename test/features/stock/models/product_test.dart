import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce_mobile/features/stock/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('should map every Odoo field of a fully populated payload', () {
      final product = Product.fromJson({
        'id': 77,
        'name': 'Ống nhựa PVC 21mm',
        'default_code': 'PVC-21',
        'barcode': '8935001234567',
        'categ_id': [12, 'Vật tư / Ống nước'],
        'uom_id': [1, 'Cái'],
        'standard_price': 25000,
      });

      expect(product.odooId, 77);
      expect(product.name, 'Ống nhựa PVC 21mm');
      expect(product.defaultCode, 'PVC-21');
      expect(product.barcode, '8935001234567');
      expect(product.categoryName, 'Vật tư / Ống nước');
      expect(product.uomName, 'Cái');
      expect(product.standardPrice, 25000.0);
      expect(product.lastSyncAt, isA<DateTime>());
    });

    test('should convert Odoo false values into null', () {
      final product = Product.fromJson({
        'id': 5,
        'name': 'Sản phẩm',
        'default_code': false,
        'barcode': false,
        'categ_id': false,
        'uom_id': false,
        'standard_price': null,
      });

      expect(product.defaultCode, isNull);
      expect(product.barcode, isNull);
      expect(product.categoryName, isNull);
      expect(product.uomName, isNull);
      expect(product.standardPrice, isNull);
    });

    test('should fall back to an empty name when Odoo omits it', () {
      final product = Product.fromJson({'id': 9});

      expect(product.name, '');
      expect(product.defaultCode, isNull);
      expect(product.barcode, isNull);
    });

    test('should coerce integer standard_price to double', () {
      final product = Product.fromJson({
        'id': 1,
        'name': 'X',
        'standard_price': 1500,
      });

      expect(product.standardPrice, isA<double>());
      expect(product.standardPrice, 1500.0);
    });

    test('should read only the label part of a many2one tuple', () {
      final product = Product.fromJson({
        'id': 2,
        'name': 'Y',
        'categ_id': [3, 'Vật tư'],
        'uom_id': [4, 'Mét'],
      });

      expect(product.categoryName, 'Vật tư');
      expect(product.uomName, 'Mét');
    });
  });
}
