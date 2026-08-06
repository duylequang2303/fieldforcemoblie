import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/server_url_field.dart';
import '../../../core/auth/secure_storage.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';

/// Màn hình đăng nhập Odoo.
/// Form gồm: Server URL, Database, Username, Password + nút Login.
/// Hỗ trợ đăng nhập biometric nếu có session lưu sẵn.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlCtrl = TextEditingController(text: 'https://');
  final _databaseCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // FocusNodes để điều hướng keyboard mượt mà (A01)
  final _serverUrlFocus = FocusNode();
  final _databaseFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    
    // Tự động clear error cũ khi người dùng bắt đầu sửa thông tin form (A13)
    _serverUrlCtrl.addListener(_onFormFieldChanged);
    _databaseCtrl.addListener(_onFormFieldChanged);
    _usernameCtrl.addListener(_onFormFieldChanged);
    _passwordCtrl.addListener(_onFormFieldChanged);
  }

  void _onFormFieldChanged() {
    final auth = context.read<AuthProvider>();
    if (auth.errorMessage != null) {
      auth.clearError();
    }
  }

  Future<void> _loadSavedCredentials() async {
    final creds = await SecureStorageService.instance.loadSavedCredentials();
    if (!mounted) return;
    setState(() {
      _serverUrlCtrl.text = creds['serverUrl'] ?? 'https://';
      _databaseCtrl.text = creds['database'] ?? '';
      _usernameCtrl.text = creds['username'] ?? '';
    });
  }

  @override
  void dispose() {
    _serverUrlCtrl.removeListener(_onFormFieldChanged);
    _databaseCtrl.removeListener(_onFormFieldChanged);
    _usernameCtrl.removeListener(_onFormFieldChanged);
    _passwordCtrl.removeListener(_onFormFieldChanged);

    _serverUrlCtrl.dispose();
    _databaseCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();

    _serverUrlFocus.dispose();
    _databaseFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final goRouter = GoRouter.of(context);
    final authProvider = context.read<AuthProvider>();

    await authProvider.login(
      serverUrl: _serverUrlCtrl.text.trim(),
      database: _databaseCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    // Chuyển trang trực tiếp sau khi đăng nhập thành công (giải quyết A07/A11/A19)
    if (!mounted) return;
    if (authProvider.isAuthenticated) {
      goRouter.go(RouteNames.shellSchedule);
    }
  }

  Future<void> _onLoginWithBiometric() async {
    final goRouter = GoRouter.of(context);
    final authProvider = context.read<AuthProvider>();
    
    await authProvider.loginWithBiometric();
    
    if (!mounted) return;
    if (authProvider.isAuthenticated) {
      goRouter.go(RouteNames.shellSchedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return LoadingStack(
          isLoading: auth.status == AuthStatus.loading,
          message: 'Đang đăng nhập...',
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    // Logo & Title
                    const Icon(
                      Icons.build_circle_outlined,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fieldforce Worker',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Đăng nhập để bắt đầu công việc',
                      style: TextStyle(color: AppColors.onSurfaceMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Error message
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ErrorView(
                          message: auth.errorMessage!,
                          onRetry: auth.clearError,
                          retryLabel: 'Đóng',
                        ),
                      ),

                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ServerUrlField(
                            controller: _serverUrlCtrl,
                            focusNode: _serverUrlFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_databaseFocus),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _databaseCtrl,
                            focusNode: _databaseFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_usernameFocus),
                            decoration: const InputDecoration(
                              labelText: 'Tên Database',
                              prefixIcon: Icon(Icons.storage_outlined),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Nhập tên database' : null,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _usernameCtrl,
                            focusNode: _usernameFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_passwordFocus),
                            decoration: const InputDecoration(
                              labelText: 'Tên đăng nhập',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Nhập tên đăng nhập' : null,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onLogin(),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Nhập mật khẩu' : null,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: auth.status == AuthStatus.loading
                                ? null
                                : _onLogin,
                            child: const Text('Đăng nhập'),
                          ),
                          if (auth.isBiometricAvailable) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: auth.status == AuthStatus.loading
                                  ? null
                                  : _onLoginWithBiometric, // Disable khi loading (A03)
                              icon: const Icon(Icons.fingerprint),
                              label: const Text(
                                  'Đăng nhập bằng vân tay / Face ID'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
