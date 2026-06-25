import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/results/vg_attractiveness_report_card.dart';
import '../../../components/vg/results/vg_attractiveness_scan_box_overlay.dart';
import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';
import '../../../utils/vg_payload_lists.dart';

class VGAttractivenessResult extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGAttractivenessResult({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = result.payload;
    final overallScore = VGPayloadValues.displayOutOf10(p, p['overallScore']);
    final tierLabel = p['tierLabel']?.toString() ??
        VGCopy.attractivenessTierFor(overallScore);
    final subtitle = p['subtitle']?.toString() ?? VGCopy.attractivenessSubtitle;
    final facialAge = VGPayloadValues.asIntOr(p['facialAge'], 0);
    final appearanceScores = VGPayloadValues.asMap(p['appearanceScores']);
    final traitScores = VGPayloadValues.asMap(p['traitScores']);
    final faceBox = VGPayloadValues.normalizedFaceBox(p['faceBox']);
    final landmarks = VGPayloadValues.normalizedLandmarkList(p['landmarks']);
    var meshConnections = VGPayloadLists.intPairs(p, 'meshConnections');
    if (meshConnections.isEmpty) {
      meshConnections = VGPayloadValues.defaultFaceReadingMeshConnections();
    }

    return VGResultScaffold(
      result: result,
      feature: feature,
      hero: VGFacePhotoHero(
        photoPath: result.photoPath,
        passport: true,
        photoFit: BoxFit.contain,
        overlay: VGAttractivenessScanBoxOverlay(
          faceBox: faceBox,
          landmarks: landmarks,
          meshConnections: meshConnections,
        ),
      ),
      children: [
        16.height,
        VGAttractivenessReportCard(
          overallScore: overallScore,
          tierLabel: tierLabel,
          subtitle: subtitle,
          facialAge: facialAge,
          appearanceScores: appearanceScores,
          traitScores: traitScores,
          photoPath: result.photoPath,
          scoresFinalized: VGPayloadValues.isScoresFinalized(p),
        ),
      ],
    );
  }
}
