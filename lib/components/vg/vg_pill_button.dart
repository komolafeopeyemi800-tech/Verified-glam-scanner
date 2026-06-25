import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/BMColors.dart';

class VGPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool outline;
  final double? width;

  const VGPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.outline = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final fill = outline ? Colors.transparent : bmSpecialColor;
    final textColor = outline ? bmSpecialColor : Colors.white;
    final border = outline ? Border.all(color: bmSpecialColor) : null;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: enabled ? fill : bmGreyColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: width ?? double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: enabled ? border : null,
            ),
            child: Text(label, style: boldTextStyle(color: textColor, size: 16)),
          ),
        ),
      ),
    );
  }
}
