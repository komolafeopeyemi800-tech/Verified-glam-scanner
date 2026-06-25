import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';
import '../vg_scan_photo_image.dart';
import 'vg_subscore_row.dart';

/// Fotor-inspired symmetry metrics summary with Verified Glam styling.
class VGSymmetryMetricsCard extends StatelessWidget {
  final double overallScore;
  final Map<String, dynamic> subscores;
  final String? photoPath;

  const VGSymmetryMetricsCard({
    super.key,
    required this.overallScore,
    required this.subscores,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final descriptor = VGCopy.symmetryDescriptorFor(overallScore);
    final displayScore = overallScore == overallScore.roundToDouble()
        ? overallScore.round().toString()
        : overallScore.toStringAsFixed(1);

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
                    Text(
                      displayScore,
                      style: boldTextStyle(color: bmSpecialColorDark, size: 44),
                    ),
                    Text(
                      descriptor,
                      style: boldTextStyle(color: bmSpecialColor, size: 14),
                    ),
                    2.height,
                    Text(
                      VGCopy.resultSymmetryAttractivenessLabel,
                      style: secondaryTextStyle(color: appTextColorSecondary, size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    VGSubscoreRow(label: VGCopy.subscoreBeauty, percent: _sub('beauty')),
                    VGSubscoreRow(label: VGCopy.subscoreCuteness, percent: _sub('cuteness')),
                    VGSubscoreRow(
                      label: VGCopy.subscoreSkinSmoothness,
                      percent: _sub('skinSmoothness'),
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
                      percent: _sub('handsomeness'),
                    ),
                    VGSubscoreRow(label: VGCopy.resultFaceShape, percent: _sub('faceShape')),
                    VGSubscoreRow(
                      label: VGCopy.subscoreFacialSymmetry,
                      percent: _sub('facialSymmetry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _sub(String key) => VGPayloadValues.asIntOr(subscores[key], 0);
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
