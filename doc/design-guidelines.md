# Café Bloom デザインガイドライン

## 1. デザインコンセプト

### 1.1 ビジョン
「Café Bloom」は、洗練された女性向けカフェ空間をデジタルで表現したPOSシステムです。
使いやすさと美しさを両立し、スタッフが心地よく働ける環境を提供します。

### 1.2 デザイン原則
- **Elegant（エレガント）**: 上品で洗練された印象
- **Soft（ソフト）**: 優しく親しみやすい雰囲気
- **Intuitive（直感的）**: 誰でもすぐに理解できる操作性
- **Modern（モダン）**: 現代的でトレンドを意識したデザイン

## 2. カラーシステム

### 2.1 メインカラーパレット
```dart
class CafeBloomColors {
  // Primary Colors
  static const Color primaryRoseGold = Color(0xFFE8B4B8);
  static const Color primaryLight = Color(0xFFF5D5D8);
  static const Color primaryDark = Color(0xFFD49499);
  
  // Secondary Colors
  static const Color secondaryBeige = Color(0xFFF5E6D3);
  static const Color secondaryLight = Color(0xFFFBF2E8);
  static const Color secondaryDark = Color(0xFFE8D4B8);
  
  // Accent Colors
  static const Color accentPink = Color(0xFFD4A5A5);
  static const Color accentLight = Color(0xFFE8C5C5);
  static const Color accentDark = Color(0xFFB88585);
  
  // Neutral Colors
  static const Color backgroundCream = Color(0xFFFFF8F3);
  static const Color surface = Color(0xFFFFFBF7);
  static const Color textPrimary = Color(0xFF3E3E3E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Semantic Colors
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
}
```

### 2.2 カラー使用ガイドライン
- **プライマリカラー**: 主要なアクション、選択状態
- **セカンダリカラー**: 背景、セクション区切り
- **アクセントカラー**: 重要な情報、CTAボタン
- **ニュートラルカラー**: テキスト、境界線、背景

## 3. タイポグラフィ

### 3.1 フォントファミリー
```dart
class CafeBloomTypography {
  static const String headingFont = 'Noto Serif JP';
  static const String bodyFont = 'Noto Sans JP';
  static const String numberFont = 'Roboto';
}
```

### 3.2 テキストスタイル
```dart
class CafeBloomTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: CafeBloomTypography.headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: CafeBloomTypography.headingFont,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: CafeBloomTypography.headingFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: CafeBloomTypography.bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: CafeBloomTypography.bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Numbers
  static const TextStyle numberLarge = TextStyle(
    fontFamily: CafeBloomTypography.numberFont,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle price = TextStyle(
    fontFamily: CafeBloomTypography.numberFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
```

## 4. コンポーネントデザイン

### 4.1 ボタン
```dart
class CafeBloomButton extends StatelessWidget {
  // Primary Button
  static BoxDecoration primaryDecoration = BoxDecoration(
    color: CafeBloomColors.primaryRoseGold,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
  
  // Secondary Button
  static BoxDecoration secondaryDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: CafeBloomColors.primaryRoseGold,
      width: 2,
    ),
  );
}
```

### 4.2 カード
```dart
class CafeBloomCard {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: CafeBloomColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
  
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}
```

### 4.3 入力フィールド
```dart
class CafeBloomInputDecoration {
  static InputDecoration standard({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: CafeBloomColors.textSecondary),
      floatingLabelStyle: TextStyle(color: CafeBloomColors.primaryRoseGold),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CafeBloomColors.textHint,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CafeBloomColors.primaryRoseGold,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
```

## 5. レイアウトガイドライン

### 5.1 スペーシングシステム
```dart
class CafeBloomSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
```

### 5.2 グリッドシステム
- タブレット横向き: 12カラムグリッド
- メインコンテンツ: 8カラム
- サイドバー: 4カラム
- ガター幅: 16px

### 5.3 ブレークポイント
```dart
class CafeBloomBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}
```

## 6. アニメーション

### 6.1 デュレーション
```dart
class CafeBloomAnimation {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve defaultCurve = Curves.easeInOut;
}
```

### 6.2 トランジション例
```dart
// ページ遷移
PageTransitionTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

// ボタンホバー効果
AnimatedContainer(
  duration: CafeBloomAnimation.fast,
  transform: isHovered ? Matrix4.identity().scaled(1.05) : Matrix4.identity(),
);
```

## 7. アイコノグラフィー

### 7.1 アイコンスタイル
- Material Icons Outlined を基本使用
- サイズ: 24px (標準), 20px (小), 28px (大)
- 色: textSecondary を基本、アクティブ時は primaryRoseGold

### 7.2 よく使うアイコン
```dart
class CafeBloomIcons {
  static const IconData cashRegister = Icons.point_of_sale_outlined;
  static const IconData members = Icons.people_outline;
  static const IconData products = Icons.inventory_2_outlined;
  static const IconData inventory = Icons.warehouse_outlined;
  static const IconData reports = Icons.analytics_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData search = Icons.search_outlined;
  static const IconData add = Icons.add_circle_outline;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
}
```

## 8. 実装例

### 8.1 ボトムナビゲーションバー
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: CafeBloomColors.surface,
  selectedItemColor: CafeBloomColors.primaryRoseGold,
  unselectedItemColor: CafeBloomColors.textSecondary,
  selectedLabelStyle: CafeBloomTextStyles.bodySmall.copyWith(
    fontWeight: FontWeight.w600,
  ),
  items: [
    BottomNavigationBarItem(
      icon: Icon(CafeBloomIcons.cashRegister),
      label: '会計',
    ),
    BottomNavigationBarItem(
      icon: Icon(CafeBloomIcons.members),
      label: '会員',
    ),
    BottomNavigationBarItem(
      icon: Icon(CafeBloomIcons.products),
      label: '商品',
    ),
    BottomNavigationBarItem(
      icon: Icon(CafeBloomIcons.inventory),
      label: '在庫',
    ),
    BottomNavigationBarItem(
      icon: Icon(CafeBloomIcons.reports),
      label: 'レポート',
    ),
  ],
);
```

### 8.2 商品カード
```dart
Container(
  decoration: CafeBloomCard.cardDecoration,
  padding: CafeBloomCard.cardPadding,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'カフェラテ',
        style: CafeBloomTextStyles.h3,
      ),
      SizedBox(height: CafeBloomSpacing.sm),
      Text(
        '¥450',
        style: CafeBloomTextStyles.price.copyWith(
          color: CafeBloomColors.primaryRoseGold,
        ),
      ),
    ],
  ),
);
```

## 9. アクセシビリティ

### 9.1 コントラスト比
- 通常テキスト: 最小 4.5:1
- 大きいテキスト: 最小 3:1
- インタラクティブ要素: 最小 3:1

### 9.2 タッチターゲット
- 最小サイズ: 48x48px
- 推奨サイズ: 56x56px
- 間隔: 最小 8px

### 9.3 フィードバック
- タップフィードバック: Ripple効果
- エラー表示: テキスト + アイコン
- 成功表示: トーストメッセージ

## 10. ベストプラクティス

1. **一貫性を保つ**: 定義されたスタイルシステムを厳守
2. **余白を大切に**: 適切なスペーシングで見やすさを確保
3. **階層を明確に**: タイポグラフィとカラーで情報の重要度を表現
4. **アニメーションは控えめに**: ユーザーの注意を妨げない程度に
5. **タッチフレンドリー**: タブレット操作に最適化されたUI設計