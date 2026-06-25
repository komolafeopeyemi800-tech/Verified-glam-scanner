import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGRecommendationCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String> items;

  const VGRecommendationCard({
    super.key,
    required this.title,
    this.subtitle,
    this.items = const [],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: bmSpecialColor, size: 20),
              8.width,
              Expanded(child: Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 15))),
            ],
          ),
          if (subtitle != null) ...[
            6.height,
            Text(subtitle!, style: primaryTextStyle(color: appTextColorPrimary, size: 14)),
          ],
          if (items.isNotEmpty) ...[
            10.height,
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: primaryTextStyle(color: bmSpecialColor, size: 14)),
                    Expanded(child: Text(item, style: primaryTextStyle(size: 14))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
