# intlパッケージのロケール初期化エラー修正

## 作業日時
2025-10-29

## 作業内容の概要
アプリケーション起動時に発生していた`LocaleDataException`エラーを修正しました。

## エラー内容
```
LocaleDataException: Locale data has not been initialized, call initializeDateFormatting(<locale>).
```

エラー発生箇所: `lib/features/dashboard/screens/dashboard_screen.dart:21`

## 原因
`DashboardScreen`内で日本語ロケール(`ja_JP`)を使用した`DateFormat`を使用していましたが、ロケールデータの初期化が行われていませんでした。

```dart
final dateFormatter = DateFormat('yyyy年MM月dd日', 'ja_JP');
```

## 修正内容

### 変更ファイル: `lib/main.dart`

1. **インポート追加**
   ```dart
   import 'package:intl/date_symbol_data_local.dart';
   ```

2. **main関数の修正**
   - `async`キーワードを追加
   - `WidgetsFlutterBinding.ensureInitialized()`を追加
   - `await initializeDateFormatting('ja_JP', null)`を追加

   ```dart
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
           enabled: !kReleaseMode,
           builder: (context) => const MyApp(),
         ),
       ),
     );
   }
   ```

## 影響範囲
- `lib/main.dart`: アプリケーションエントリーポイント
- 全体: 日本語ロケールを使用する`DateFormat`がアプリ全体で正常に動作するようになります

## テスト結果
修正後、アプリケーションの起動とダッシュボード画面の表示が正常に動作することを確認する必要があります。

## 注意事項
- `WidgetsFlutterBinding.ensureInitialized()`は、`main()`関数内で非同期処理を行う前に必ず呼び出す必要があります
- 他のロケールを使用する場合は、対応するロケールコードで`initializeDateFormatting()`を呼び出す必要があります

## 今後の課題
- 必要に応じて、他のロケールのサポートを追加する
- ロケール切り替え機能の実装を検討する

## 追加の修正（DevicePreview設定）

### 変更内容
DevicePreviewの初期設定を iPad Pro 13インチ M4 横向きに変更しました。

```dart
child: DevicePreview(
  enabled: !kReleaseMode, // 開発時のみ有効
  defaultDevice: Devices.ios.iPadPro13InchesM4,
  data: const DevicePreviewData(
    orientation: Orientation.landscape,
  ),
  isToolbarVisible: true,
  builder: (context) => const MyApp(),
),
```

### 効果
- デフォルトのプレビューデバイスがiPad Pro 13インチ M4に設定されました
- 初期方向が横向きになりました
- 以前発生していたレイアウトオーバーフローエラー（136ピクセルのオーバーフロー）が解消されました
- POSシステムに適した画面サイズで開発・テストができるようになりました
