import 'package:flutter/material.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import 'app_providers.dart';

/// Widget gốc của ứng dụng Fieldforce Worker.
/// Kết hợp Theme + Router + MultiProvider.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp.router(
        title: 'Fieldforce Worker',
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
