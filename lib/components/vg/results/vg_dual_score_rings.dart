import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

/// Dual score rings for attractiveness / showdown on photo hero.
class VGDualScoreRings extends StatelessWidget {
  final String leftLabel;
  final int leftPercent;
  final String rightLabel;
  final int rightPercent;

  const VGDualScoreRings({
    super.key,
    required this.leftLabel,
    required this.leftPercent,
    required this.rightLabel,
    required this.rightPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _ring(leftLabel, leftPercent),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _ring(rightLabel, rightPercent),
          ),
        ),
      ],
    );
  }

  Widget _ring(String label, int percent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                strokeWidth: 5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(bmSpecialColor),
              ),
              Text('$percent%', style: boldTextStyle(color: Colors.white, size: 14)),
            ],
          ),
        ),
        4.height,
        Text(label, style: secondaryTextStyle(color: Colors.white, size: 10), textAlign: TextAlign.center),
      ],
    );
  }
}
