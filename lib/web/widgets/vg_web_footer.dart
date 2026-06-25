import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import '../../utils/vg_feature_data.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_breakpoints.dart';

class VGWebFooter extends StatelessWidget {
  const VGWebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);
    final tools = getVerifiedGlamFeatures();

    return ColoredBox(
      color: bmSecondBackgroundColorLight,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: VGWebBreakpoints.contentPadding(context),
              vertical: 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: desktop ? 2 : 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('images/verified_glam_logo.png', height: 40),
                              const SizedBox(width: 10),
                              Text(
                                vgAppName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: bmSpecialColorDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'AI beauty analysis with your photo at the center. Upload, analyze, and get personalized insights.',
                            style: TextStyle(color: appTextColorSecondary, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    if (desktop) const SizedBox(width: 48),
                    if (desktop)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Tools', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            ...tools.take(5).map(
                                  (f) => _FooterLink(
                                    label: f.title,
                                    onTap: () => context.go('/${slugForFeatureType(f.featureType)}'),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    if (desktop)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),
                            ...tools.skip(5).map(
                                  (f) => _FooterLink(
                                    label: f.title,
                                    onTap: () => context.go('/${slugForFeatureType(f.featureType)}'),
                                  ),
                                ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (!desktop) ...[
                  const SizedBox(height: 24),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('AI Tools', style: TextStyle(fontWeight: FontWeight.w700)),
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            for (final f in tools)
                              _FooterLink(
                                label: f.title,
                                onTap: () => context.go('/${slugForFeatureType(f.featureType)}'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(color: Color(0xFFE8D4D4)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text('© ${DateTime.now().year} $vgAppName', style: secondaryTextStyle()),
                    _FooterLink(label: 'Pricing', onTap: () => context.go('/pricing')),
                    _FooterLink(label: 'Support', onTap: () {}),
                    _FooterLink(label: vgSupportEmail, onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: bmSpecialColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}

TextStyle secondaryTextStyle() => const TextStyle(color: appTextColorSecondary, fontSize: 13);
