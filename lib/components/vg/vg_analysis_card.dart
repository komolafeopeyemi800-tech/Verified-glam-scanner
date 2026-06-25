import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGAnalysisCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData? icon;

  const VGAnalysisCard({
    super.key,
    required this.title,
    required this.body,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: bmSpecialColor, size: 22),
            12.width,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 15)),
                6.height,
                Text(body, style: primaryTextStyle(color: appTextColorPrimary, size: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
