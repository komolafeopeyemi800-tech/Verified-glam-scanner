import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import 'vg_web_section.dart';

class VGWebFaqSection extends StatefulWidget {
  final List<VGFaqItem> items;

  const VGWebFaqSection({super.key, required this.items});

  @override
  State<VGWebFaqSection> createState() => _VGWebFaqSectionState();
}

class _VGWebFaqSectionState extends State<VGWebFaqSection> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return VGWebSection(
      background: bmSecondBackgroundColorLight,
      child: Column(
        children: [
          const VGWebSectionTitle(
            title: 'Frequently asked questions',
            subtitle: 'Quick answers for search engines and first-time visitors.',
          ),
          const SizedBox(height: 32),
          ...widget.items.asMap().entries.map((e) {
            final open = _expanded == e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _expanded = open ? null : e.key),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.value.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: appTextColorPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              open ? Icons.remove : Icons.add,
                              color: bmSpecialColor,
                            ),
                          ],
                        ),
                        if (open) ...[
                          const SizedBox(height: 12),
                          Text(
                            e.value.answer,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.65,
                              color: appTextColorSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
