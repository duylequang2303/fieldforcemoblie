import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:fieldforce_mobile/widgets/material_entry_form.dart';
import 'package:fieldforce_mobile/features/stock/models/product.dart';

void main() {
  patrolTest(
    'Thêm vật tư: Tìm kiếm, chọn và lưu',
    nativeAutomation: true,
    ($) async {
      bool isSaved = false;

      // 1. Mở app (Mock màn hình có chứa MaterialEntryForm)
      await $.pumpWidgetAndSettle(
        MaterialApp(
          home: Scaffold(
            body: MaterialEntryForm(
              availableProducts: [
                Product()..name = 'AC Filter (Standard)'..standardPrice = 10.0,
                Product()..name = 'Oil Filter'..standardPrice = 5.0,
              ],
              onSaved: () {
                isSaved = true;
              },
            ),
          ),
        ),
      );

      // 2. Tap vào ô tìm kiếm sản phẩm
      final searchInput = $(const Key('input_material_search'));
      await searchInput.tap();
      await $.pumpAndSettle();

      // 3. Nhập một ký tự (ví dụ: 'AC') và assert rằng danh sách gợi ý hiện ra.
      await searchInput.enterText('AC');
      await $.pumpAndSettle();

      // Danh sách gợi ý từ Autocomplete (trong MaterialEntryForm có mock 'AC Filter (Standard)')
      expect($('AC Filter (Standard)'), findsWidgets);

      // 4. Tap chọn một sản phẩm.
      await $('AC Filter (Standard)').tap();
      await $.pumpAndSettle();

      // 5. Nhập số lượng vào ô.
      final quantityInput = $(const Key('input_quantity'));
      await quantityInput.enterText('5');
      await $.pumpAndSettle();

      // 6. Tap nút Lưu.
      final saveBtn = $(const Key('btn_save_material'));
      await saveBtn.tap();
      await $.pumpAndSettle();

      // 7. Assert rằng onSaved đã được gọi (tương đương form đóng lại/báo thành công trong mock test).
      expect(isSaved, true);
    },
  );
}
