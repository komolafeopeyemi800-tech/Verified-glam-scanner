import 'package:flutter/material.dart';

import '../content/vg_legal_content.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_web_legal_page_scaffold.dart';

class VGWebPrivacyScreen extends StatefulWidget {
  const VGWebPrivacyScreen({super.key});

  @override
  State<VGWebPrivacyScreen> createState() => _VGWebPrivacyScreenState();
}

class _VGWebPrivacyScreenState extends State<VGWebPrivacyScreen> {
  @override
  void initState() {
    super.initState();
    final c = VGLegalPages.privacy;
    vgWebSetPageMeta(
      title: c.pageTitle,
      description: c.metaDescription,
      canonicalPath: c.canonicalPath,
      jsonLd: vgSeoWebPageJsonLd(name: 'Privacy Policy', description: c.metaDescription, path: c.canonicalPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VGWebLegalPageScaffold(content: VGLegalPages.privacy);
  }
}
