import 'package:flutter/material.dart';

/// White wireframe face mesh for Beauty Score Showdown result hero.
class VGShowdownFaceMeshOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;

  const VGShowdownFaceMeshOverlay({
    super.key,
    required this.landmarks,
    required this.meshConnections,
  });

  static const _meshColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShowdownMeshPainter(
        landmarks: landmarks,
        meshConnections: meshConnections,
      ),
      size: Size.infinite,
    );
  }
}

class _ShowdownMeshPainter extends CustomPainter {
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;

  _ShowdownMeshPainter({
    required this.landmarks,
    required this.meshConnections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final points = landmarks.map((lm) {
      return Offset(
        (lm['x'] as num).toDouble() * size.width,
        (lm['y'] as num).toDouble() * size.height,
      );
    }).toList();

    final linePaint = Paint()
      ..color = VGShowdownFaceMeshOverlay._meshColor.withValues(alpha: 0.72)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    for (final edge in meshConnections) {
      if (edge.length < 2) continue;
      final a = edge[0];
      final b = edge[1];
      if (a < 0 || b < 0 || a >= points.length || b >= points.length) continue;
      canvas.drawLine(points[a], points[b], linePaint);
    }

    final dotPaint = Paint()
      ..color = VGShowdownFaceMeshOverlay._meshColor.withValues(alpha: 0.92);
    for (final p in points) {
      canvas.drawCircle(p, 2.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShowdownMeshPainter oldDelegate) =>
      oldDelegate.landmarks != landmarks ||
      oldDelegate.meshConnections != meshConnections;
}
