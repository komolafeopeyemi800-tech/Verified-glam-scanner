import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'vg_platform_file.dart';

/// Center-crops [sourcePath] to a square JPEG and returns the new file path.
Future<String> vgCenterCropToSquare(String sourcePath) async {
  final bytes = await vgReadFileBytes(sourcePath);
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return sourcePath;

  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final x = (decoded.width - side) ~/ 2;
  final y = (decoded.height - side) ~/ 2;
  final cropped = img.copyCrop(decoded, x: x, y: y, width: side, height: side);

  return vgWriteTempJpeg(img.encodeJpg(cropped, quality: 90), prefix: 'vg_square');
}

/// Writes cropped image bytes to a temp JPEG and returns the file path.
Future<String> vgExportCroppedImage(Uint8List croppedBytes) async {
  final decoded = img.decodeImage(croppedBytes);
  final output = decoded != null ? img.encodeJpg(decoded, quality: 90) : croppedBytes;
  return vgWriteTempJpeg(output, prefix: 'vg_cropped');
}
