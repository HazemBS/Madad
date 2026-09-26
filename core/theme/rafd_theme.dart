import 'package:flutter/material.dart';

import '../../theme/rafd_colors.dart';

abstract final class RafdTheme {
  const RafdTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RafdColors.teal,
      brightness: Brightness.light,
      primary: RafdColors.teal,
      secondary: RafdColors.navy,
      surface: RafdColors.white,
      error: RafdColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RafdColors.offWhite,
      fontFamily: 'Tahoma',

      appBarTheme: const AppBarTheme(
        backgroundColor: RafdColors.offWhite,
        foregroundColor: RafdColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: RafdColors.ink,
          fontFamily: 'Tahoma',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: RafdColors.ink,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        headlineLarge: TextStyle(
          color: RafdColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          color: RafdColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          color: RafdColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          color: RafdColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          color: RafdColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          color: RafdColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          color: RafdColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RafdColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: RafdColors.muted),
        hintStyle: const TextStyle(color: RafdColors.muted),
        errorStyle: const TextStyle(color: RafdColors.error, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RafdColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RafdColors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RafdColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: RafdColors.error, width: 1.5),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: RafdColors.teal,
          foregroundColor: RafdColors.white,
          disabledBackgroundColor: RafdColors.disabled,
          disabledForegroundColor: RafdColors.muted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          foregroundColor: RafdColors.teal,
          side: const BorderSide(color: RafdColors.teal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: RafdColors.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: RafdColors.navy,
        contentTextStyle: const TextStyle(
          color: RafdColors.white,
          fontFamily: 'Tahoma',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
