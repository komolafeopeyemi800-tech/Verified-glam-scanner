import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/vg_scan_result.dart';

const vgScanHistoryKey = 'vg_scan_history';
const _legacyHistoryClearedKey = 'vg_scan_history_cleared_v2';

/// Legacy scan history — no longer persisted. Clears old local entries once on boot.
class VGScanHistoryStore {
  VGScanHistoryStore._();

  static Future<void> clearLegacyLocalHistoryOnce() async {
    if (getBoolAsync(_legacyHistoryClearedKey)) return;
    await removeKey(vgScanHistoryKey);
    await setValue(_legacyHistoryClearedKey, true);
    debugPrint('VGScanHistoryStore: cleared legacy local scan history');
  }

  @Deprecated('Scan history removed — results are download-only')
  static Future<List<VGScanResult>> loadAll() async {
    await clearLegacyLocalHistoryOnce();
    return const [];
  }

  @Deprecated('Scan history removed — results are download-only')
  static Future<void> save(VGScanResult result) async {}

  @Deprecated('Scan history removed — results are download-only')
  static Future<VGScanResult?> getById(String id) async => null;
}
