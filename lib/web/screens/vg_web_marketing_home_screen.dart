import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_home_landing_content.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_marketing_iframe_stub.dart'
    if (dart.library.html) '../widgets/vg_marketing_iframe_web.dart' as marketing_iframe;
import '../widgets/vg_web_header.dart';

/// Homepage at `/` — Flutter header (mega menu) + original static HTML via iframe.
class VGWebMarketingHomeScreen extends StatefulWidget {
  const VGWebMarketingHomeScreen({super.key});

  @override
  State<VGWebMarketingHomeScreen> createState() => _VGWebMarketingHomeScreenState();
}

class _VGWebMarketingHomeScreenState extends State<VGWebMarketingHomeScreen> {
  @override
  void initState() {
    super.initState();
    vgWebSetPageMeta(
      title: VGHomeLandingContent.pageTitle,
      description: VGHomeLandingContent.metaDescription,
      canonicalPath: '/',
      jsonLd: vgSeoHomeJsonLd(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: const VGWebHeader(),
      body: SizedBox.expand(
        child: marketing_iframe.buildMarketingHomeIframeBody(),
      ),
    );
  }
}
