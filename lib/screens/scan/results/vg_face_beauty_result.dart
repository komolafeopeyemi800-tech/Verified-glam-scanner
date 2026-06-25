import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/results/vg_beauty_annotation_overlay.dart';
import '../../../components/vg/results/vg_beauty_guide_overlay.dart';
import '../../../components/vg/results/vg_beauty_report_card.dart';
import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';

class VGFaceBeautyResult extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGFaceBeautyResult({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = result.payload;
    final guides = (p['guides'] as Map<String, dynamic>?) ?? {};
    final annotations = (p['annotations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final subscores = VGPayloadValues.asMap(p['subscores']);
    final beautyScore = VGPayloadValues.displayPercent(p, p['beautyScore'], fallback: 78);

    return VGResultScaffold(
      result: result,
      feature: feature,
      hero: VGFacePhotoHero(
        photoPath: result.photoPath,
        passport: true,
        overlay: Stack(
          fit: StackFit.expand,
          children: [
            VGBeautyGuideOverlay(guides: guides),
            VGBeautyAnnotationOverlay(annotations: annotations),
          ],
        ),
      ),
      children: [
        16.height,
        VGBeautyReportCard(
          beautyScore: beautyScore,
          subscores: subscores,
          disclaimer: VGCopy.resultBeautyDisclaimer,
        ),
      ],
    );
  }
}
