import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class VGFaceComparisonScoreBadge extends StatelessWidget {
  final String scoreLabel;
  final int similarity;

  const VGFaceComparisonScoreBadge({
    super.key,
    required this.scoreLabel,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF7A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF7A).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '$scoreLabel: $similarity/100',
        style: boldTextStyle(color: Colors.white, size: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
