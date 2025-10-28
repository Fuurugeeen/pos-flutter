# 飲食店POSシステム開発TODO

## フェーズ1: プロジェクト基盤構築 (1-2日)

### 1.1 依存関係とプロジェクト設定
- [x] **必要な依存関係の追加** (1時間)
  - riverpod, flutter_riverpod (状態管理)
  - go_router (ルーティング)
  - shared_preferences (ローカルストレージ)
  - intl (国際化対応)
  - json_annotation, build_runner (JSON シリアライゼーション)
  - テスト用: mockito, riverpod_test
  - **テスト**: pubspec.yamlの依存関係チェック
  - **コミット**: "Add required dependencies for POS system"

### 1.2 プロジェクト構造の作成
- [x] **基本ディレクトリ構造の作成** (30分)
  - lib/features/ (機能別フォルダ)
  - lib/shared/ (共通コンポーネント)
  - lib/core/ (コア機能)
  - test/unit/, test/widget/, test/integration/
  - **テスト**: ディレクトリ構造の確認
  - **コミット**: "Create project directory structure"

### 1.3 コア機能とモデルの実装
- [x] **エンティティモデルの作成** (2時間)
  - Product (商品), Customer (顧客), Sale (売上), SaleItem (売上明細)
  - Enums: ProductCategory, PaymentMethod, TaxRate
  - **テスト**: モデルのunit test (JSON変換、コピー、等価性)
  - **コミット**: "Implement core entity models with tests"

- [x] **Repository インターフェースの定義** (1時間)
  - ProductRepository, CustomerRepository, SaleRepository
  - **テスト**: インターフェース実装のmock test
  - **コミット**: "Define repository interfaces"

### 1.4 状態管理の設定
- [x] **Riverpodプロバイダーの基本設定** (1時間)
  - プロバイダー構成ファイル作成
  - **テスト**: プロバイダーのunit test
  - **コミット**: "Setup Riverpod state management"

## フェーズ2: データレイヤー実装 (2-3日)

### 2.1 モック用リポジトリ実装
- [x] **MockProductRepository の実装** (2時間)
  - サンプルデータ30件の作成
  - CRUD操作の実装
  - **テスト**: 全CRUD操作のunit test
  - **コミット**: "Implement MockProductRepository with sample data"

- [x] **MockCustomerRepository の実装** (2時間)
  - サンプル顧客データ20件の作成
  - 検索機能の実装
  - **テスト**: 検索・CRUD操作のunit test
  - **コミット**: "Implement MockCustomerRepository with search"

- [x] **MockSaleRepository の実装** (2時間)
  - 過去30日分の売上データ生成
  - 集計機能の実装
  - **テスト**: データ生成・集計のunit test
  - **コミット**: "Implement MockSaleRepository with aggregation"

### 2.2 ローカルストレージ実装
- [ ] **SharedPreferences ストレージ実装** (1.5時間)
  - JSONシリアライゼーション
  - データ永続化機能
  - **テスト**: データ保存・読み込みのunit test
  - **コミット**: "Implement local storage with SharedPreferences"

## フェーズ3: UI基盤とルーティング (2日)

### 3.1 ルーティング設定
- [ ] **go_router 設定** (1時間)
  - メインルート定義
  - ネストしたルート設定
  - **テスト**: ルーティングのwidget test
  - **コミット**: "Setup go_router navigation"

### 3.2 共通UIコンポーネント
- [ ] **Café Bloomテーマの実装** (1.5時間)
  - カラーパレット設定
  - Material 3テーマ適用
  - **テスト**: テーマ適用のwidget test
  - **コミット**: "Implement Café Bloom theme"

- [ ] **共通ウィジェットの作成** (2時間)
  - カスタムボタン、カード、フォームフィールド
  - レスポンシブレイアウトヘルパー
  - **テスト**: 各ウィジェットのwidget test
  - **コミット**: "Create common UI widgets"

### 3.3 基本レイアウト
- [ ] **メインレイアウトの実装** (1.5時間)
  - ダッシュボードレイアウト
  - ボトムナビゲーション
  - **テスト**: レイアウトのwidget test
  - **コミット**: "Implement main app layout"

## フェーズ4: メイン機能実装 (5-6日)

### 4.1 ダッシュボード
- [ ] **ダッシュボード画面の実装** (2時間)
  - 今日の売上表示
  - 機能ボタンメニュー
  - **テスト**: ダッシュボードのwidget test
  - **コミット**: "Implement dashboard screen"

### 4.2 会計機能
- [ ] **商品選択画面の実装** (3時間)
  - カテゴリ別商品表示
  - 商品検索機能
  - **テスト**: 商品選択のwidget/integration test
  - **コミット**: "Implement product selection for checkout"

- [ ] **カート機能の実装** (2時間)
  - 商品追加・削除・数量変更
  - 小計・税額計算
  - **テスト**: カート操作のunit/widget test
  - **コミット**: "Implement shopping cart functionality"

- [ ] **決済処理の実装** (2時間)
  - 決済方法選択
  - 会計完了処理
  - **テスト**: 決済処理のunit/integration test
  - **コミット**: "Implement payment processing"

### 4.3 会員管理機能
- [ ] **会員検索画面の実装** (2時間)
  - 検索フォーム
  - 会員一覧表示
  - **テスト**: 検索機能のwidget/integration test
  - **コミット**: "Implement customer search"

