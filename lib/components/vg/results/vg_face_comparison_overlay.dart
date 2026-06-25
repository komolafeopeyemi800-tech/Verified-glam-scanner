import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

/// Dual face contour overlay with Face 1 / Face 2 labels.
class VGFaceComparisonOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> faces;

  const VGFaceComparisonOverlay({super.key, required this.faces});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _FaceContourPainter(faces: faces, size: size),
              size: Size.infinite,
            ),
            ...faces.take(2).map((face) => _labelFor(face, size)),
          ],
        );
      },
    );
  }

  Widget _labelFor(Map<String, dynamic> face, Size size) {
    final center = face['center'] as Map<String, dynamic>? ?? {};
    final cx = (center['x'] as num? ?? 0.5).toDouble();
    final cy = (center['y'] as num? ?? 0.2).toDouble();
    final label = face['label'] as String? ?? 'Face';

    return Positioned(
      left: (cx * size.width - 36).clamp(4.0, size.width - 72),
      top: (cy * size.height - 28).clamp(4.0, size.height - 32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: boldTextStyle(color: Colors.white, size: 11),
        ),
      ),
    );
  }
}

class _FaceContourPainter extends CustomPainter {
  final List<Map<String, dynamic>> faces;
  final Size size;

  _FaceContourPainter({required this.faces, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final face in faces.take(2)) {
      final points = face['contourPoints'] as List?;
      if (points == null || points.isEmpty) continue;

      final color = Color(face['color'] as int? ?? 0xFFFFFFFF);
      final stroke = Paint()
        ..color = color.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

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
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceContourPainter oldDelegate) => oldDelegate.faces != faces;
}
