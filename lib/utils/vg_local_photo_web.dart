import 'package:flutter/material.dart';

Widget vgLocalPhotoImage(
  String path, {
  required BoxFit fit,
  required Alignment alignment,
}) {
  return Image.network(
    path,
    fit: fit,
    alignment: alignment,
  );
}
