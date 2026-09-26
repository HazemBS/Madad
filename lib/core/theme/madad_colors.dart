import 'package:flutter/material.dart';

abstract final class MadadColors {
  static const navy = Color(0xFF102A43);
  static const teal = Color(0xFF18B6A4);
  static const sand = Color(0xFFF3E9D2);
  static const white = Color(0xFFFFFFFF);

  static Color get line => navy.withValues(alpha: 0.10);
  static Color get muted => navy.withValues(alpha: 0.68);
}
