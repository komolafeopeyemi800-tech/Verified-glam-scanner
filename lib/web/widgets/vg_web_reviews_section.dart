import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_section.dart';

class VGWebReviewsSection extends StatelessWidget {
  final List<VGReviewItem> reviews;

  const VGWebReviewsSection({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);

    return VGWebSection(
      background: Colors.white,
      child: Column(
        children: [
          const VGWebSectionTitle(title: 'User reviews'),
          const SizedBox(height: 36),
          if (desktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < reviews.length; i++) ...[
                  if (i > 0) const SizedBox(width: 20),
                  Expanded(child: _ReviewCard(review: reviews[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (final r in reviews) ...[
                  _ReviewCard(review: r),
                  const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final VGReviewItem review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bmSecondBackgroundColorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: appTextColorPrimary),
              ),
              const Spacer(),
              ...List.generate(
                5,
                (_) => const Icon(Icons.star_rounded, color: bmSpecialColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Icon(Icons.format_quote_rounded, color: bmPrimaryColor.withValues(alpha: 0.6), size: 28),
          const SizedBox(height: 4),
          Text(
            review.quote,
            style: const TextStyle(fontSize: 14, height: 1.65, color: appTextColorSecondary),
          ),
        ],
      ),
    );
  }
}
