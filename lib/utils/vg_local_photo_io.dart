import 'dart:io';

import 'package:flutter/material.dart';

Widget vgLocalPhotoImage(
  String path, {
  required BoxFit fit,
  required Alignment alignment,
}) {
  return Image.file(
    File(path),
    fit: fit,
    alignment: alignment,
  );
}
