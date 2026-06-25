import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/results/vg_beauty_tips_report_card.dart';
import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../components/vg/results/vg_skin_concern_overlay.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_skin_scan_payload.dart';
import '../../../utils/vg_payload_lists.dart';

class VGBeautyTipsResult extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGBeautyTipsResult({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = result.payload;
    final findings = VGPayloadLists.maps(p, 'findings');
    final annotations = VGSkinScanPayload.resolveAnnotations(p);
    final tips = VGPayloadLists.maps(p, 'tips');
    final summary = p['summary'] as String? ?? '';
    final globalDisclaimer = p['globalDisclaimer'] as String? ?? '';

    return VGResultScaffold(
      result: result,
      feature: feature,
      hero: VGFacePhotoHero(
        photoPath: result.photoPath,
        passport: true,
        overlay: VGSkinConcernOverlay(annotations: annotations),
      ),
      children: [
        16.height,
        VGBeautyTipsReportCard(
          findings: findings,
          tips: tips,
          summary: summary,
          globalDisclaimer: globalDisclaimer,
          photoPath: result.photoPath,
        ),
      ],
    );
  }
}
