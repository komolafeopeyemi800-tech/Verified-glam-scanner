import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';

/// Triangulated mesh lines between normalized landmark points.
class VGLandmarkMeshPainter extends CustomPainter {
  final List<Map<String, dynamic>> landmarks;

  VGLandmarkMeshPainter({required this.landmarks});

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.length < 2) return;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final offsets = landmarks.map((lm) {
      return Offset(
        (lm['x'] as num).toDouble() * size.width,
        (lm['y'] as num).toDouble() * size.height,
      );
    }).toList();

    for (var i = 0; i < offsets.length; i++) {
      for (var j = i + 1; j < offsets.length; j++) {
        if ((i - j).abs() <= 2 || (i == 0 && j == offsets.length - 1)) {
          canvas.drawLine(offsets[i], offsets[j], stroke);
        }
      }
    }

    final dot = Paint()..color = bmSpecialColor.withValues(alpha: 0.9);
    for (final o in offsets) {
      canvas.drawCircle(o, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant VGLandmarkMeshPainter oldDelegate) => oldDelegate.landmarks != landmarks;
}
