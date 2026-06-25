import 'dart:html' as html;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

Future<Uint8List> vgReadFileBytes(String path) async {
  if (path.startsWith('blob:') || path.startsWith('data:')) {
    final request = await html.HttpRequest.request(path, responseType: 'arraybuffer');
    return Uint8List.view(request.response as ByteBuffer);
  }
  final response = await http.get(Uri.parse(path));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError('Failed to read image bytes ($path): ${response.statusCode}');
  }
  return response.bodyBytes;
}

/// On web, returns a blob URL usable for display and upload.
Future<String> vgWriteTempJpeg(Uint8List bytes, {String prefix = 'vg'}) async {
  final blob = html.Blob([bytes], 'image/jpeg');
  return html.Url.createObjectUrlFromBlob(blob);
}

bool vgLocalPathExists(String? path) {
  if (path == null || path.isEmpty) return false;
  if (path.startsWith('http://') || path.startsWith('https://')) return false;
  return path.startsWith('blob:') || path.startsWith('data:');
}
