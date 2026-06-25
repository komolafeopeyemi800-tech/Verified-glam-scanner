import 'package:flutter/material.dart';

/// Draws normalized polygon outlines (0–1 coords) on the hero.
class VGRegionOutlinePainter extends CustomPainter {
  final List<Map<String, dynamic>> regions;

  VGRegionOutlinePainter({required this.regions});

  @override
  void paint(Canvas canvas, Size size) {
    for (final region in regions) {
      final colorValue = region['color'] as int? ?? 0xFFFFFFFF;
      final fill = Paint()
        ..color = Color(colorValue).withValues(alpha: 0.30)
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = Color(colorValue).withValues(alpha: 0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final glow = Paint()
        ..color = Color(colorValue).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final polygons = region['outlinePolygons'] as List?;
      if (polygons != null && polygons.isNotEmpty) {
        for (final poly in polygons) {
          _drawPolygon(canvas, size, poly as List, fill, stroke, glow);
        }
        continue;
      }

      final points = region['outlinePoints'] as List?;
      if (points == null || points.isEmpty) continue;
      _drawPolygon(canvas, size, points, fill, stroke, glow);
    }
  }

  void _drawPolygon(
    Canvas canvas,
    Size size,
    List points,
    Paint fill,
    Paint stroke,
    Paint glow,
  ) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final pt = points[i];
      final x = (pt[0] as num).toDouble() * size.width;
      final y = (pt[1] as num).toDouble() * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, glow);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant VGRegionOutlinePainter oldDelegate) => oldDelegate.regions != regions;
}

class VGLandmarkDotsPainter extends CustomPainter {
  final List<Map<String, dynamic>> landmarks;

  VGLandmarkDotsPainter({required this.landmarks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    for (final lm in landmarks) {
      final x = (lm['x'] as num).toDouble() * size.width;
      final y = (lm['y'] as num).toDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant VGLandmarkDotsPainter oldDelegate) => oldDelegate.landmarks != landmarks;
}
