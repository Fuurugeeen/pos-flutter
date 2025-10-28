.PHONY: help run test build release clean analyze format

# デフォルトターゲット
help:
	@echo "利用可能なコマンド:"
	@echo "  make run       - 開発サーバーを起動（Chrome）"
	@echo "  make test      - テストを実行"
	@echo "  make build     - リリースビルドを作成"
	@echo "  make release   - ビルドしてGitHub Pagesにデプロイ"
	@echo "  make clean     - ビルドファイルをクリーンアップ"
	@echo "  make analyze   - コード分析を実行"
	@echo "  make format    - コードフォーマットを実行"

# 開発サーバー起動
run:
	@echo "開発サーバーを起動中..."
	flutter run -d chrome

# テスト実行
test:
	@echo "テストを実行中..."
	flutter test

# リリースビルド
build:
	@echo "リリースビルドを作成中..."
	flutter build web --release --base-href /pos-flutter/

# GitHub Pagesへのデプロイ
release:
	@echo "リリースプロセスを開始..."
	@echo "1. クリーンビルド..."
	flutter clean
	@echo "2. パッケージ取得..."
	flutter pub get
	@echo "3. リリースビルド作成..."
	flutter build web --release --base-href /pos-flutter/
	@echo "4. Gitにコミット..."
	git add .
	git commit --allow-empty -m "release: Deploy to GitHub Pages"
	@echo "5. リモートにプッシュ..."
	git push origin main
	@echo "✅ リリースプロセスが完了しました！"
	@echo "GitHub Actionsでデプロイが開始されます。"

# クリーンアップ
clean:
	@echo "ビルドファイルをクリーンアップ中..."
	flutter clean
	rm -rf build/

# コード分析
analyze:
	@echo "コード分析を実行中..."
	flutter analyze

# コードフォーマット
format:
	@echo "コードをフォーマット中..."
	dart format lib/ test/

# 依存関係の更新
update-deps:
	@echo "依存関係を更新中..."
	flutter pub upgrade

# 開発環境セットアップ
setup:
	@echo "開発環境をセットアップ中..."
	flutter pub get
	@echo "✅ セットアップが完了しました！"