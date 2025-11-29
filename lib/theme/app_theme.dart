import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData buildTheme(TextTheme baseTextTheme) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF7C4DFF));
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: baseTextTheme.bodyMedium?.fontFamily,
      textTheme: baseTextTheme.apply(bodyColor: Colors.black87),
      scaffoldBackgroundColor: const Color(0xFFF8F5FF),
      cardTheme: CardTheme(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
