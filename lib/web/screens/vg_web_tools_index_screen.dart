import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_feature_data.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_web_footer.dart';
import '../widgets/vg_web_header.dart';
import '../widgets/vg_web_section.dart';
import '../widgets/vg_web_tools_grid_section.dart';

/// Directory of per-tool SaaS landing pages (not the main marketing homepage).
class VGWebToolsIndexScreen extends StatefulWidget {
  const VGWebToolsIndexScreen({super.key});

  @override
  State<VGWebToolsIndexScreen> createState() => _VGWebToolsIndexScreenState();
}

class _VGWebToolsIndexScreenState extends State<VGWebToolsIndexScreen> {
  static const _title = 'AI Beauty Tools — Verified Glam Scanner';
  static const _description =
      'Browse AI beauty scan tools: face beauty analysis, symmetry, celebrity look-alike, seasonal color palette, and more.';

  @override
  void initState() {
    super.initState();
    vgWebSetPageMeta(
      title: _title,
      description: _description,
      canonicalPath: '/tools',
      jsonLd: vgSeoToolsIndexJsonLd(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = getFeaturedGlamFeatures();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const VGWebHeader(toolsIndexActive: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VGWebSection(
              background: bmLightScaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VGWebSectionTitle(
                    title: 'AI beauty tools',
                    subtitle: 'Each scan has its own page — upload a photo and get results on the web.',
                    align: TextAlign.start,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: featured
                        .map(
                          (f) => ActionChip(
                            label: Text(f.title),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.4)),
                            onPressed: () => context.go('/${slugForFeatureType(f.featureType)}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const VGWebToolsGridSection(),
            const VGWebFooter(),
          ],
        ),
      ),
    );
  }
}
