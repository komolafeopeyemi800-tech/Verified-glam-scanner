import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../vg_web_breakpoints.dart';

/// Shared horizontal padding + max width for SaaS marketing sections.
class VGWebSection extends StatelessWidget {
  final Widget child;
  final Color? background;
  final EdgeInsetsGeometry? padding;

  const VGWebSection({
    super.key,
    required this.child,
    this.background,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        EdgeInsets.symmetric(
          horizontal: VGWebBreakpoints.contentPadding(context),
          vertical: 56,
        );

    return ColoredBox(
      color: background ?? Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
          child: Padding(padding: pad, child: child),
        ),
      ),
    );
  }
}

class VGWebSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign align;

  const VGWebSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          align == TextAlign.center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: TextStyle(
            fontSize: VGWebBreakpoints.isDesktop(context) ? 32 : 26,
            fontWeight: FontWeight.w700,
            color: appTextColorPrimary,
            height: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: align,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: appTextColorSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
