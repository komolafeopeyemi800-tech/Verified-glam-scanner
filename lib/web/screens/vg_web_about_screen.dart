import 'package:flutter/material.dart';

import '../content/vg_legal_content.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_web_legal_page_scaffold.dart';

class VGWebAboutScreen extends StatefulWidget {
  const VGWebAboutScreen({super.key});

  @override
  State<VGWebAboutScreen> createState() => _VGWebAboutScreenState();
}

class _VGWebAboutScreenState extends State<VGWebAboutScreen> {
  @override
  void initState() {
    super.initState();
    final c = VGLegalPages.about;
    vgWebSetPageMeta(
      title: c.pageTitle,
      description: c.metaDescription,
      canonicalPath: c.canonicalPath,
      jsonLd: vgSeoWebPageJsonLd(name: 'About Us', description: c.metaDescription, path: c.canonicalPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VGWebLegalPageScaffold(content: VGLegalPages.about);
  }
}
