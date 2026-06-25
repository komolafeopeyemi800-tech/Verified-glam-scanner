import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/vg_scan_result.dart';
import '../utils/vg_widget_capture.dart';

String _shareFilename(VGScanResult result, {required bool png}) {
  final ext = png ? 'png' : 'jpg';
  final slug = result.featureType.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return 'verified-glam-$slug-${result.id}.$ext';
}

Future<bool> downloadResultPhoto(
  VGScanResult result, {
  GlobalKey? heroBoundaryKey,
}) async {
  if (heroBoundaryKey != null) {
    final png = await captureWidgetPng(heroBoundaryKey);
    if (png != null && png.isNotEmpty) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${_shareFilename(result, png: true)}');
      await file.writeAsBytes(png);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png', name: file.uri.pathSegments.last)],
        text: 'Verified Glam analysis',
      );
      return true;
    }
  }

  final path = result.photoPath;
  if (path == null || path.isEmpty) return false;

  await Share.shareXFiles(
    [XFile(path, mimeType: 'image/jpeg', name: _shareFilename(result, png: false))],
    text: 'Verified Glam analysis',
  );
  return true;
}
