import 'package:flutter/material.dart';

class AppTheme {
  // Café Bloom カラーパレット
  static const Color _bloomRose = Color(0xFFE8B4B8); // ローズゴールド
  static const Color _bloomBrown = Color(0xFF8B4513); // コーヒーブラウン
  static const Color _bloomCream = Color(0xFFFDF5E6); // クリーム
  static const Color _bloomGreen = Color(0xFF90EE90); // ライトグリーン
  static const Color _bloomDarkBrown = Color(0xFF5D4037); // ダークブラウン

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: _bloomRose,
      onPrimary: Colors.white,
      secondary: _bloomBrown,
      onSecondary: Colors.white,
      tertiary: _bloomGreen,
      onTertiary: _bloomDarkBrown,
      surface: Colors.white,
      onSurface: _bloomDarkBrown,
      error: Color(0xFFB00020),
      onError: Colors.white,
      outline: Color(0xFFE0E0E0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      // AppBar テーマ
      appBarTheme: const AppBarTheme(
        backgroundColor: _bloomRose,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card テーマ
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        shadowColor: _bloomDarkBrown.withValues(alpha: 0.1),
      ),

      // Button テーマ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _bloomRose,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _bloomRose,
          side: const BorderSide(color: _bloomRose),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _bloomRose,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input テーマ
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _bloomRose),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _bloomRose.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _bloomRose, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: Colors.white,
        filled: true,
      ),

      // Chip テーマ
      chipTheme: ChipThemeData(
        backgroundColor: _bloomCream,
        selectedColor: _bloomRose,
        labelStyle: const TextStyle(color: _bloomDarkBrown),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // FloatingActionButton テーマ
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _bloomRose,
        foregroundColor: Colors.white,
      ),

      // BottomNavigationBar テーマ
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _bloomRose,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),

      // Drawer テーマ
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
      ),

      // Divider テーマ
      dividerTheme: DividerThemeData(
        color: _bloomRose.withValues(alpha: 0.2),
        thickness: 1,
      ),

      // Text テーマ
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _bloomDarkBrown,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _bloomDarkBrown,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _bloomDarkBrown,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _bloomDarkBrown,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _bloomDarkBrown,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: _bloomDarkBrown,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _bloomDarkBrown,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: _bloomRose,
      onPrimary: Colors.white,
      secondary: _bloomBrown,
      onSecondary: Colors.white,
      tertiary: _bloomGreen,
      onTertiary: _bloomDarkBrown,
      surface: Color(0xFF1A1A1A),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      outline: Color(0xFF444444),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: _bloomDarkBrown,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color(0xFF2C2C2C),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _bloomRose),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _bloomRose.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _bloomRose, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: const Color(0xFF2C2C2C),
        filled: true,
      ),
    );
  }
}