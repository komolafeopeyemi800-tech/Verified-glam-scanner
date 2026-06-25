import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';
import '../vg_scan_photo_image.dart';
import 'vg_score_out_of_10_ring.dart';
import 'vg_subscore_row.dart';

/// Attractiveness Test summary: overall /10 score, facial age, appearance + trait bars.
class VGAttractivenessReportCard extends StatelessWidget {
  final double overallScore;
  final String tierLabel;
  final String subtitle;
  final int facialAge;
  final Map<String, dynamic> appearanceScores;
  final Map<String, dynamic> traitScores;
  final String? photoPath;
  final bool scoresFinalized;

  const VGAttractivenessReportCard({
    super.key,
    required this.overallScore,
    required this.tierLabel,
    required this.subtitle,
    required this.facialAge,
    required this.appearanceScores,
    required this.traitScores,
    this.photoPath,
    this.scoresFinalized = false,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumbnail(photoPath: photoPath),
              14.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VGScoreOutOf10Ring(score: overallScore),
                        10.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tierLabel,
                                style: boldTextStyle(color: bmSpecialColor, size: 15),
                              ),
                              2.height,
                              Text(
                                VGCopy.attractivenessScoreLabel,
                                style: secondaryTextStyle(color: appTextColorSecondary, size: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    6.height,
                    Text(
                      subtitle,
                      style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.35),
                    ),
                    8.height,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bmSpecialColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        VGCopy.attractivenessFacialAge(facialAge),
                        style: boldTextStyle(color: bmSpecialColorDark, size: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          18.height,
          Text(
            VGCopy.attractivenessAppearanceSection,
            style: boldTextStyle(color: bmSpecialColorDark, size: 14),
          ),
          10.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    VGSubscoreRow(
                      label: VGCopy.subscoreBeauty,
                      percent: _appearance('beauty'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreCuteness,
                      percent: _appearance('cuteness'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreSkinSmoothness,
                      percent: _appearance('skinSmoothness'),
                    ),
                  ],
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  children: [
                    VGSubscoreRow(
                      label: VGCopy.subscoreHandsomeness,
                      percent: _appearance('handsomeness'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreFaceShape,
                      percent: _appearance('faceShape'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreFacialSymmetry,
                      percent: _appearance('facialSymmetry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          8.height,
          Text(
            VGCopy.attractivenessTraitsSection,
            style: boldTextStyle(color: bmSpecialColorDark, size: 14),
          ),
          10.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    VGSubscoreRow(
                      label: VGCopy.subscoreFunFactor,
                      percent: _trait('funFactor'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreIntelligence,
                      percent: _trait('intelligence'),
                    ),
                  ],
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  children: [
                    VGSubscoreRow(
                      label: VGCopy.subscoreConfidence,
                      percent: _trait('confidence'),
                    ),
                    VGSubscoreRow(
                      label: VGCopy.subscoreCredibility,
                      percent: _trait('credibility'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          8.height,
          Text(
            VGCopy.attractivenessDisclaimer,
            style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  int _appearance(String key) => scoresFinalized
      ? VGPayloadValues.asIntOr(appearanceScores[key], 80)
      : VGPayloadValues.normalizePercent(appearanceScores[key], fallback: 80);

  int _trait(String key) => scoresFinalized
      ? VGPayloadValues.asIntOr(traitScores[key], 75)
      : VGPayloadValues.normalizePercent(traitScores[key], fallback: 75);
}

class _Thumbnail extends StatelessWidget {
  final String? photoPath;

  const _Thumbnail({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = vgPortraitSizeForWidth(w * 0.22);

    final image = VGScanPhotoImage(
      photoPath: photoPath,
      fit: BoxFit.cover,
      placeholder: Container(
        color: bmLightScaffoldBackgroundColor,
        child: Icon(Icons.face_outlined, color: bmPrimaryColor.withValues(alpha: 0.4)),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: size.width, height: size.height, child: image),
    );
  }
}
