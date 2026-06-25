import '../models/vg_scan_result.dart';
import '../utils/vg_constants.dart';

/// In-memory scan from the current session — used for glow-up challenge assignment only.
class VGSessionScanCache {
  VGSessionScanCache._();

  static VGScanResult? _lastScan;

  static void set(VGScanResult result) {
    _lastScan = result;
  }

  static void clear() {
    _lastScan = null;
  }

  /// Same priority as the former history-based resolver: glow-up, then beauty tips, then any.
  static VGScanResult? resolveForChallenge() {
    final scan = _lastScan;
    if (scan == null) return null;
    if (scan.featureType == VGFeatureTypes.glowUpGuide) return scan;
    if (scan.featureType == VGFeatureTypes.beautyTips) return scan;
    return scan;
  }
}
