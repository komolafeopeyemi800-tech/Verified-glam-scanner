import 'package:flutter/material.dart';

import '../../models/vg_feature_model.dart';
import '../../models/vg_scan_result.dart';
import '../../utils/vg_constants.dart';
import 'results/vg_attractiveness_result.dart';
import 'results/vg_beauty_tips_result.dart';
import 'results/vg_celebrity_result.dart';
import 'results/vg_color_analysis_result.dart';
import 'results/vg_face_beauty_result.dart';
import 'results/vg_facial_symmetry_result.dart';
import 'results/vg_glow_up_result.dart';
import 'results/vg_golden_ratio_result.dart';
import 'results/vg_legacy_best_face_result.dart';
import 'results/vg_resemblance_result.dart';
import 'results/vg_showdown_result.dart';

/// Routes completed scans to per-feature result UIs (photo hero + overlays).
class VGResultsScreen extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGResultsScreen({super.key, required this.result, required this.feature});

  @override
  Widget build(BuildContext context) {
    switch (result.featureType) {
      case VGFeatureTypes.faceBeautyAnalysis:
        return VGFaceBeautyResult(result: result, feature: feature);
      case VGFeatureTypes.colorAnalysis:
        return VGColorAnalysisResult(result: result, feature: feature);
      case VGFeatureTypes.glowUpGuide:
        return VGGlowUpResult(result: result, feature: feature);
      case VGFeatureTypes.beautyTips:
        return VGBeautyTipsResult(result: result, feature: feature);
      case VGFeatureTypes.celebrityLookalike:
        return VGCelebrityResult(result: result, feature: feature);
      case VGFeatureTypes.facialSymmetry:
        return VGFacialSymmetryResult(result: result, feature: feature);
      case VGFeatureTypes.beautyScoreShowdown:
        return VGShowdownResult(result: result, feature: feature);
      case VGFeatureTypes.facialResemblance:
        return VGResemblanceResult(result: result, feature: feature);
      case VGFeatureTypes.faceReading:
        return VGAttractivenessResult(result: result, feature: feature);
      case VGFeatureTypes.goldenRatio:
        return VGGoldenRatioResult(result: result, feature: feature);
      case VGFeatureTypes.bestFacePart:
        return VGBestFacePartLegacyResult(result: result, feature: feature);
      default:
        return VGBestFacePartLegacyResult(result: result, feature: feature);
    }
  }
}
