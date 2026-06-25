import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

/// Golden ratio diagnostic overlay: landmarks, measurement lines, callouts, score bar.
class VGGoldenRatioMeasurementOverlay extends StatelessWidget {
  final Map<String, dynamic> landmarks;
  final List<Map<String, dynamic>> measurements;
  final double overallScore;
  final String ratingLabel;
  final List<String> deviations;

  const VGGoldenRatioMeasurementOverlay({
    super.key,
    required this.landmarks,
    required this.measurements,
    required this.overallScore,
    required this.ratingLabel,
    this.deviations = const [],
  });

  static const _edgeInset = 6.0;
  static const _calloutWidth = 108.0;
  static const _calloutHeight = 52.0;

  /// Fixed vertical slots so left/right callouts never overlap.
  static const _leftSlotY = <String, double>{
    'eyeWidthEyeDistance': 0.20,
    'faceLengthWidth': 0.42,
    'noseWidthFaceWidth': 0.64,
  };

  static const _rightSlotY = <String, double>{
    'eyeDistanceFaceWidth': 0.20,
    'philtrumNose': 0.44,
    'mouthWidthNoseWidth': 0.68,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layouts = _buildLayouts(size);

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _GoldenRatioMeasurementPainter(
                landmarks: landmarks,
                measurements: measurements,
                layouts: layouts,
                size: size,
              ),
              size: Size.infinite,
            ),
            ...layouts.map((layout) => _calloutAt(layout, size)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black.withValues(alpha: 0.55),
                child: Text(
                  VGCopy.goldenRatioOverallBar(overallScore, ratingLabel),
                  style: boldTextStyle(color: Colors.white, size: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<_GoldenCalloutLayout> _buildLayouts(Size size) {
    return measurements.map((m) {
      final id = m['id'] as String? ?? '';
      final side = (m['labelSide'] as String? ?? 'right').toLowerCase();
      final feature = _featureCenter(m, size);
      final slotY = side == 'left'
          ? (_leftSlotY[id] ?? 0.45)
          : (_rightSlotY[id] ?? 0.45);
      final top = (slotY * size.height - _calloutHeight / 2)
          .clamp(_edgeInset + 36, size.height - _calloutHeight - 44);

      final labelCenter = side == 'left'
          ? Offset(_edgeInset + _calloutWidth / 2, top + _calloutHeight / 2)
          : Offset(size.width - _edgeInset - _calloutWidth / 2, top + _calloutHeight / 2);

      return _GoldenCalloutLayout(
        measurement: m,
        featurePoint: feature,
        labelCenter: labelCenter,
        top: top,
        side: side,
      );
    }).toList();
  }

  Offset _featureCenter(Map<String, dynamic> m, Size size) {
    final from = m['from'] as Map<String, dynamic>? ?? {};
    final to = m['to'] as Map<String, dynamic>? ?? {};
    final fx = ((from['x'] as num?)?.toDouble() ?? 0.5) + ((to['x'] as num?)?.toDouble() ?? 0.5);
    final fy = ((from['y'] as num?)?.toDouble() ?? 0.5) + ((to['y'] as num?)?.toDouble() ?? 0.5);
    return Offset(fx / 2 * size.width, fy / 2 * size.height);
  }

  Widget _calloutAt(_GoldenCalloutLayout layout, Size size) {
    final m = layout.measurement;
    final pass = m['pass'] == true;
    final ratio = (m['ratio'] as num?)?.toDouble() ?? 0;
    final delta = (m['delta'] as num?)?.toDouble() ?? 0;
    final shortName = VGCopy.goldenRatioShortName(m['id'] as String? ?? '');

    final box = _GoldenRatioCalloutBox(
      line1: '$shortName: ${ratio.toStringAsFixed(3)}',
      line2: VGCopy.goldenRatioDeltaLabel(delta),
      pass: pass,
    );

    return Positioned(
      left: layout.side == 'left' ? _edgeInset : null,
      right: layout.side == 'right' ? _edgeInset : null,
      top: layout.top,
      child: SizedBox(width: _calloutWidth, child: box),
    );
  }
}

class _GoldenCalloutLayout {
  final Map<String, dynamic> measurement;
  final Offset featurePoint;
  final Offset labelCenter;
  final double top;
  final String side;

  const _GoldenCalloutLayout({
    required this.measurement,
    required this.featurePoint,
    required this.labelCenter,
    required this.top,
    required this.side,
  });
}

class _GoldenRatioCalloutBox extends StatelessWidget {
  final String line1;
  final String line2;
  final bool pass;

  const _GoldenRatioCalloutBox({
    required this.line1,
    required this.line2,
    required this.pass,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = pass ? const Color(0xFF2E7D32) : const Color(0xFFE53935);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            line1,
            style: boldTextStyle(color: bmSpecialColorDark, size: 8),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          1.height,
          Text(line2, style: secondaryTextStyle(size: 7, color: appTextColorSecondary)),
          1.height,
          Text(
            pass ? VGCopy.resultPass : VGCopy.goldenRatioFailLabel,
            style: boldTextStyle(color: statusColor, size: 7),
          ),
        ],
      ),
    );
  }
}

class _GoldenRatioMeasurementPainter extends CustomPainter {
  final Map<String, dynamic> landmarks;
  final List<Map<String, dynamic>> measurements;
  final List<_GoldenCalloutLayout> layouts;
  final Size size;

