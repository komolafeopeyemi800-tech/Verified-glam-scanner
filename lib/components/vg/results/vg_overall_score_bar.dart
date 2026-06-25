import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

/// Pill progress bar for symmetry / overall percent scores.
class VGOverallScoreBar extends StatelessWidget {
  final String label;
  final int percent;
  final double? score;

  const VGOverallScoreBar({
    super.key,
    required this.label,
    this.percent = 0,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    final value = score ?? percent.toDouble();
    final display = score != null
        ? (score! == score!.roundToDouble()
            ? '${score!.round()}%'
            : '${score!.toStringAsFixed(1)}%')
        : '$percent%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: secondaryTextStyle(size: 11, letterSpacing: 0.6),
          ),
          8.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: bmLightScaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation(bmSpecialColor),
            ),
          ),
          8.height,
          Text(display, style: boldTextStyle(color: bmSpecialColorDark, size: 20)),
        ],
      ),
    );
  }
}
