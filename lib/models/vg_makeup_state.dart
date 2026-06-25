import 'package:flutter/material.dart';

import '../utils/vg_makeup_regions.dart';

enum VGMakeupZone { lips, eyes, blush }

/// In-memory makeup session state (API can hydrate regions later).
class VGMakeupState {
  final VGMakeupZone activeZone;
  final double intensity;
  final Color? lipsColor;
  final Color? eyesColor;
  final Color? blushColor;
  final VGMakeupFaceRegions regions;

  const VGMakeupState({
    this.activeZone = VGMakeupZone.lips,
    this.intensity = 0.65,
    this.lipsColor,
    this.eyesColor,
    this.blushColor,
    required this.regions,
  });

  Color? colorFor(VGMakeupZone zone) {
    switch (zone) {
      case VGMakeupZone.lips:
        return lipsColor;
      case VGMakeupZone.eyes:
        return eyesColor;
      case VGMakeupZone.blush:
        return blushColor;
    }
  }

  VGMakeupState copyWith({
    VGMakeupZone? activeZone,
    double? intensity,
    Color? lipsColor,
    Color? eyesColor,
    Color? blushColor,
    bool clearLips = false,
    bool clearEyes = false,
    bool clearBlush = false,
    VGMakeupFaceRegions? regions,
  }) {
    return VGMakeupState(
      activeZone: activeZone ?? this.activeZone,
      intensity: intensity ?? this.intensity,
      lipsColor: clearLips ? null : (lipsColor ?? this.lipsColor),
      eyesColor: clearEyes ? null : (eyesColor ?? this.eyesColor),
      blushColor: clearBlush ? null : (blushColor ?? this.blushColor),
      regions: regions ?? this.regions,
    );
  }

  VGMakeupState clearActiveZone() {
    switch (activeZone) {
      case VGMakeupZone.lips:
        return copyWith(clearLips: true);
      case VGMakeupZone.eyes:
        return copyWith(clearEyes: true);
      case VGMakeupZone.blush:
        return copyWith(clearBlush: true);
    }
  }

  VGMakeupState resetAll() {
    return VGMakeupState(
      activeZone: activeZone,
      intensity: intensity,
      regions: regions,
    );
  }
}

class VGMakeupSwatch {
  final Color color;
  final bool isPro;
  final bool fromSeasonPalette;

  const VGMakeupSwatch({
    required this.color,
    this.isPro = false,
    this.fromSeasonPalette = false,
  });
}
