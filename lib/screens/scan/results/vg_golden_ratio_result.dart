import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_golden_ratio_measurement_overlay.dart';
import '../../../components/vg/results/vg_golden_ratio_report_card.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../components/vg/results/vg_skin_concern_overlay.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_result_overlay_service.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';

class VGGoldenRatioResult extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGGoldenRatioResult({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = result.payload;
    final overallScore = VGPayloadValues.asDoubleOr(p['overallScore'], 0);
    final goldenRatioIndex = VGPayloadValues.asIntOr(
      p['goldenRatioIndex'] ?? p['harmonyPercent'],
      0,
    );
    final ratingLabel = p['ratingLabel'] as String? ??
        VGCopy.goldenRatioRatingFor(goldenRatioIndex);
    final idealPhi = VGPayloadValues.asDoubleOr(p['idealPhi'], 1.618);
    final landmarks = VGPayloadValues.asMap(p['landmarks']);
    final measurements = VGPayloadValues.asMapList(p['measurements']);
    final deviations = VGPayloadValues.asStringList(p['deviations']);
    final concernAnnotations = VGResultOverlayService.concernAnnotations(p);

    return VGResultScaffold(
      result: result,
      feature: feature,
      hero: VGFacePhotoHero(
        photoPath: result.photoPath,
        passport: true,
        overlay: Stack(
          fit: StackFit.expand,
          children: [
            VGGoldenRatioMeasurementOverlay(
              landmarks: landmarks,
              measurements: measurements,
              overallScore: overallScore,
              ratingLabel: ratingLabel,
              deviations: deviations,
            ),
            VGSkinConcernOverlay(annotations: concernAnnotations),
          ],
        ),
      ),
      children: [
        16.height,
        VGGoldenRatioReportCard(
          overallScore: overallScore,
          goldenRatioIndex: goldenRatioIndex,
          ratingLabel: ratingLabel,
          measurements: measurements,
          idealPhi: idealPhi,
        ),
      ],
    );
  }
}
