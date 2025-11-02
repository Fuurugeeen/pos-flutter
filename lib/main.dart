import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/error/error_handler.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Flutterバインディングの初期化
  WidgetsFlutterBinding.ensureInitialized();

  // ロケールデータの初期化（日本語）
  await initializeDateFormatting('ja_JP', null);

  // グローバルエラーハンドラーを初期化
  GlobalErrorHandler.init();

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode, // 開発時のみ有効
        defaultDevice: Devices.ios.iPadPro11Inches,
        isToolbarVisible: true,
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
