import 'package:flutter/material.dart';

import '../content/vg_legal_content.dart';
import '../vg_web_seo.dart';
import '../vg_web_seo_schema.dart';
import '../widgets/vg_web_legal_page_scaffold.dart';

class VGWebTermsScreen extends StatefulWidget {
  const VGWebTermsScreen({super.key});

  @override
  State<VGWebTermsScreen> createState() => _VGWebTermsScreenState();
}

class _VGWebTermsScreenState extends State<VGWebTermsScreen> {
  @override
  void initState() {
    super.initState();
    final c = VGLegalPages.terms;
    vgWebSetPageMeta(
      title: c.pageTitle,
      description: c.metaDescription,
      canonicalPath: c.canonicalPath,
      jsonLd: vgSeoWebPageJsonLd(name: 'Terms of Use', description: c.metaDescription, path: c.canonicalPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VGWebLegalPageScaffold(content: VGLegalPages.terms);
  }
}
