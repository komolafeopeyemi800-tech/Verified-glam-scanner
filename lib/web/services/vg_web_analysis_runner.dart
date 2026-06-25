import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/scan/vg_scan_error_dialog.dart';
import '../../models/vg_feature_model.dart';
import '../../models/vg_scan_result.dart';
import '../../services/vg_analysis_mode.dart';
import '../../services/vg_analysis_service.dart';
import '../../services/vg_analytics_service.dart';
import '../../services/vg_connectivity_service.dart';
import '../../screens/scan/vg_results_screen.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_error_utils.dart';
import '../../utils/vg_navigation.dart';

/// Runs analysis from the web workspace (same backend as [VGProcessingScreen]).
Future<bool> vgRunWebScanAnalysis(
  BuildContext context, {
  required VGFeatureModel feature,
  required String photoPath,
  required ValueNotifier<double> progress,
}) async {
  final blockReason = VGAnalysisMode.blockReason;
  if (blockReason != null) {
    if (context.mounted) {
      await showVGScanErrorDialog(context, failure: VGAnalysisFailure(message: blockReason));
    }
    return false;
  }

  if (VGAnalysisMode.isLiveAnalysis) {
    final online = await VGConnectivityService.isOnline();
    if (!online) {
      if (context.mounted) {
        await showVGScanErrorDialog(
          context,
          failure: const VGAnalysisFailure(
            message: VGCopy.scanOfflineMessage,
            errorCode: 'NETWORK_ERROR',
          ),
        );
      }
      return false;
    }
  }

  progress.value = 0;
  for (var i = 1; i <= 20; i++) {
    await Future.delayed(const Duration(milliseconds: 120));
    progress.value = i / 20;
  }

  VGScanResult result;
  try {
    result = await VGAnalysisService.runAnalysis(feature: feature, photoPath: photoPath);
  } catch (e) {
    if (context.mounted) {
      await showVGScanErrorDialog(context, failure: vgParseAnalysisError(e));
    }
    return false;
  }

  if (!context.mounted) return false;

  try {
    await vgMaybeShowAdBeforeResults(context);
  } catch (_) {}

  if (!context.mounted) return false;

  VGAnalyticsService.logScanCompleted(feature.featureType, result.payload);
  await VGResultsScreen(result: result, feature: feature).launch(context);
  return true;
}
