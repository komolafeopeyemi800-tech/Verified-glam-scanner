import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

class VGIssuePill extends StatelessWidget {
  final String label;
  final String? subtitle;
  final String severity;

  const VGIssuePill({
    super.key,
    required this.label,
    this.subtitle,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _dotColor(severity),
              shape: BoxShape.circle,
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: boldTextStyle(color: appTextColorPrimary, size: 14)),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  4.height,
                  Text(subtitle!, style: secondaryTextStyle(color: appTextColorSecondary, size: 12)),
                ],
              ],
            ),
          ),
          _SeverityBadge(severity: severity),
        ],
      ),
    );
  }

  Color _dotColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFE65100);
      default:
        return bmSpecialColor;
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity.toLowerCase()) {
      'high' => (VGCopy.beautyTipsSeverityHigh, const Color(0xFFC62828)),
      'low' => (VGCopy.beautyTipsSeverityLow, const Color(0xFF2E7D32)),
      _ => (VGCopy.beautyTipsSeverityMedium, const Color(0xFFE65100)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: boldTextStyle(color: color, size: 10)),
    );
  }
}
