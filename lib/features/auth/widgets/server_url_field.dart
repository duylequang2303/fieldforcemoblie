import 'package:flutter/material.dart';

/// TextField chuyên dụng để nhập Odoo Server URL.
/// Tự động thêm 'https://' prefix và validate format URL.
class ServerUrlField extends StatefulWidget {
  const ServerUrlField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  State<ServerUrlField> createState() => _ServerUrlFieldState();
}

class _ServerUrlFieldState extends State<ServerUrlField> {
  String? _error;

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
      controller: widget.controller,
      keyboardType: TextInputType.url,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: 'URL Server Odoo',
        hintText: 'https://your-odoo.com',
        prefixIcon: const Icon(Icons.cloud_outlined),
        errorText: _error,
      ),
      onChanged: (val) {
        setState(() => _error = _validate(val));
        widget.onChanged?.call(val);
      },
      validator: _validate,
    );
  }
}