- [ ] **会員詳細・編集の実装** (2時間)
  - 会員情報表示・編集
  - ポイント管理
  - **テスト**: 会員操作のwidget test
  - **コミット**: "Implement customer detail and edit"

### 4.4 商品管理機能
- [ ] **商品一覧画面の実装** (1.5時間)
  - 商品リスト表示
  - カテゴリフィルター
  - **テスト**: 商品一覧のwidget test
  - **コミット**: "Implement product list screen"

- [ ] **商品編集機能の実装** (2時間)
  - 商品情報編集フォーム
  - バリデーション
  - **テスト**: 商品編集のwidget/unit test
  - **コミット**: "Implement product edit functionality"

## フェーズ5: レポート・分析機能 (2-3日)

### 5.1 売上レポート
- [ ] **日別売上レポートの実装** (2時間)
  - データ集計ロジック
  - グラフ表示
  - **テスト**: 集計処理のunit test
  - **コミット**: "Implement daily sales report"

- [ ] **商品別売上分析の実装** (1.5時間)
  - 商品ランキング
  - カテゴリ別分析
  - **テスト**: 分析ロジックのunit test
  - **コミット**: "Implement product sales analysis"

### 5.2 データエクスポート
- [ ] **Excel出力機能の実装** (2時間)
  - CSV形式でのデータ出力
  - レポート形式の整形
  - **テスト**: エクスポート機能のunit test
  - **コミット**: "Implement data export to CSV/Excel"

## フェーズ6: 在庫管理機能 (2日)

### 6.1 在庫表示・管理
- [ ] **在庫一覧画面の実装** (1.5時間)
  - 現在庫表示
  - アラート表示
  - **テスト**: 在庫表示のwidget test
  - **コミット**: "Implement inventory list screen"

- [ ] **入出庫管理の実装** (2時間)
  - 入庫・出庫記録
  - 在庫履歴表示
  - **テスト**: 在庫操作のunit/integration test
  - **コミット**: "Implement inventory management"

## フェーズ7: 設定・管理機能 (1-2日)

### 7.1 システム設定
- [ ] **店舗・端末設定の実装** (1時間)
  - 設定画面
  - データ永続化
  - **テスト**: 設定機能のwidget test
  - **コミット**: "Implement system settings"

### 7.2 ユーザー管理
- [ ] **簡易認証機能の実装** (1.5時間)
  - ログイン画面
  - セッション管理
  - **テスト**: 認証のunit/widget test
  - **コミット**: "Implement simple authentication"

## フェーズ8: 品質保証・最適化 (2-3日)

### 8.1 統合テスト
- [ ] **主要フローの統合テストの作成** (3時間)
  - 会計フロー全体のテスト
  - 会員登録〜購入フローのテスト
  - **テスト**: End-to-endテスト
  - **コミット**: "Add comprehensive integration tests"

### 8.2 パフォーマンス最適化
- [ ] **パフォーマンステストの実行** (1時間)
  - ビルドサイズチェック
  - 初期ロード時間測定
  - **テスト**: パフォーマンステスト
  - **コミット**: "Optimize performance"

### 8.3 エラーハンドリング
- [ ] **エラーハンドリングの強化** (1.5時間)
  - グローバルエラーハンドラー
  - ユーザーフレンドリーなエラー表示
  - **テスト**: エラーケースのwidget test
  - **コミット**: "Enhance error handling"

## フェーズ9: ドキュメント・デプロイ (1日)

### 9.1 ドキュメント作成
- [ ] **API仕様書の作成** (1時間)
  - Repository インターフェース仕様
  - 将来のAPI連携用
  - **テスト**: ドキュメント内容の確認
  - **コミット**: "Add API documentation"

### 9.2 デプロイ設定
- [ ] **GitHub Pages デプロイの設定** (1時間)
  - GitHub Actions ワークフロー
  - Makefile の確認・更新
  - **テスト**: デプロイメントテスト
  - **コミット**: "Setup GitHub Pages deployment"

- [ ] **本番ビルドの最終確認** (30分)
  - リリースビルドテスト
  - 動作確認
  - **テスト**: 本番環境テスト
  - **コミット**: "Final production build verification"

## 品質基準

### 各タスクの完了条件
1. **実装**: 機能が仕様通りに動作する
2. **テスト**: 対応するunit/widget/integration testが通る
3. **コードレビュー**: flutter analyze でエラーがない
4. **動作確認**: 該当機能の手動テストが完了
5. **コミット**: 適切なコミットメッセージで変更がコミットされる

### テスト戦略
- **Unit Test**: ビジネスロジック、Repository、Provider
- **Widget Test**: UI コンポーネント、画面
- **Integration Test**: ユーザーフロー全体

### コード品質
- flutter analyze でエラー・警告なし
- テストカバレッジ 80% 以上を目標
- 各機能のテストコード必須

## 見積もり時間
- **総開発時間**: 約80-100時間 (10-12営業日)
- **1日8時間作業想定**
- **バッファ**: 20% (テスト・デバッグ・リファクタリング)

## 備考
- 各フェーズ完了後にビルド可能性を確認
- 問題発生時は即座に修正・テスト追加
- 仕様変更時はTODOリストを更新