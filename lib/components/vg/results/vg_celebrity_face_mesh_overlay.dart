import 'package:flutter/material.dart';

/// Static green wireframe face mesh for celebrity lookalike result hero.
class VGCelebrityFaceMeshOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;
  final bool showScanFrame;

  const VGCelebrityFaceMeshOverlay({
    super.key,
    required this.landmarks,
    required this.meshConnections,
    this.showScanFrame = true,
  });

  static const _meshColor = Color(0xFF7DFF9A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showScanFrame) const _ScanFrameDecoration(),
        CustomPaint(
          painter: _CelebrityMeshPainter(
            landmarks: landmarks,
            meshConnections: meshConnections,
          ),
          size: Size.infinite,
        ),
      ],
    );
  }
}

class _ScanFrameDecoration extends StatelessWidget {
  const _ScanFrameDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 6,
          top: 24,
          bottom: 24,
          child: _SideGradientBar(),
        ),
        Positioned(
          right: 6,
          top: 24,
          bottom: 24,
          child: _SideGradientBar(),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.65),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SideGradientBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF2B6CB0).withValues(alpha: 0.85),
            const Color(0xFF48BB78).withValues(alpha: 0.85),
          ],
        ),
      ),
    );
  }
}

class _CelebrityMeshPainter extends CustomPainter {
  final List<Map<String, dynamic>> landmarks;
  final List<List<int>> meshConnections;

  _CelebrityMeshPainter({
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
      ..color = VGCelebrityFaceMeshOverlay._meshColor.withValues(alpha: 0.85)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final edge in meshConnections) {
      if (edge.length < 2) continue;
      final a = edge[0];
      final b = edge[1];
      if (a < 0 || b < 0 || a >= points.length || b >= points.length) continue;
      canvas.drawLine(points[a], points[b], linePaint);
    }

    final dotPaint = Paint()
      ..color = VGCelebrityFaceMeshOverlay._meshColor.withValues(alpha: 0.95);
    for (final p in points) {
      canvas.drawCircle(p, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrityMeshPainter oldDelegate) =>
      oldDelegate.landmarks != landmarks ||
      oldDelegate.meshConnections != meshConnections;
}
