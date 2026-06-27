import 'package:flutter/material.dart';

import '../content/vg_tool_landing_content.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_web_faq_section.dart';
import '../widgets/vg_web_footer.dart';
import '../widgets/vg_web_header.dart';
import '../widgets/vg_web_hero_section.dart';
import '../widgets/vg_web_how_to_section.dart';
import '../widgets/vg_web_reviews_section.dart';
import '../widgets/vg_web_showcase_section.dart';
import '../widgets/vg_web_tools_grid_section.dart';
import '../widgets/vg_web_why_choose_section.dart';

/// SEO landing page for a single AI beauty tool (web SaaS layout).
class VGToolLandingScreen extends StatefulWidget {
  final String slug;

  const VGToolLandingScreen({super.key, required this.slug});

  @override
  State<VGToolLandingScreen> createState() => _VGToolLandingScreenState();
}

class _VGToolLandingScreenState extends State<VGToolLandingScreen> {
  @override
  void initState() {
    super.initState();
    final content = landingContentForSlug(widget.slug);
    if (content != null) {
      vgWebSetPageMeta(
        title: content.pageTitle,
        description: content.metaDescription,
        canonicalPath: '/${content.slug}',
        jsonLd: vgSeoToolPageJsonLd(content),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feature = featureForSlug(widget.slug);
    final content = landingContentForSlug(widget.slug);

    if (feature == null || content == null) {
      return const Scaffold(body: Center(child: Text('Tool not found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: VGWebHeader(activeSlug: widget.slug),
      body: SingleChildScrollView(
        child: Column(
          children: [
            VGWebHeroSection(feature: feature, content: content),
            VGWebWhyChooseSection(items: content.whyChoose),
            VGWebShowcaseSection(
              title: content.showcaseTitle,
              subtitle: content.showcaseSubtitle,
              items: content.showcase,
            ),
            VGWebHowToSection(steps: content.howTo),
            VGWebToolsGridSection(currentSlug: widget.slug),
            VGWebReviewsSection(reviews: content.reviews),
            VGWebFaqSection(items: content.faqs),
            const VGWebFooter(),
          ],
        ),
      ),
    );
  }
}
