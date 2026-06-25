import 'package:flutter/material.dart';

import '../../../utils/vg_payload_values.dart';

const _defaultHorizontalLines = [0.18, 0.28, 0.38, 0.52, 0.64, 0.78, 0.88];

/// Alignment grid with vertical symmetry axis and landmark horizontal lines.
class VGSymmetryGridOverlay extends StatelessWidget {
  final Map<String, dynamic> guides;

  const VGSymmetryGridOverlay({super.key, this.guides = const {}});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SymmetryGridPainter(guides: guides),
      size: Size.infinite,
    );
  }
}

class _SymmetryGridPainter extends CustomPainter {
  final Map<String, dynamic> guides;

  _SymmetryGridPainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.40)
      ..strokeWidth = 1;

    final centerX = (VGPayloadValues.asDoubleOr(guides['verticalCenter'], 0.5)) * size.width;
    canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), linePaint);

    final sideRaw = VGPayloadValues.asNumList(guides['verticalSideLines']);
    final sideLines = sideRaw.isNotEmpty ? sideRaw : const [0.35, 0.65];
    for (final xNorm in sideLines) {
      final x = xNorm.toDouble() * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    final horizRaw = VGPayloadValues.asNumList(guides['horizontalLines']);
    final horizontals = horizRaw.isNotEmpty ? horizRaw : _defaultHorizontalLines;
    for (final yNorm in horizontals) {
      final y = yNorm.toDouble() * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SymmetryGridPainter oldDelegate) =>
      oldDelegate.guides != guides;
}
