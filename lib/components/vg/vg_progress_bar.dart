import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGProgressBar extends StatelessWidget {
  final double progress;

  const VGProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: 6,
        backgroundColor: bmLightScaffoldBackgroundColor,
        valueColor: const AlwaysStoppedAnimation<Color>(bmSpecialColor),
      ),
    );
  }
}
