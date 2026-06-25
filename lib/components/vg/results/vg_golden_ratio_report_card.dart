import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';
import 'vg_score_out_of_10_ring.dart';

/// Fotor-style Golden Ratio Face Report with per-metric scores out of 20.
class VGGoldenRatioReportCard extends StatelessWidget {
  final double overallScore;
  final int goldenRatioIndex;
  final String ratingLabel;
  final List<Map<String, dynamic>> measurements;
  final double idealPhi;

  const VGGoldenRatioReportCard({
    super.key,
    required this.overallScore,
    required this.goldenRatioIndex,
    required this.ratingLabel,
    required this.measurements,
    this.idealPhi = 1.618,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
          Text(
            VGCopy.goldenRatioReportTitle,
            style: boldTextStyle(color: bmSpecialColorDark, size: 18),
          ),
          4.height,
          Text(
            VGCopy.goldenRatioPhiExplanation(idealPhi),
            style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.35),
          ),
          14.height,
          Row(
            children: [
              VGScoreOutOf10Ring(score: overallScore, scoreFontSize: 20, suffixFontSize: 11),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VGCopy.goldenRatioIndexLabel(goldenRatioIndex),
                      style: boldTextStyle(color: bmSpecialColorDark, size: 14),
                    ),
                    6.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bmSpecialColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        ratingLabel,
                        style: boldTextStyle(color: bmSpecialColorDark, size: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          ...measurements.map(_metricRow),
          8.height,
          Text(
            VGCopy.goldenRatioTotalScore(goldenRatioIndex),
            style: boldTextStyle(color: bmSpecialColorDark, size: 13),
          ),
          8.height,
          Text(
            VGCopy.goldenRatioDisclaimer,
            style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(Map<String, dynamic> m) {
    final pass = m['pass'] == true;
    final barColor = pass ? const Color(0xFF2E7D32) : const Color(0xFFE53935);
    final ratio = VGPayloadValues.asDoubleOr(m['ratio'], 0);
    final delta = VGPayloadValues.asDoubleOr(m['delta'], 0);
    final score = VGPayloadValues.asIntOr(m['scoreOutOf20'], 0);
    final name = m['name'] as String? ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: bmLightScaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: primaryTextStyle(size: 12)),
                4.height,
                Text(
                  '${ratio.toStringAsFixed(3)} ${VGCopy.goldenRatioDeltaLabel(delta)}',
                  style: secondaryTextStyle(size: 11, color: bmSpecialColor),
                ),
              ],
            ),
          ),
          Text(
            VGCopy.goldenRatioMetricScore(score),
            style: boldTextStyle(color: bmSpecialColorDark, size: 12),
          ),
        ],
      ),
    );
  }
}
