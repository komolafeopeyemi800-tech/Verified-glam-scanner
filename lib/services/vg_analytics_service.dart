import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Lightweight analytics wrapper (Firebase Analytics when available).
class VGAnalyticsService {
  VGAnalyticsService._();

  static FirebaseAnalytics? get _analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  static Future<void> logScanStarted(String featureType) async {
    await _log('scan_started', {'feature_type': featureType});
  }

  static Future<void> logScanCompleted(
    String featureType,
    Map<String, dynamic> payload,
  ) async {
    final score = payload['beautyScore'] ??
        payload['overallScore'] ??
        payload['overallSymmetryScore'] ??
        payload['overallPercent'];
    await _log('scan_completed', {
      'feature_type': featureType,
      if (score != null) 'score': score.toString(),
    });
  }

  static Future<void> logScanFailed(String featureType, String errorCode) async {
    await _log('scan_failed', {
      'feature_type': featureType,
      'error_code': errorCode,
    });
  }

  static Future<void> logOnboardingCompleted() async {
    await _log('onboarding_completed');
  }

  static Future<void> logPaywallShown(String source) async {
    await _log('paywall_shown', {'source': source});
  }

  static Future<void> logChallengeDayCompleted(int dayNumber) async {
    await _log('challenge_day_completed', {'day_number': dayNumber});
  }

  static Future<void> logPushOpened(String kind, {String deepLink = ''}) async {
    await _log('push_opened', {
      'kind': kind,
      if (deepLink.isNotEmpty) 'deep_link': deepLink,
    });
  }

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) {
      debugPrint('VGAnalytics: $name ${params ?? ''}');
    }
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('VGAnalytics failed: $e');
    }
  }
}
