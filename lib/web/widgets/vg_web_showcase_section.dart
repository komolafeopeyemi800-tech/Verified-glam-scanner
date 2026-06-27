import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_section.dart';

class VGWebShowcaseSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<VGShowcaseItem> items;

  const VGWebShowcaseSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return VGWebSection(
      background: Colors.white,
      child: Column(
        children: [
          VGWebSectionTitle(title: title, subtitle: subtitle),
          const SizedBox(height: 40),
          ...items.asMap().entries.map((e) {
            final reverse = e.key.isOdd;
            return Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: _ShowcaseRow(item: e.value, imageOnRight: !reverse),
            );
          }),
        ],
      ),
    );
  }
}

class _ShowcaseRow extends StatelessWidget {
  final VGShowcaseItem item;
  final bool imageOnRight;

  const _ShowcaseRow({required this.item, required this.imageOnRight});

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.asset(
          item.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: bmLightScaffoldBackgroundColor,
            child: const Icon(Icons.image_outlined, size: 48, color: bmPrimaryColor),
          ),
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: appTextColorPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          item.body,
          style: const TextStyle(fontSize: 15, height: 1.65, color: appTextColorSecondary),
        ),
      ],
    );

    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [image, const SizedBox(height: 20), text],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: imageOnRight
          ? [Expanded(child: text), const SizedBox(width: 40), Expanded(child: image)]
          : [Expanded(child: image), const SizedBox(width: 40), Expanded(child: text)],
    );
  }
}
