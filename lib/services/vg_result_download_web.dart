import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/vg_scan_result.dart';
import '../utils/vg_platform_file.dart';
import '../utils/vg_widget_capture.dart';

String _downloadFilename(VGScanResult result, {required bool png}) {
  final ext = png ? 'png' : 'jpg';
  final slug = result.featureType.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return 'verified-glam-$slug-${result.id}.$ext';
}

Future<bool> _downloadBytes(Uint8List bytes, String filename, String mimeType) async {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  return true;
}

Future<bool> downloadResultPhoto(
  VGScanResult result, {
  GlobalKey? heroBoundaryKey,
}) async {
  if (heroBoundaryKey != null) {
    final png = await captureWidgetPng(heroBoundaryKey);
    if (png != null && png.isNotEmpty) {
      return _downloadBytes(png, _downloadFilename(result, png: true), 'image/png');
    }
  }

  final path = result.photoPath;
  if (path == null || path.isEmpty) return false;

  final bytes = await vgReadFileBytes(path);
  return _downloadBytes(
    bytes,
    _downloadFilename(result, png: false),
    'image/jpeg',
  );
}