  _GoldenRatioMeasurementPainter({
    required this.landmarks,
    required this.measurements,
    required this.layouts,
    required this.size,
  });

  Offset _pt(Map<String, dynamic>? p) {
    if (p == null) return Offset.zero;
    return Offset(
      (p['x'] as num).toDouble() * size.width,
      (p['y'] as num).toDouble() * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), gridPaint);
    for (final yNorm in [0.38, 0.52, 0.64]) {
      canvas.drawLine(
        Offset(0, size.height * yNorm),
        Offset(size.width, size.height * yNorm),
        gridPaint,
      );
    }

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    for (final entry in landmarks.entries) {
      final p = entry.value as Map<String, dynamic>?;
      if (p == null) continue;
      canvas.drawCircle(_pt(p), 3.2, dotPaint);
    }

    final measurePaint = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.88)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final m in measurements) {
      final from = _pt(m['from'] as Map<String, dynamic>?);
      final to = _pt(m['to'] as Map<String, dynamic>?);
      final lineType = m['lineType'] as String? ?? 'horizontal';
      final highlight = m['highlightBracket'] == true;

      if (lineType == 'verticalBracket') {
        final bracketX = from.dx - 14;
        canvas.drawLine(Offset(bracketX, from.dy), Offset(bracketX, to.dy), measurePaint);
        _drawBracketCap(canvas, Offset(bracketX, from.dy), true, measurePaint);
        _drawBracketCap(canvas, Offset(bracketX, to.dy), false, measurePaint);
        final faceLeft = _pt(landmarks['faceWidthLeft'] as Map<String, dynamic>?);
        final faceRight = _pt(landmarks['faceWidthRight'] as Map<String, dynamic>?);
        canvas.drawLine(faceLeft, faceRight, measurePaint);
        _drawEndpoint(canvas, faceLeft, measurePaint);
        _drawEndpoint(canvas, faceRight, measurePaint);
      } else {
        canvas.drawLine(from, to, measurePaint);
        _drawEndpoint(canvas, from, measurePaint);
        _drawEndpoint(canvas, to, measurePaint);
      }

      if (highlight) {
        _drawHighlightBracket(canvas, from, to, measurePaint);
      }
    }

    final leaderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1;

    for (final layout in layouts) {
      final edge = _calloutEdge(layout.labelCenter, layout.side);
      canvas.drawLine(edge, layout.featurePoint, leaderPaint);
    }
  }

  Offset _calloutEdge(Offset labelCenter, String side) {
    if (side == 'left') {
      return Offset(
        labelCenter.dx + VGGoldenRatioMeasurementOverlay._calloutWidth / 2,
        labelCenter.dy,
      );
    }
    return Offset(
      labelCenter.dx - VGGoldenRatioMeasurementOverlay._calloutWidth / 2,
      labelCenter.dy,
    );
  }

  void _drawEndpoint(Canvas canvas, Offset p, Paint paint) {
    canvas.drawCircle(p, 3, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
  }

  void _drawBracketCap(Canvas canvas, Offset p, bool top, Paint paint) {
    const arm = 8.0;
    canvas.drawLine(p, Offset(p.dx + arm, p.dy), paint);
    if (top) {
      canvas.drawLine(p, Offset(p.dx, p.dy + arm), paint);
    } else {
      canvas.drawLine(p, Offset(p.dx, p.dy - arm), paint);
    }
  }

  void _drawHighlightBracket(Canvas canvas, Offset from, Offset to, Paint paint) {
    final left = math.min(from.dx, to.dx) - 10;
    final right = math.max(from.dx, to.dx) + 10;
    final top = math.min(from.dy, to.dy) - 8;
    final bottom = math.max(from.dy, to.dy) + 8;
    const arm = 10.0;
    canvas.drawLine(Offset(left, top + arm), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + arm, top), paint);
    canvas.drawLine(Offset(right - arm, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + arm), paint);
    canvas.drawLine(Offset(left, bottom - arm), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + arm, bottom), paint);
    canvas.drawLine(Offset(right - arm, bottom), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, bottom - arm), Offset(right, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenRatioMeasurementPainter oldDelegate) =>
      oldDelegate.landmarks != landmarks ||
      oldDelegate.measurements != measurements ||
      oldDelegate.layouts != layouts;
}
