import 'package:flutter/material.dart';

import '../../models/vg_feature_model.dart';
import '../content/vg_tool_landing_content.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_hero_demo.dart';
import 'vg_web_upload_card.dart';

class VGWebHeroSection extends StatelessWidget {
  final VGFeatureModel feature;
  final VGToolLandingContent content;

  const VGWebHeroSection({
    super.key,
    required this.feature,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);
    final pad = VGWebBreakpoints.contentPadding(context);

    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 40, pad, 56),
            child: desktop ? _DesktopHero(feature: feature, content: content) : _MobileHero(feature: feature, content: content),
          ),
        ),
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  final VGFeatureModel feature;
  final VGToolLandingContent content;

  const _DesktopHero({required this.feature, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: VGWebHeroDemo(feature: feature)),
        const SizedBox(width: 48),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.headline,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content.subheadline,
                style: const TextStyle(fontSize: 17, height: 1.65, color: Color(0xFF5A5C5E)),
              ),
              const SizedBox(height: 24),
              VGWebUploadCard(feature: feature, buttonLabel: 'Try it now'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  final VGFeatureModel feature;
  final VGToolLandingContent content;

  const _MobileHero({required this.feature, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content.headline,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, color: Color(0xFF212121)),
        ),
        const SizedBox(height: 12),
        Text(
          content.subheadline,
          style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF5A5C5E)),
        ),
        const SizedBox(height: 24),
        VGWebHeroDemo(feature: feature),
        const SizedBox(height: 24),
        VGWebUploadCard(feature: feature, buttonLabel: 'Try it now'),
      ],
    );
  }
}
