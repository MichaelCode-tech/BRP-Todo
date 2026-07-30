import 'package:flutter/material.dart';

class ThemeManager {
  static ThemeData getTheme(bool isDark, bool isRetro) {
    if (isRetro) {
      return _getRetroTheme(isDark);
    } else {
      return _getModernTheme(isDark);
    }
  }

  static ThemeData _getModernTheme(bool isDark) {
    // 3 Colors: 1. Yellow (Primary), 2. Dark/Light Neutral (BG), 3. Black/White (Contrast)
    final Color primaryColor = Colors.yellow[700]!;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: contrastColor),
        titleTextStyle: TextStyle(
          color: contrastColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(isDark ? Colors.black : Colors.white),
      ),
    );
  }

  static ThemeData _getRetroTheme(bool isDark) {
    // 3 Colors: 1. Neon Green (Primary), 2. Black (BG), 3. White (Contrast)
    final Color primaryColor = isDark ? const Color(0xFF00FF41) : const Color(0xFF008F11);
    final Color bgColor = isDark ? Colors.black : const Color(0xFFE0E0E0);
    final Color contrastColor = isDark ? Colors.white : Colors.black;

    return ThemeData(
      useMaterial3: false,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: contrastColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: primaryColor,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Courier',
          color: contrastColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: isDark ? Colors.black : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(primaryColor),
        checkColor: WidgetStateProperty.all(isDark ? Colors.black : Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}
