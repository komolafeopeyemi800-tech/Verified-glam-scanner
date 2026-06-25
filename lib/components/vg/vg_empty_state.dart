import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';
import 'vg_pill_button.dart';

class VGEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const VGEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: bmLightScaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: bmSpecialColor),
          ),
          24.height,
          Text(title, style: boldTextStyle(color: appTextColorPrimary, size: 20), textAlign: TextAlign.center),
          12.height,
          Text(subtitle, style: secondaryTextStyle(color: appTextColorSecondary), textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            28.height,
            VGPillButton(label: actionLabel!, onTap: onAction, width: context.width() * 0.7),
          ],
        ],
      ),
    );
  }
}
