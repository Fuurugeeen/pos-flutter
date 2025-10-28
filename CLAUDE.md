# CLAUDE.md

このファイルは、このリポジトリでコードを扱う際のClaude Code (claude.ai/code) へのガイダンスを提供します。

## プロジェクト概要

これはPOS（販売時点情報管理）システム用のFlutter Webアプリケーションです。このプロジェクトはWebプラットフォーム専用に設定されています。

## 開発コマンド

### アプリケーションの実行
```bash
flutter run -d chrome
```

### Device Preview付きで実行（推奨）
```bash
flutter run -d chrome
# Device Previewが自動で有効になり、様々なデバイスサイズでテスト可能
```

### 本番用ビルド
```bash
flutter build web
```

### テストの実行
```bash
flutter test
```

### 特定のテストの実行
```bash
flutter test test/widget_test.dart
```

### コード分析とリンティング
```bash
flutter analyze
```

### 依存関係の取得
```bash
flutter pub get
```

### 依存関係のアップグレード
```bash
flutter pub upgrade
```

## プロジェクト構成

アプリケーションはFlutterの標準的なプロジェクト構造に従っています：

- **lib/main.dart**: アプリケーションのエントリーポイント。現在はカウンターデモを含む基本的なMaterialアプリが含まれています。
- **test/**: アプリケーションのウィジェットテストを含む
- **web/**: Web固有のアセットと設定ファイル
- **pubspec.yaml**: プロジェクト設定と依存関係

## 主要な依存関係

- Flutter SDK: ^3.6.1
- flutter_lints: ^5.0.0 (コード品質のため)
- device_preview: ^1.1.0 (開発時のデバイステスト用)
- Material Design 3が有効
- Café Bloomテーマカラー（ローズゴールド #E8B4B8）を適用済み

## コード品質

プロジェクトは`analysis_options.yaml`で定義されたデフォルトのFlutterリントルールを持つ`flutter_lints`パッケージを使用しています。

## ドキュメント作成ルール

**重要**: 全てのドキュメントは`doc/`フォルダ内に作成してください。これにより、プロジェクトのドキュメントが整理され、見つけやすくなります。

## 作業ログルール

**必須**: コード変更、機能追加、バグ修正などの作業を行った際は、必ず作業ログを`doc/`フォルダ内に出力してください。

作業ログには以下の情報を含めてください：

- 作業日時
- 作業内容の概要
- 変更したファイルと変更内容
- 影響範囲
- テスト結果（該当する場合）
- 注意事項や今後の課題

ログファイル名は`YYYY-MM-DD-作業内容.md`の形式で作成してください。