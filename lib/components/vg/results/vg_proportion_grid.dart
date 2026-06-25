import 'package:flutter/material.dart';

class VGProportionGrid extends CustomPainter {
  final bool showThirds;

  VGProportionGrid({this.showThirds = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);

    if (showThirds) {
      for (final y in [0.22, 0.38, 0.55, 0.72, 0.88]) {
        canvas.drawLine(Offset(0, size.height * y), Offset(size.width, size.height * y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VGProportionGridOverlay extends StatelessWidget {
  const VGProportionGridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: VGProportionGrid(), size: Size.infinite);
  }
}
