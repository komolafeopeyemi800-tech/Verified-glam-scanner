import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';

/// Circular progress ring with a centered "8.2/10" score (single baseline row).
class VGScoreOutOf10Ring extends StatelessWidget {
  final double score;
  final double size;
  final double scoreFontSize;
  final double suffixFontSize;

  const VGScoreOutOf10Ring({
    super.key,
    required this.score,
    this.size = 84,
    this.scoreFontSize = 22,
    this.suffixFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final display = score == score.roundToDouble()
        ? score.toStringAsFixed(1)
        : score.toStringAsFixed(2);

    return SizedBox(
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
              strokeWidth: 5,
              backgroundColor: bmLightScaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation(bmSpecialColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    display,
                    style: TextStyle(
                      fontSize: scoreFontSize,
                      fontWeight: FontWeight.bold,
                      color: bmSpecialColorDark,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/10',
                    style: TextStyle(
                      fontSize: suffixFontSize,
                      color: appTextColorSecondary,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
