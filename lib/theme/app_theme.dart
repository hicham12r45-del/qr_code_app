import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF2F7AFE);
  static const Color primaryDark = Color(0xFF1B5FE0);
  static const Color background = Color(0xFFF4F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF14213D);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color divider = Color(0xFFE7ECF5);

  // Quick create tile accent colors (from design)
  static const Color websiteBg = Color(0xFFE7F0FF);
  static const Color websiteFg = Color(0xFF2F7AFE);
  static const Color textBg = Color(0xFFEFEAFB);
  static const Color textFg = Color(0xFF7C4DE8);
  static const Color wifiBg = Color(0xFFE4F8EE);
  static const Color wifiFg = Color(0xFF23B26D);
  static const Color contactBg = Color(0xFFFDF1E4);
  static const Color contactFg = Color(0xFFE08A2B);
  static const Color emailBg = Color(0xFFFCE9EC);
  static const Color emailFg = Color(0xFFE84366);
  static const Color phoneBg = Color(0xFFE4F3FC);
  static const Color phoneFg = Color(0xFF1FA1D9);

  static const List<Color> qrColorOptions = [
    Color(0xFF2F7AFE),
    Color(0xFF1B2B4B),
    Color(0xFF23B26D),
    Color(0xFF8B5CF6),
    Color(0xFFE8792E),
  ];

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: background,
        primaryColor: primary,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: primaryDark,
          surface: surface,
          error: Color(0xFFE84366),
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
          titleMedium: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          hintStyle: const TextStyle(color: textSecondary),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.6),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        dividerColor: divider,
      );
}
