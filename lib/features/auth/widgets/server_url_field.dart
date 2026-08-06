import 'package:flutter/material.dart';

/// TextField chuyên dụng để nhập Odoo Server URL.
/// Tự động validate format URL và chỉ cho phép HTTPS.
class ServerUrlField extends StatelessWidget {
  const ServerUrlField({
    super.key,
    required this.controller,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  String? _validate(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập URL server';
    
    // Chỉ chấp nhận https:// (bảo mật)
    if (!value.startsWith('https://')) {
      return 'URL phải bắt đầu bằng https://';
    }
    
    // Parse an toàn - không force-unwrap
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority) return 'URL không hợp lệ';
    
    // Validate thêm: host không được rỗng
    if (uri.host.isEmpty) return 'URL không hợp lệ';
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.url,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'URL Server Odoo',
        hintText: 'https://your-odoo.com',
        prefixIcon: Icon(Icons.cloud_outlined),
      ),
      onChanged: onChanged,
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
