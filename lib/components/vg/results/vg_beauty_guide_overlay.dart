import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';

/// Editorial guide lines on the portrait (symmetry axis, thirds, feature curves).
class VGBeautyGuideOverlay extends StatelessWidget {
  final Map<String, dynamic> guides;

  const VGBeautyGuideOverlay({super.key, required this.guides});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BeautyGuidePainter(guides: guides),
      size: Size.infinite,
    );
  }
}

class _BeautyGuidePainter extends CustomPainter {
  final Map<String, dynamic> guides;

  static const _guideColor = Color(0xFFC5A373);

  _BeautyGuidePainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final dashed = Paint()
      ..color = _guideColor.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final solid = Paint()
      ..color = bmPrimaryColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = (guides['verticalCenter'] as num? ?? 0.5).toDouble() * size.width;
    _drawDashedLine(canvas, Offset(cx, 0), Offset(cx, size.height), dashed);

    final eyeY = (guides['eyeLineY'] as num? ?? 0.38).toDouble() * size.height;
    final lipY = (guides['lipLineY'] as num? ?? 0.62).toDouble() * size.height;
    _drawDashedLine(canvas, Offset(0, eyeY), Offset(size.width, eyeY), dashed);
    _drawDashedLine(canvas, Offset(0, lipY), Offset(size.width, lipY), dashed);

    _drawPolyline(canvas, size, guides['browCurve'], solid);
    _drawPolyline(canvas, size, guides['noseBridge'], solid);
    _drawPolyline(canvas, size, guides['jawCurve'], solid);
  }

  void _drawPolyline(Canvas canvas, Size size, dynamic points, Paint paint) {
    final list = (points as List?)?.cast<Map<String, dynamic>>();
    if (list == null || list.length < 2) return;

    final path = Path();
    for (var i = 0; i < list.length; i++) {
      final p = list[i];
      final o = Offset(
        (p['x'] as num).toDouble() * size.width,
        (p['y'] as num).toDouble() * size.height,
      );
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final path = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6;
        canvas.drawPath(metric.extractPath(distance, math.min(next, metric.length)), paint);
        distance = next + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BeautyGuidePainter oldDelegate) => oldDelegate.guides != guides;
}
