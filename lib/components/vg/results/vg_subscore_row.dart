import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

class VGSubscoreRow extends StatelessWidget {
  final String label;
  final int percent;

  const VGSubscoreRow({super.key, required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label, style: primaryTextStyle(color: appTextColorPrimary, size: 13)),
              ),
              Text('$percent', style: boldTextStyle(color: bmSpecialColorDark, size: 14)),
            ],
          ),
          6.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: bmLightScaffoldBackgroundColor,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFC5A373)),
            ),
          ),
        ],
      ),
    );
  }
}
