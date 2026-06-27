import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../vg_web_breakpoints.dart';

/// Centered desktop page chrome inside the SaaS shell (no mobile burgundy app bar).
class VGWebPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final String? backLabel;
  final Widget child;
  final Widget? trailing;

  const VGWebPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backLabel,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final pad = VGWebBreakpoints.contentPadding(context);
    final compact = VGWebBreakpoints.isCompact(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        pad,
        VGWebBreakpoints.isPhone(context) ? 20 : 28,
        pad,
        VGWebBreakpoints.isPhone(context) ? 28 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onBack != null) ...[
                TextButton.icon(
                  onPressed: onBack,
                  style: TextButton.styleFrom(
                    foregroundColor: bmSpecialColor,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(backLabel ?? 'Back'),
                ),
                const SizedBox(height: 8),
              ],
              if (compact && trailing != null) ...[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: VGWebBreakpoints.isPhone(context) ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    color: bmSpecialColorDark,
                    height: 1.15,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: appTextColorSecondary),
                  ),
                ],
                const SizedBox(height: 12),
                trailing!,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: bmSpecialColorDark,
                              height: 1.15,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle!,
                              style: const TextStyle(fontSize: 15, height: 1.5, color: appTextColorSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded card used across desktop web panels.
class VGWebDesktopCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const VGWebDesktopCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.22)),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: card,
      ),
    );
  }
}
