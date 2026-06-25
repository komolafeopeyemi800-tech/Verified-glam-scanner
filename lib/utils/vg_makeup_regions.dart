import 'dart:ui';

import 'package:flutter/material.dart';

import 'vg_camera_utils.dart';
import 'vg_constants.dart';

/// Normalized ellipse (0–1 coordinates relative to preview size).
class VGMakeupEllipseRegion {
  final double centerX;
  final double centerY;
  final double width;
  final double height;

  const VGMakeupEllipseRegion({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
  });

  Rect toRect(Size size) {
    final cx = centerX * size.width;
    final cy = centerY * size.height;
    final w = width * size.width;
    final h = height * size.height;
    return Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
  }
}

class VGMakeupFaceRegions {
  final VGMakeupEllipseRegion lips;
  final List<VGMakeupEllipseRegion> eyes;
  final List<VGMakeupEllipseRegion> blush;

  const VGMakeupFaceRegions({
    required this.lips,
    required this.eyes,
    required this.blush,
  });

  static VGMakeupFaceRegions fromNormalizedFaceRect(Rect n) {
    final cx = n.center.dx;
    final cy = n.center.dy;
    final fw = n.width;
    final fh = n.height;

    return VGMakeupFaceRegions(
      lips: VGMakeupEllipseRegion(
        centerX: cx,
        centerY: n.bottom - fh * 0.12,
        width: fw * 0.42,
        height: fh * 0.09,
      ),
      eyes: [
        VGMakeupEllipseRegion(
          centerX: cx - fw * 0.18,
          centerY: cy - fh * 0.12,
          width: fw * 0.22,
          height: fh * 0.08,
        ),
        VGMakeupEllipseRegion(
          centerX: cx + fw * 0.18,
          centerY: cy - fh * 0.12,
          width: fw * 0.22,
          height: fh * 0.08,
        ),
      ],
      blush: [
        VGMakeupEllipseRegion(
          centerX: cx - fw * 0.26,
          centerY: cy + fh * 0.06,
          width: fw * 0.2,
          height: fh * 0.14,
        ),
        VGMakeupEllipseRegion(
          centerX: cx + fw * 0.26,
          centerY: cy + fh * 0.06,
          width: fw * 0.2,
          height: fh * 0.14,
        ),
      ],
    );
  }

  static const VGMakeupFaceRegions fallback = VGMakeupFaceRegions(
    lips: VGMakeupEllipseRegion(centerX: 0.5, centerY: 0.72, width: 0.28, height: 0.06),
    eyes: [
      VGMakeupEllipseRegion(centerX: 0.38, centerY: 0.42, width: 0.14, height: 0.05),
      VGMakeupEllipseRegion(centerX: 0.62, centerY: 0.42, width: 0.14, height: 0.05),
    ],
    blush: [
      VGMakeupEllipseRegion(centerX: 0.32, centerY: 0.52, width: 0.12, height: 0.1),
      VGMakeupEllipseRegion(centerX: 0.68, centerY: 0.52, width: 0.12, height: 0.1),
    ],
  );
}

/// Loads face-based makeup regions for [photoPath] (preview-sized detection).
Future<VGMakeupFaceRegions> vgMakeupRegionsFromPhoto(String photoPath, Size previewSize) async {
  final face = await vgDetectFaceBoundsFromFile(photoPath, previewSize);
  if (face == null || previewSize.isEmpty) return VGMakeupFaceRegions.fallback;

  final normalized = Rect.fromLTRB(
    face.left / previewSize.width,
    face.top / previewSize.height,
    face.right / previewSize.width,
    face.bottom / previewSize.height,
  );
  return VGMakeupFaceRegions.fromNormalizedFaceRect(normalized);
}

Size vgMakeupPreviewSize(double screenWidth) {
  final w = (screenWidth - 40).clamp(220.0, 400.0);
  return vgPortraitSizeForWidth(w);
}
