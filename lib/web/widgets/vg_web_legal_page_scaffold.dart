import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/BMColors.dart';
import '../content/vg_legal_content.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_footer.dart';
import 'vg_web_header.dart';

class VGWebLegalPageScaffold extends StatelessWidget {
  final VGLegalPageContent content;

  const VGWebLegalPageScaffold({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final pad = VGWebBreakpoints.contentPadding(context);

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: const VGWebHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, 40, pad, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.h1,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: bmSpecialColorDark,
                        ),
                      ),
                      if (content.metaLine != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          content.metaLine!,
                          style: const TextStyle(color: appTextColorSecondary, fontSize: 15),
                        ),
                      ],
                      const SizedBox(height: 28),
                      ...content.blocks.map((b) => _LegalBlockWidget(block: b, context: context)),
                    ],
                  ),
                ),
              ),
            ),
            const VGWebFooter(),
          ],
        ),
      ),
    );
  }
}

class _LegalBlockWidget extends StatelessWidget {
  final VGLegalBlock block;
  final BuildContext context;

  const _LegalBlockWidget({required this.block, required this.context});

  @override
  Widget build(BuildContext _) {
    return switch (block) {
      VGLegalHeading(:final text) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: bmSpecialColorDark,
            ),
          ),
        ),
      VGLegalParagraph(:final text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _LegalText(text: text, context: context),
        ),
      VGLegalBulletList(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(color: bmSpecialColor, fontWeight: FontWeight.w700)),
                        Expanded(child: _LegalText(text: item, context: context)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      VGLegalNumberedList(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ', style: const TextStyle(color: bmSpecialColor, fontWeight: FontWeight.w700)),
                      Expanded(child: _LegalText(text: items[i], context: context)),
                    ],
                  ),
                ),
            ],
          ),
        ),
    };
  }
}

class _LegalText extends StatelessWidget {
  final String text;
  final BuildContext context;

  const _LegalText({required this.text, required this.context});

  @override
  Widget build(BuildContext context) {
    if (text.contains('Privacy Policy') && !text.contains('support@')) {
      final parts = text.split('Privacy Policy');
      return Wrap(
        children: [
          Text(parts.first, style: const TextStyle(height: 1.65, color: appTextColorSecondary)),
          InkWell(
            onTap: () => context.go('/privacy'),
            child: const Text(
              'Privacy Policy',
              style: TextStyle(color: bmSpecialColor, fontWeight: FontWeight.w600, height: 1.65),
            ),
          ),
          if (parts.length > 1)
            Text(parts[1], style: const TextStyle(height: 1.65, color: appTextColorSecondary)),
        ],
      );
    }
    return Text(text, style: const TextStyle(height: 1.65, color: appTextColorSecondary, fontSize: 15));
  }
}
