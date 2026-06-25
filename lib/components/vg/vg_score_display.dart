import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGScoreDisplay extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const VGScoreDisplay({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(label, style: secondaryTextStyle(color: appTextColorSecondary)),
          12.height,
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 88,
                width: 88,
                child: CircularProgressIndicator(
                  value: _progressValue(),
                  strokeWidth: 6,
                  backgroundColor: bmLightScaffoldBackgroundColor,
                  valueColor: AlwaysStoppedAnimation(bmSpecialColor),
                ),
              ),
              Column(
                children: [
                  Text(value, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
                  if (suffix != null) Text(suffix!, style: secondaryTextStyle(size: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  double? _progressValue() {
    final match = RegExp(r'([\d.]+)').firstMatch(value);
    if (match == null) return null;
    final n = double.tryParse(match.group(1)!);
    if (n == null) return null;
    if (value.contains('%')) return (n / 100).clamp(0.0, 1.0);
    if (value.contains('/10')) return (n / 10).clamp(0.0, 1.0);
    return null;
  }
}
