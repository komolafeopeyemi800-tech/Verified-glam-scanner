import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../vg_scan_photo_image.dart';

/// Beauty Tips skin check: findings grouped with community-style tip cards.
class VGBeautyTipsReportCard extends StatelessWidget {
  final List<Map<String, dynamic>> findings;
  final List<Map<String, dynamic>> tips;
  final String summary;
  final String globalDisclaimer;
  final String? photoPath;

  const VGBeautyTipsReportCard({
    super.key,
    required this.findings,
    required this.tips,
    required this.summary,
    required this.globalDisclaimer,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(photoPath: photoPath),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VGCopy.beautyTipsTitle,
                      style: boldTextStyle(color: bmSpecialColorDark, size: 16),
                    ),
                    6.height,
                    Text(
                      summary,
                      style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          14.height,
          Text(
            VGCopy.beautyTipsSummaryTitle,
            style: boldTextStyle(color: bmSpecialColor, size: 13),
          ),
          10.height,
          ...findings.map((finding) => _FindingSection(
                finding: finding,
                tips: _tipsForFinding(finding, tips),
              )),
          12.height,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bmSpecialColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VGCopy.beautyTipsNotMedicalNotice,
                  style: boldTextStyle(color: bmSpecialColorDark, size: 10),
                ),
                6.height,
                Text(
                  globalDisclaimer,
                  style: secondaryTextStyle(color: appTextColorSecondary, size: 9, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _tipsForFinding(
    Map<String, dynamic> finding,
    List<Map<String, dynamic>> allTips,
  ) {
    final categoryId = finding['categoryId'] as String? ?? '';
    return allTips.where((t) => t['categoryId'] == categoryId).toList();
  }
}

class _FindingSection extends StatelessWidget {
  final Map<String, dynamic> finding;
  final List<Map<String, dynamic>> tips;

  const _FindingSection({required this.finding, required this.tips});

  @override
  Widget build(BuildContext context) {
    final categoryName = finding['categoryName'] as String? ?? '';
    final severity = finding['severity'] as String? ?? 'medium';
    final spotCount = (finding['spotCount'] as num?)?.round() ?? 1;
    final title = spotCount > 1
        ? '$categoryName · ${VGCopy.beautyTipsAreasLabel(spotCount)}'
        : categoryName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: boldTextStyle(color: bmSpecialColorDark, size: 12),
                ),
              ),
              _SeverityChip(severity: severity),
            ],
          ),
          8.height,
          ...tips.map((t) => _TipCard(tip: t)),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String severity;

  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      'high' => (VGCopy.beautyTipsSeverityHigh, const Color(0xFFC62828)),
      'low' => (VGCopy.beautyTipsSeverityLow, const Color(0xFF2E7D32)),
      _ => (VGCopy.beautyTipsSeverityMedium, const Color(0xFFE65100)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(label, style: boldTextStyle(color: color, size: 9)),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Map<String, dynamic> tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final title = tip['title'] as String? ?? '';
    final body = tip['body'] as String? ?? '';
    final disclaimer =
        tip['disclaimer'] as String? ?? VGCopy.beautyTipsTipDisclaimer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bmPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 11)),
          if (title.isNotEmpty) 4.height,
          Text(
            body,
            style: secondaryTextStyle(color: appTextColorSecondary, size: 10, height: 1.4),
          ),
          6.height,
          Text(
            disclaimer,
            style: secondaryTextStyle(
              color: appTextColorSecondary.withValues(alpha: 0.85),
              size: 8,
              height: 1.3,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? photoPath;

  const _Thumbnail({this.photoPath});

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 52,
        height: 52,
        child: VGScanPhotoImage(
          photoPath: photoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
