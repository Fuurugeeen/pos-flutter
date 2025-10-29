# TODO リスト

## 未対応項目

なし

## 完了項目

### ✅ バグ修正（2025-10-29）

#### 商品管理 - 編集ボタンのルーティング問題
- 商品管理から編集ボタンをタップしてもページが見つかりませんと表示される
- 優先度: 高
- 影響: 商品情報の編集ができない
- **修正内容**:
  - `product_list_screen.dart` のルーティングを修正
  - `/products/${id}/edit` → `/products/edit/${id}` に変更
  - `/products/new` → `/products/add` に変更
  - `app_router.dart` のルート定義と一致させた
  - 修正ファイル: `lib/features/products/screens/product_list_screen.dart:41, 64, 272, 444`

#### 会員管理 - 編集ボタンのルーティング問題
- 会員管理から編集ボタンをタップしてもページが見つかりませんと表示される
- 優先度: 高
- 影響: 会員情報の編集ができない
- **修正内容**:
  - `customer_list_screen.dart` のルーティングを修正
  - `/customers/${id}/edit` → `/customers/edit/${id}` に変更
  - `/customers/new` → `/customers/add` に変更
  - `app_router.dart` のルート定義と一致させた
  - 修正ファイル: `lib/features/members/screens/customer_list_screen.dart:39, 60, 212, 341`

#### タブ - アクティブ状態の表示問題
- タブでアクティブになるとアイコンも文字も表示されない
- 優先度: 中
- 影響: ユーザビリティの低下
- **修正内容**:
  - `reports_screen.dart` の TabBar の色設定を修正
  - アクティブなタブの `labelColor` を `primary`（ローズゴールド）から `Colors.white` に変更
  - 非アクティブなタブの色も `Colors.white.withValues(alpha: 0.7)` に変更
  - インジケーター色も `Colors.white` に変更
  - `AppBar` の背景色（ローズゴールド）とのコントラストを改善
  - これにより、アクティブなタブのアイコンと文字が白色で明確に表示されるようになった
  - 修正ファイル: `lib/features/reports/screens/reports_screen.dart:58-60`
