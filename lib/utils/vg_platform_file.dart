import 'dart:typed_data';

import 'vg_platform_file_io.dart' if (dart.library.html) 'vg_platform_file_web.dart' as impl;

/// Reads local image bytes from a path (file path on mobile, blob URL on web).
Future<Uint8List> vgReadFileBytes(String path) => impl.vgReadFileBytes(path);

/// Writes JPEG bytes to a temp location; returns a path usable for display/upload.
Future<String> vgWriteTempJpeg(Uint8List bytes, {String prefix = 'vg'}) =>
    impl.vgWriteTempJpeg(bytes, prefix: prefix);

/// Whether a local photo path exists on the current platform.
bool vgLocalPathExists(String? path) => impl.vgLocalPathExists(path);
