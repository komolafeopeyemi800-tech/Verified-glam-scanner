import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../components/vg/results/vg_skin_concern_overlay.dart';
import '../../../components/vg/vg_analysis_card.dart';
import '../../../components/vg/vg_score_display.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_result_overlay_service.dart';

/// Archived BEST_FACE_PART scans from before catalog removal.
class VGBestFacePartLegacyResult extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGBestFacePartLegacyResult({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    final p = result.payload;
    final concernAnnotations = VGResultOverlayService.concernAnnotations(p);
    return VGResultScaffold(
      result: result,
      feature: feature,
      hero: VGFacePhotoHero(
        photoPath: result.photoPath,
        passport: true,
        overlay: VGSkinConcernOverlay(annotations: concernAnnotations),
      ),
      children: [
        16.height,
        VGScoreDisplay(label: 'Standout feature', value: p['bestFeature']?.toString() ?? '—'),
        VGAnalysisCard(title: 'Why', body: p['reason']?.toString() ?? '', icon: Icons.star_outline),
      ],
    );
  }
}
