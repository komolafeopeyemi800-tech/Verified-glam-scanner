import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';

class VGMatchRow extends StatelessWidget {
  final String name;
  final int percent;
  final List<String> traits;

  const VGMatchRow({
    super.key,
    required this.name,
    required this.percent,
    required this.traits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bmLightScaffoldBackgroundColor,
            child: Text(name.isNotEmpty ? name[0] : '?', style: boldTextStyle(color: bmSpecialColor)),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: boldTextStyle(size: 15)),
                4.height,
                Text(traits.join(' · '), style: secondaryTextStyle(size: 12), maxLines: 2),
              ],
            ),
          ),
          Text('$percent%', style: boldTextStyle(color: bmSpecialColor, size: 18)),
        ],
      ),
    );
  }
}
