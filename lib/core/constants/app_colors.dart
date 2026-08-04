import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF080808);
  static const Color apexGreen = Color(0xFF22C55E);
  static const Color energyOrange = Color(0xFFF97316);
  static const Color apexNeonRed = Color(0xFFFF2A55);
  static const Color cyberBlue = Color(0xFF3B82F6);
  static const Color textGray = Color(0xFFA1A1AA);
  static const Color white = Color(0xFFFFFFFF);

  // PREP-PANEL-ACTIVATION-U3-FIX1 — one exclusive neon color per
  // preparation-panel indicator beyond the three already above (FPS/RAM/
  // GPU): Ping, Otimização, Boost aplicado and Performance melhorada.
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonViolet = Color(0xFF9B5CFF);
  static const Color neonLime = Color(0xFFB7FF2A);
  static const Color neonMagenta = Color(0xFFFF2BD6);
}
