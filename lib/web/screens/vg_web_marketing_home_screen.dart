import 'package:flutter/material.dart';

import '../widgets/vg_marketing_iframe_stub.dart'
    if (dart.library.html) '../widgets/vg_marketing_iframe_web.dart' as marketing_iframe;
import '../widgets/vg_web_header.dart';

/// Homepage at `/` — Flutter header (mega menu) + marketing content iframe.
class VGWebMarketingHomeScreen extends StatelessWidget {
  const VGWebMarketingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const VGWebHeader(),
      body: SizedBox.expand(
        child: marketing_iframe.buildMarketingHomeIframeBody(),
      ),
    );
  }
}
