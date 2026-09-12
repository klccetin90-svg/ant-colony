import 'package:flutter/material.dart';

class AppTheme {
  // 🐜 Karınca Teması Renkleri (Turkuaz, Kırmızı, Siyah, Beyaz)
  static const Color turkuaz = Color(0xFF00BCD4);
  static const Color antKirmizisi = Color(0xFFE53935);
  static const Color koyuSiyah = Color(0xFF1E1E1E);
  static const Color safBeyaz = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: turkuaz,
        primary: turkuaz,
        secondary: antKirmizisi,
        surface: safBeyaz,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: koyuSiyah,
        foregroundColor: turkuaz,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: antKirmizisi,
        foregroundColor: safBeyaz,
      ),
    );
  }
}