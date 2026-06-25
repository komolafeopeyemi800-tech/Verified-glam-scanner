import 'package:flutter/material.dart';

import '../models/vg_scan_result.dart';

import 'vg_result_download_stub.dart'
    if (dart.library.io) 'vg_result_download_io.dart'
    if (dart.library.html) 'vg_result_download_web.dart' as impl;

/// Saves the labeled result hero (or raw photo fallback) to the user's device.
class VGResultDownloadService {
  VGResultDownloadService._();

  static Future<bool> downloadResultPhoto(
    VGScanResult result, {
    GlobalKey? heroBoundaryKey,
  }) =>
      impl.downloadResultPhoto(result, heroBoundaryKey: heroBoundaryKey);
}
