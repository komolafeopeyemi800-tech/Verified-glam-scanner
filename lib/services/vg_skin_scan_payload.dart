import 'vg_challenge_service.dart';
import 'vg_detected_issues_builder.dart';
import 'vg_result_overlay_service.dart';

/// Shared skin-scan payload parsing for Beauty Tips and Beauty Routine Challenge results.
class VGSkinScanPayload {
  VGSkinScanPayload._();

  /// Legacy GLOW_UP_GUIDE payloads only contained AI-generated day lists.
  static bool isLegacyGlowUpPayload(Map<String, dynamic> payload) {
    final days = payload['days'];
    if (days is! List || days.isEmpty) return false;
    final spots = payload['spots'];
    final findings = payload['findings'];
    final detected = payload['detectedIssues'];
    return (spots is! List || spots.isEmpty) &&
        (findings is! List || findings.isEmpty) &&
        (detected is! List || detected.isEmpty);
  }

  static bool hasSkinScanData(Map<String, dynamic> payload) {
    return !isLegacyGlowUpPayload(payload) &&
        (resolveAnnotations(payload).isNotEmpty || detectedIssues(payload).isNotEmpty);
  }

  static List<Map<String, dynamic>> detectedIssues(Map<String, dynamic> payload) {
    return VGChallengeService.detectedIssuesForPayload(payload);
  }

  /// Face overlay labels: prefer per-spot callouts, then findings, then ranked issues.
  static List<Map<String, dynamic>> resolveAnnotations(Map<String, dynamic> payload) {
    final fromPayload = payload['annotations'];
    if (fromPayload is List && fromPayload.isNotEmpty) {
      return fromPayload
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .take(16)
          .toList();
    }

    final spots = payload['spots'];
    if (spots is List && spots.isNotEmpty) {
      return spots
          .whereType<Map>()
          .map((s) => Map<String, dynamic>.from(s))
          .map(
            (s) => {
              'text': s['label'] ?? s['shortLabel'] ?? 'Spot',
              'anchor': s['anchor'],
              'labelSide': s['labelSide'],
              'color': s['color'],
              'spotId': s['id'],
            },
          )
          .take(16)
          .toList();
    }

    final findings = payload['findings'];
    if (findings is List && findings.isNotEmpty) {
      return findings
          .whereType<Map>()
          .map((f) => Map<String, dynamic>.from(f))
          .map(
            (f) => {
              'text': f['shortLabel'] ?? f['categoryName'] ?? 'Concern',
              'anchor': f['anchor'],
              'labelSide': f['labelSide'],
              'color': f['color'],
            },
          )
          .take(8)
          .toList();
    }

    return VGResultOverlayService.concernAnnotations(payload);
  }

  static List<Map<String, dynamic>> ensureDetectedIssues(Map<String, dynamic> payload) {
    final existing = detectedIssues(payload);
    if (existing.isNotEmpty) return existing;
    return VGDetectedIssuesBuilder.fromPayload(payload);
  }
}
