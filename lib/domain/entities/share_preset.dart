enum SharePreset { portrait, square, landscape }

extension SharePresetDimensions on SharePreset {
  double get aspectRatio => switch (this) {
    SharePreset.portrait  => 9 / 16,
    SharePreset.square    => 1.0,
    SharePreset.landscape => 16 / 9,
  };

  String get label => switch (this) {
    SharePreset.portrait  => '9:16',
    SharePreset.square    => '1:1',
    SharePreset.landscape => '16:9',
  };
}
