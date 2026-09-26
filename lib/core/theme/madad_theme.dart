import 'package:flutter/material.dart';

import 'madad_colors.dart';

abstract final class MadadTheme {
  static ThemeData get light {
    const family = 'Tajawal';

    TextStyle text({
      required double size,
      FontWeight weight = FontWeight.w400,
      double height = 1.45,
      Color color = MadadColors.navy,
    }) {
      return TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );
    }

    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      fontFamily: family,
      scaffoldBackgroundColor: MadadColors.sand,
      colorScheme: const ColorScheme.light(
        primary: MadadColors.teal,
        onPrimary: MadadColors.white,
        secondary: MadadColors.navy,
        onSecondary: MadadColors.white,
        surface: MadadColors.white,
        onSurface: MadadColors.navy,
        error: MadadColors.navy,
        onError: MadadColors.white,
      ),
      textTheme: TextTheme(
        displaySmall: text(size: 36, weight: FontWeight.w700, height: 1.3),
        headlineMedium: text(size: 26, weight: FontWeight.w700, height: 1.35),
        headlineSmall: text(size: 22, weight: FontWeight.w700, height: 1.35),
        titleLarge: text(size: 18, weight: FontWeight.w700),
        titleMedium: text(size: 16, weight: FontWeight.w700),
        titleSmall: text(size: 14, weight: FontWeight.w700),
        bodyLarge: text(size: 16),
        bodyMedium: text(size: 14),
        bodySmall: text(size: 12, color: MadadColors.muted),
        labelLarge: text(size: 16, weight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: MadadColors.sand,
        foregroundColor: MadadColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text(size: 20, weight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MadadColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: text(size: 14, color: MadadColors.muted),
        labelStyle: text(size: 14, color: MadadColors.muted),
        errorStyle: text(size: 12, weight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: MadadColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: MadadColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: MadadColors.teal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: MadadColors.navy),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: MadadColors.navy, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MadadColors.teal,
          foregroundColor: MadadColors.white,
          disabledBackgroundColor: MadadColors.teal.withValues(alpha: 0.40),
          disabledForegroundColor: MadadColors.white,
          minimumSize: const Size(64, 52),
          elevation: 0,
          textStyle: text(
            size: 16,
            weight: FontWeight.w700,
            color: MadadColors.white,
          ),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MadadColors.navy,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: MadadColors.navy),
          textStyle: text(size: 16, weight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MadadColors.teal,
          textStyle: text(
            size: 15,
            weight: FontWeight.w700,
            color: MadadColors.teal,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: MadadColors.line, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MadadColors.navy,
        contentTextStyle: text(size: 14, color: MadadColors.white),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MadadColors.teal,
      ),
    );
  }
}
