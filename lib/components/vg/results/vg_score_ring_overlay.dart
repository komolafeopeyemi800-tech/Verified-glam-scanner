import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

class VGScoreRingOverlay extends StatelessWidget {
  final String label;
  final int percent;
  final double size;
  final Alignment alignment;

  const VGScoreRingOverlay({
    super.key,
    required this.label,
    required this.percent,
    this.size = 72,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
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
            Text(label, style: secondaryTextStyle(color: Colors.white, size: 10)),
          ],
        ),
      ),
    );
  }
}
