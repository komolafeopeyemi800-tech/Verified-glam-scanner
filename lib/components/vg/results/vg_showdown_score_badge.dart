import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

/// Circular beauty score badge with progress ring (top-left on hero).
class VGShowdownScoreBadge extends StatelessWidget {
  final double score;

  const VGShowdownScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final display = score == score.roundToDouble()
        ? score.toStringAsFixed(1)
        : score.toStringAsFixed(2);
    const size = 88.0;

    return Positioned(
      top: 10,
      left: 10,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: (score / 10).clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF7A)),
              ),
            ),
            Container(
              width: size - 12,
              height: size - 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF4CAF7A).withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    VGCopy.showdownBeautyScore,
                    style: secondaryTextStyle(size: 7, color: bmSpecialColorDark),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    display,
                    style: boldTextStyle(color: bmSpecialColorDark, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
