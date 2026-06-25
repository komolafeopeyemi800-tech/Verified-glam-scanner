import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_feature_data.dart';
import '../vg_feature_slugs.dart';
import 'vg_web_section.dart';

class VGWebToolsGridSection extends StatelessWidget {
  final String? currentSlug;

  const VGWebToolsGridSection({super.key, this.currentSlug});

  @override
  Widget build(BuildContext context) {
    final tools = getVerifiedGlamFeatures();

    return VGWebSection(
      background: Colors.white,
      child: Column(
        children: [
          const VGWebSectionTitle(
            title: 'All AI beauty tools',
            subtitle: 'Explore every Verified Glam analysis — each with its own landing page and upload flow.',
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cols = w >= 1000 ? 4 : (w >= 640 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: cols == 1 ? 2.8 : 0.92,
                ),
                itemCount: tools.length,
                itemBuilder: (context, i) => _ToolCard(
                  feature: tools[i],
                  isCurrent: slugForFeatureType(tools[i].featureType) == currentSlug,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final VGFeatureModel feature;
  final bool isCurrent;

  const _ToolCard({required this.feature, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final slug = slugForFeatureType(feature.featureType);
    final thumb = feature.thumbnailAsset;

    return Material(
      color: isCurrent ? bmLightScaffoldBackgroundColor : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.go('/$slug'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.25),
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumb != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(thumb, fit: BoxFit.cover),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: appTextColorPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, height: 1.45, color: appTextColorSecondary),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Try it now →',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: bmSpecialColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
