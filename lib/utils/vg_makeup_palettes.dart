import 'package:flutter/material.dart';

import '../models/vg_makeup_state.dart';

Color vgParseHexColor(String hex) {
  try {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return const Color(0xFFC79A9A);
  }
}

/// Season palette + zone-specific extended swatches.
class VGMakeupPalettes {
  static const _lipsExtended = [
    '#872B3F',
    '#B84D62',
    '#D4788C',
    '#E8A0B0',
    '#6B2030',
    '#F2C4CE',
    '#9E3D52',
    '#C67B5C',
  ];

  static const _eyesExtended = [
    '#3D2B1F',
    '#5C6B4A',
    '#6B4E71',
    '#8B7355',
    '#4A5568',
    '#9C8575',
    '#2C1810',
    '#7D6B5A',
  ];

  static const _blushExtended = [
    '#E8A0A8',
    '#D4788C',
    '#C4956A',
    '#E8B4A0',
    '#F0C4B8',
    '#B87878',
    '#DEB887',
    '#CD8B62',
  ];

  /// Indices in combined list that are Pro-only (extended section).
  static const proOffsetLips = 4;
  static const proOffsetEyes = 4;
  static const proOffsetBlush = 4;

  static List<VGMakeupSwatch> swatchesForZone(
    VGMakeupZone zone,
    List<String> seasonPaletteHex,
  ) {
    final fromSeason = seasonPaletteHex.map((h) => VGMakeupSwatch(
          color: vgParseHexColor(h),
          fromSeasonPalette: true,
        ));

    final extendedHex = switch (zone) {
      VGMakeupZone.lips => _lipsExtended,
      VGMakeupZone.eyes => _eyesExtended,
      VGMakeupZone.blush => _blushExtended,
    };

    final extended = extendedHex.asMap().entries.map((e) {
      return VGMakeupSwatch(
        color: vgParseHexColor(e.value),
        isPro: e.key >= 4,
      );
    });

    final seen = <int>{};
    final merged = <VGMakeupSwatch>[];
    for (final s in [...fromSeason, ...extended]) {
      final key = s.color.toARGB32();
      if (seen.add(key)) merged.add(s);
    }
    return merged;
  }
}
