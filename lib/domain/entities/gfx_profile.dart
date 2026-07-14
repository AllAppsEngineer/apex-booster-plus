import 'package:flutter/material.dart';
import 'package:apex_booster_plus/core/constants/app_colors.dart';

enum GfxProfile {
  balanced,
  performance,
  quality,
  economy;

  String get label {
    switch (this) {
      case GfxProfile.balanced:
        return 'Equilibrado';
      case GfxProfile.performance:
        return 'Desempenho';
      case GfxProfile.quality:
        return 'Qualidade';
      case GfxProfile.economy:
        return 'Economia';
    }
  }

  IconData get icon {
    switch (this) {
      case GfxProfile.balanced:
        return Icons.tune_rounded;
      case GfxProfile.performance:
        return Icons.speed_rounded;
      case GfxProfile.quality:
        return Icons.hd_rounded;
      case GfxProfile.economy:
        return Icons.battery_saver_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case GfxProfile.balanced:
        return AppColors.cyberBlue;
      case GfxProfile.performance:
        return AppColors.apexGreen;
      case GfxProfile.quality:
        return AppColors.energyOrange;
      case GfxProfile.economy:
        return AppColors.textGray;
    }
  }

  static GfxProfile? fromLabel(String? label) {
    if (label == null) return null;
    for (final profile in GfxProfile.values) {
      if (profile.label == label) return profile;
    }
    return null;
  }
}
