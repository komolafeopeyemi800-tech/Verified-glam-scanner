import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/vg_payload_values.dart';

/// Rectangular AI scan frame with corner brackets and white face mesh on result hero.
class VGAttractivenessScanBoxOverlay extends StatelessWidget {
  final Map<String, dynamic> faceBox;
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;

  const VGAttractivenessScanBoxOverlay({
    super.key,
    required this.faceBox,
    required this.landmarks,
    required this.meshConnections,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanBoxMeshPainter(
        faceBox: VGPayloadValues.normalizedFaceBox(faceBox),
        landmarks: landmarks,
        meshConnections: meshConnections,
      ),
      size: Size.infinite,
    );
  }
}

class _ScanBoxMeshPainter extends CustomPainter {
  final Map<String, double> faceBox;
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;

  _ScanBoxMeshPainter({
    required this.faceBox,
    required this.landmarks,
    required this.meshConnections,
  });

  Rect _boxRect(Size size) {
    final x = faceBox['x'] ?? 0.21;
    final y = faceBox['y'] ?? 0.18;
    final w = faceBox['width'] ?? 0.58;
    final h = faceBox['height'] ?? 0.48;
    return Rect.fromLTWH(x * size.width, y * size.height, w * size.width, h * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = _boxRect(size);

    canvas.save();
    canvas.clipRect(box);
    if (landmarks.isNotEmpty) {
      _drawLandmarkMesh(canvas, size);
    } else {
      _drawGridMesh(canvas, box);
    }
    canvas.restore();

    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(box, border);

    _drawCornerBrackets(canvas, box);
  }

  void _drawLandmarkMesh(Canvas canvas, Size size) {
    final points = <Offset>[];
    for (final lm in landmarks) {
      final px = VGPayloadValues.asDouble(lm['x']);
      final py = VGPayloadValues.asDouble(lm['y']);
      if (px == null || py == null) continue;
      points.add(Offset(px * size.width, py * size.height));
    }
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (final edge in meshConnections) {
      if (edge.length < 2) continue;
      final a = edge[0];
      final b = edge[1];
      if (a < 0 || b < 0 || a >= points.length || b >= points.length) continue;
      canvas.drawLine(points[a], points[b], linePaint);
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final p in points) {
      canvas.drawCircle(p, 2.4, dotPaint);
    }
  }

  void _drawGridMesh(Canvas canvas, Rect box) {
    final mesh = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 0.9;

    const rows = 6;
    const cols = 5;
    for (var r = 0; r <= rows; r++) {
      final t = r / rows;
      final y = box.top + box.height * t;
      canvas.drawLine(Offset(box.left, y), Offset(box.right, y), mesh);
    }
    for (var c = 0; c <= cols; c++) {
      final t = c / cols;
      final x = box.left + box.width * t;
      canvas.drawLine(Offset(x, box.top), Offset(x, box.bottom), mesh);
    }

    final radial = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..strokeWidth = 0.9;
    final center = box.center;
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final edge = Offset(
        center.dx + (box.width / 2) * math.cos(angle),
        center.dy + (box.height / 2) * math.sin(angle),
      );
      canvas.drawLine(center, edge, radial);
    }
  }

  void _drawCornerBrackets(Canvas canvas, Rect box) {
    final arm = math.min(box.width, box.height) * 0.12;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    // Top-left
    canvas.drawLine(Offset(box.left, box.top + arm), Offset(box.left, box.top), paint);
    canvas.drawLine(Offset(box.left, box.top), Offset(box.left + arm, box.top), paint);
    // Top-right
    canvas.drawLine(Offset(box.right - arm, box.top), Offset(box.right, box.top), paint);
    canvas.drawLine(Offset(box.right, box.top), Offset(box.right, box.top + arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(box.left, box.bottom - arm), Offset(box.left, box.bottom), paint);
    canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left + arm, box.bottom), paint);
    // Bottom-right
    canvas.drawLine(Offset(box.right - arm, box.bottom), Offset(box.right, box.bottom), paint);
    canvas.drawLine(Offset(box.right, box.bottom - arm), Offset(box.right, box.bottom), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanBoxMeshPainter oldDelegate) =>
      oldDelegate.faceBox != faceBox ||
      oldDelegate.landmarks != landmarks ||
      oldDelegate.meshConnections != meshConnections;
}
