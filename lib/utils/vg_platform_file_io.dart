import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> vgReadFileBytes(String path) => File(path).readAsBytes();

Future<String> vgWriteTempJpeg(Uint8List bytes, {String prefix = 'vg'}) async {
  final outPath = '${Directory.systemTemp.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(outPath).writeAsBytes(bytes);
  return outPath;
}

bool vgLocalPathExists(String? path) {
  if (path == null || path.isEmpty) return false;
  if (path.startsWith('http://') || path.startsWith('https://')) return false;
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}
