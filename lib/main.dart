import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/error/error_handler.dart';

void main() {
  // グローバルエラーハンドラーを初期化
  GlobalErrorHandler.init();
  
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode, // 開発時のみ有効
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Café Bloom POS',
      locale: DevicePreview.locale(context), // DevicePreview用
      builder: DevicePreview.appBuilder, // DevicePreview用
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

