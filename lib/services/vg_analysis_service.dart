import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/vg_feature_model.dart';
import '../models/vg_onboarding_profile.dart';
import '../models/vg_scan_result.dart';
import '../utils/vg_camera_utils.dart';
import '../utils/vg_constants.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_error_utils.dart';
import '../utils/vg_mock_results.dart';
import 'vg_profile_cache.dart';
import 'supabase/vg_supabase_profile_repository.dart';
import 'supabase/vg_supabase_storage_service.dart';
import 'vg_analysis_mode.dart';
import 'vg_connectivity_service.dart';
import 'vg_onboarding_store.dart';
import 'vg_session_scan_cache.dart';
import 'supabase/vg_supabase_init.dart';

class VGAnalysisService {
  VGAnalysisService._();

  static const _uuid = Uuid();

  static Future<VGScanResult> runAnalysis({
    required VGFeatureModel feature,
    required String photoPath,
  }) async {
    final blockReason = VGAnalysisMode.blockReason;
    if (blockReason != null) {
      throw StateError(blockReason);
    }

    if (VGAnalysisMode.isLiveAnalysis) {
      final online = await VGConnectivityService.isOnline();
      if (!online) {
        throw const VGAnalysisFailure(
          message: VGCopy.scanOfflineMessage,
          errorCode: 'NETWORK_ERROR',
        );
      }
    }

    final scanId = _uuid.v4();
    List<Map<String, dynamic>>? detectedFaces;

    if (feature.featureType == VGFeatureTypes.facialResemblance ||
        feature.featureType == VGFeatureTypes.faceReading ||
        feature.featureType == VGFeatureTypes.goldenRatio ||
        feature.featureType == VGFeatureTypes.beautyTips ||
        feature.featureType == VGFeatureTypes.glowUpGuide) {
      detectedFaces = await vgDetectFaceContoursNormalized(photoPath);
    }

    Map<String, dynamic> payload;
    String? storagePath;
    final usedMock = VGAnalysisMode.willUseMock;

    if (VGAnalysisMode.isLiveAnalysis) {
      storagePath = await VGSupabaseStorageService.uploadScanPhoto(
        localPath: photoPath,
        scanId: scanId,
      );
      payload = await _invokeAnalyzeScan(
        feature: feature,
        storagePath: storagePath,
        detectedFaces: detectedFaces,
      );
      try {
        await VGSupabaseStorageService.deleteScanPhoto(storagePath);
      } catch (e) {
        debugPrint('VGAnalysisService: temp photo cleanup failed: $e');
      }
    } else {
      payload = buildMockResultPayload(
        feature,
        photoPath: photoPath,
        detectedFaces: detectedFaces,
      );
    }

    final scanResult = VGScanResult(
      id: scanId,
      featureType: feature.featureType,
      featureTitle: feature.title,
      createdAt: DateTime.now(),
      payload: payload,
      photoPath: photoPath,
      storagePath: storagePath,
      usedMockAnalysis: usedMock,
    );
    VGSessionScanCache.set(scanResult);
    return scanResult;
  }

  static Future<Map<String, dynamic>> _invokeAnalyzeScan({
    required VGFeatureModel feature,
    required String storagePath,
    List<Map<String, dynamic>>? detectedFaces,
  }) async {
    final profile = await _profilePayload();

    try {
      final response = await VGSupabaseInit.client.functions.invoke(
        'analyze-scan',
        body: {
          'featureType': feature.featureType,
          'storagePath': storagePath,
          'detectedFaces': detectedFaces ?? [],
          'profile': profile,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        if (data is Map) {
          throw VGAnalysisFailure(
            message: data['error']?.toString() ?? 'Analysis failed (${response.status})',
            errorCode: data['errorCode']?.toString() ?? 'ANALYSIS_FAILED',
            status: response.status,
          );
        }
        throw VGAnalysisFailure(
          message: 'Analysis failed (${response.status})',
          errorCode: 'ANALYSIS_FAILED',
          status: response.status,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['payload'] as Map);
    } on FunctionException catch (e) {
      throw vgParseAnalysisError(e);
    }
  }

  static Future<Map<String, dynamic>> _profilePayload() async {
    VGOnboardingProfile profile = await VGProfileCache.load() ?? await VGOnboardingStore.loadProfile();
    if (VGAnalysisMode.useCloud) {
      final remote = await VGSupabaseProfileRepository.fetchProfile();
      if (remote != null) {
        profile = remote;
        await VGProfileCache.save(remote);
      }
    }
    return profile.toJson();
  }
}
