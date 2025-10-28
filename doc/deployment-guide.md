# デプロイガイド

## GitHub Pagesへのデプロイ

### 初回セットアップ

1. **GitHubリポジトリの作成**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/pos-flutter.git
   git push -u origin main
   ```

2. **GitHub Pages設定**
   - リポジトリの Settings タブを開く
   - 左メニューから "Pages" を選択
   - "Source" で "GitHub Actions" を選択
   - 保存

3. **初回デプロイ**
   ```bash
   make release
   ```

### デプロイ手順

#### 自動デプロイ（推奨）
```bash
make release
```

このコマンドで以下が自動実行されます：
1. クリーンビルドの実行
2. Flutter Webアプリのビルド
3. 空コミットの作成（メッセージ: "release: Deploy to GitHub Pages"）
4. mainブランチへのプッシュ
5. GitHub Actionsによる自動デプロイ

#### 手動デプロイ
```bash
# 1. ビルド
flutter build web --release --base-href /pos-flutter/

# 2. コミット
git add .
git commit --allow-empty -m "release: Deploy to GitHub Pages"

# 3. プッシュ
git push origin main
```

### デプロイ状況の確認

1. **GitHub Actions**
   - リポジトリの "Actions" タブで実行状況を確認
   - "Deploy to GitHub Pages" ワークフローの進行状況を監視

2. **デプロイ完了後**
   - URL: `https://YOUR_USERNAME.github.io/pos-flutter/`
   - デプロイには通常2-3分かかります

### トラブルシューティング

#### デプロイが実行されない
- コミットメッセージに "release" が含まれているか確認
- GitHub Pagesの設定が "GitHub Actions" になっているか確認

#### 404エラーが表示される
- `--base-href` オプションがリポジトリ名と一致しているか確認
- GitHub Pagesが有効になっているか確認

#### ビルドエラー
```bash
# クリーンビルドを試す
flutter clean
flutter pub get
flutter build web --release
```

### 開発フロー

1. **開発**
   ```bash
   make run  # 開発サーバー起動
   ```

2. **テスト**
   ```bash
   make test
   ```

3. **コード品質チェック**
   ```bash
   make analyze
   make format
   ```

4. **デプロイ**
   ```bash
   make release
   ```

### 環境変数

本番環境用の設定が必要な場合は、以下のファイルを作成：

```dart
// lib/config/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const String apiUrl = isProduction 
    ? 'https://api.production.com' 
    : 'http://localhost:3000';
}
```

### キャッシュ対策

Flutter Webアプリケーションは自動的にバージョニングされたアセットを生成しますが、
強制的にキャッシュをクリアする必要がある場合：

1. サービスワーカーの更新
2. ブラウザのハードリロード（Ctrl+Shift+R）

### セキュリティ注意事項

- APIキーやシークレット情報は絶対にコードに含めない
- 環境変数は GitHub Secrets を使用
- ローカルストレージのデータは暗号化を検討

### パフォーマンス最適化

1. **画像最適化**
   - WebP形式の使用を推奨
   - 適切なサイズへのリサイズ

2. **コード分割**
   - 遅延ロードの活用
   - 不要なパッケージの削除

3. **キャッシュ戦略**
   - Service Workerの適切な設定
   - 静的アセットのキャッシュ期間設定