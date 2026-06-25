import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import 'vg_web_section.dart';

class VGWebWhyChooseSection extends StatelessWidget {
  final List<VGWhyChooseItem> items;

  const VGWebWhyChooseSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return VGWebSection(
      background: bmSecondBackgroundColorLight,
      child: Column(
        children: [
          const VGWebSectionTitle(
            title: 'Why choose Verified Glam',
            subtitle: 'Professional AI analysis with your photo at the center — built for web and mobile.',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final cross = constraints.maxWidth >= 900 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: cross == 2 ? 1.55 : 1.35,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => _WhyCard(index: i + 1, item: items[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  final int index;
  final VGWhyChooseItem item;

  const _WhyCard({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: bmPrimaryColor.withValues(alpha: 0.35),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: appTextColorPrimary),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              item.body,
              style: const TextStyle(fontSize: 14, height: 1.6, color: appTextColorSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
