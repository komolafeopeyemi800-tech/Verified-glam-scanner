import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

class VGCalloutLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final Alignment alignment;

  const VGCalloutLabel({
    super.key,
    required this.label,
    required this.value,
    required this.accentColor,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          6.width,
          Flexible(
            child: Text(
              '$label: $value',
              style: boldTextStyle(color: bmSpecialColorDark, size: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
