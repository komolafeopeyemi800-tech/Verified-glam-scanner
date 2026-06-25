import 'package:flutter/material.dart';

import '../../../models/vg_makeup_state.dart';
import '../../../utils/vg_makeup_regions.dart';

class VGMakeupZonePainter extends CustomPainter {
  final Color? color;
  final double intensity;
  final List<VGMakeupEllipseRegion> regions;
  final BlendMode blendMode;

  VGMakeupZonePainter({
    required this.color,
    required this.intensity,
    required this.regions,
    this.blendMode = BlendMode.softLight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || intensity <= 0) return;

    final layerPaint = Paint()..blendMode = blendMode;
    canvas.saveLayer(Offset.zero & size, layerPaint);

    final fill = Paint()
      ..color = color!.withValues(alpha: (intensity * 0.85).clamp(0.0, 0.9))
      ..blendMode = blendMode;

    for (final region in regions) {
      canvas.drawOval(region.toRect(size), fill);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VGMakeupZonePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.intensity != intensity ||
        oldDelegate.regions != regions;
  }
}

List<VGMakeupEllipseRegion> regionsForZone(VGMakeupZone zone, VGMakeupFaceRegions regions) {
  switch (zone) {
    case VGMakeupZone.lips:
      return [regions.lips];
    case VGMakeupZone.eyes:
      return regions.eyes;
    case VGMakeupZone.blush:
      return regions.blush;
  }
}
