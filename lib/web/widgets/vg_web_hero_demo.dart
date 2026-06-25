import 'package:flutter/material.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';

/// Composed hero visual — feature thumbnail with scan overlay (no competitor assets).
class VGWebHeroDemo extends StatelessWidget {
  final VGFeatureModel feature;

  const VGWebHeroDemo({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final asset = feature.thumbnailAsset ?? 'images/vg/upload_selfie_portrait.png';

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bmSpecialColor.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    bmSpecialColorDark.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _ScanGridPainter()),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _FeatureChips(feature: feature),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChips extends StatelessWidget {
  final VGFeatureModel feature;

  const _FeatureChips({required this.feature});

  @override
  Widget build(BuildContext context) {
    final labels = _chipsForFeature(feature.featureType);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: i == 0 ? bmSpecialColor : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: i == 0 ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: i == 0 ? Colors.white : bmSpecialColorDark,
              ),
            ),
          ),
      ],
    );
  }

  List<String> _chipsForFeature(String type) {
    switch (type) {
      case 'FACIAL_SYMMETRY':
        return ['Symmetry', 'Midline', 'Balance', 'Eyes'];
      case 'COLOR_ANALYSIS':
        return ['Spring', 'Summer', 'Autumn', 'Winter'];
      case 'GOLDEN_RATIO':
        return ['Phi map', 'Thirds', 'Harmony', 'Ratios'];
      case 'CELEBRITY_LOOKALIKE':
        return ['Match %', 'Eyes', 'Jawline', 'Smile'];
      default:
        return ['AI scan', 'Features', 'Score', 'Tips'];
    }
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.12, size.width * 0.64, size.height * 0.62),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, paint);

    final cx = size.width * 0.5;
    canvas.drawLine(Offset(cx, size.height * 0.12), Offset(cx, size.height * 0.74), paint);

    final corner = Paint()
      ..color = bmSpecialColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const len = 18.0;
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    canvas.drawLine(Offset(left, top), Offset(left + len, top), corner);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), corner);
    canvas.drawLine(Offset(right, top), Offset(right - len, top), corner);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), corner);
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), corner);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), corner);
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), corner);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
