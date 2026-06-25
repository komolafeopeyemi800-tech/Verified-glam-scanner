import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_assets.dart';
import '../../utils/vg_constants.dart';

/// Feature card visual: optional owner PNG, else face silhouette + overlay motif.
class VGFeatureThumbnail extends StatefulWidget {
  final String featureType;
  final double size;
  final String? assetPath;
  final BoxFit fit;
  /// When true, fills parent (grid cards) instead of fixed [size].
  final bool expand;

  const VGFeatureThumbnail({
    super.key,
    required this.featureType,
    this.size = 88,
    this.assetPath,
    this.fit = BoxFit.contain,
    this.expand = false,
  });

  @override
  State<VGFeatureThumbnail> createState() => _VGFeatureThumbnailState();
}

class _VGFeatureThumbnailState extends State<VGFeatureThumbnail> {
  bool? _hasAsset;

  @override
  void initState() {
    super.initState();
    _checkAsset();
  }

  Future<void> _checkAsset() async {
    final path = widget.assetPath ?? featureThumbnailAssetForType(widget.featureType);
    if (path == null) {
      if (mounted) setState(() => _hasAsset = false);
      return;
    }
    try {
      await rootBundle.load(path);
      if (mounted) setState(() => _hasAsset = true);
    } catch (_) {
      if (mounted) setState(() => _hasAsset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAsset == null) {
      return SizedBox(
        width: widget.expand ? double.infinity : widget.size,
        height: widget.expand ? double.infinity : widget.size,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final path = widget.assetPath ?? featureThumbnailAssetForType(widget.featureType);
    if (_hasAsset == true && path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: widget.expand ? double.infinity : widget.size,
          height: widget.expand ? double.infinity : widget.size,
          color: bmLightScaffoldBackgroundColor,
          alignment: Alignment.center,
          child: Image.asset(
            path,
            width: widget.expand ? double.infinity : widget.size,
            height: widget.expand ? double.infinity : widget.size,
            fit: widget.fit,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => SizedBox.expand(
              child: CustomPaint(
                painter: _FeatureThumbnailPainter(featureType: widget.featureType),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: widget.expand ? double.infinity : widget.size,
      height: widget.expand ? double.infinity : widget.size,
      child: CustomPaint(
        painter: _FeatureThumbnailPainter(featureType: widget.featureType),
      ),
    );
  }
}

class _FeatureThumbnailPainter extends CustomPainter {
  final String featureType;

  _FeatureThumbnailPainter({required this.featureType});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = bmLightScaffoldBackgroundColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      bg,
    );

    final cx = size.width / 2;
    final cy = size.height / 2;
    final facePaint = Paint()
      ..color = bmPrimaryColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.52, height: size.height * 0.62),
      facePaint,
    );
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 12, cy - 6), width: 8, height: 5), facePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 12, cy - 6), width: 8, height: 5), facePaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 10), width: 18, height: 8), 0.2, 2.8, false, facePaint);

    final accent = Paint()
      ..color = bmSpecialColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    switch (featureType) {
      case VGFeatureTypes.facialSymmetry:
        _drawSymmetryGrid(canvas, size, accent);
      case VGFeatureTypes.goldenRatio:
        _drawSpiral(canvas, size, accent);
      case VGFeatureTypes.colorAnalysis:
        _drawSwatches(canvas, size);
      case VGFeatureTypes.celebrityLookalike:
        _drawMatchDots(canvas, size, accent);
      case VGFeatureTypes.faceReading:
      case VGFeatureTypes.beautyScoreShowdown:
        _drawRings(canvas, size, accent);
      case VGFeatureTypes.faceBeautyAnalysis:
        _drawMesh(canvas, size, accent);
      case VGFeatureTypes.glowUpGuide:
        _drawCalendar(canvas, size, accent);
      case VGFeatureTypes.beautyTips:
        _drawTipLines(canvas, size, accent);
      case VGFeatureTypes.facialResemblance:
        _drawDualFace(canvas, size, accent);
      default:
        _drawMesh(canvas, size, accent);
    }
  }

  void _drawSymmetryGrid(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, size.height * 0.12), Offset(cx, size.height * 0.88), paint);
    for (final y in [0.28, 0.45, 0.62, 0.78]) {
      canvas.drawLine(Offset(size.width * 0.2, size.height * y), Offset(size.width * 0.8, size.height * y), paint..strokeWidth = 1);
    }
  }

  void _drawSpiral(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path();
    for (var t = 0.0; t < 4 * math.pi; t += 0.15) {
      final r = 4 + t * 3.5;
      final x = cx + r * math.cos(t);
      final y = cy + r * math.sin(t);
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawSwatches(Canvas canvas, Size size) {
    final colors = [bmSpecialColor, bmPrimaryColor, const Color(0xFF5C6B4A)];
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.62, size.height * (0.22 + i * 0.22), 14, 14),
          const Radius.circular(4),
        ),
        Paint()..color = colors[i],
      );
    }
  }

  void _drawMatchDots(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(size.width * 0.72, size.height * (0.25 + i * 0.22)), 5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  void _drawRings(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.32, paint);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.24, paint..color = bmPrimaryColor);
  }

  void _drawMesh(Canvas canvas, Size size, Paint paint) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final pts = [
      Offset(cx, cy - 28),
      Offset(cx - 22, cy - 8),
      Offset(cx + 22, cy - 8),
      Offset(cx - 18, cy + 18),
      Offset(cx + 18, cy + 18),
      Offset(cx, cy + 30),
    ];
    for (var i = 0; i < pts.length; i++) {
      for (var j = i + 1; j < pts.length; j++) {
        if ((i - j).abs() <= 2) canvas.drawLine(pts[i], pts[j], paint..strokeWidth = 1);
      }
    }
    for (final p in pts) {
      canvas.drawCircle(p, 2.5, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  void _drawCalendar(Canvas canvas, Size size, Paint paint) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.58, size.height * 0.2, 22, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(r, paint);
    canvas.drawLine(Offset(size.width * 0.58, size.height * 0.28), Offset(size.width * 0.8, size.height * 0.28), paint);
  }

  void _drawTipLines(Canvas canvas, Size size, Paint paint) {
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.3), Offset(size.width * 0.45, size.height * 0.42), paint);
    canvas.drawLine(Offset(size.width * 0.7, size.height * 0.5), Offset(size.width * 0.5, size.height * 0.55), paint);
  }

  void _drawDualFace(Canvas canvas, Size size, Paint paint) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.35, size.height * 0.5), width: 22, height: 28),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.65, size.height * 0.5), width: 22, height: 28),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FeatureThumbnailPainter oldDelegate) =>
      oldDelegate.featureType != featureType;
}
