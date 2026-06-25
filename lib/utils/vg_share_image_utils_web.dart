import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// On web, share text only (no temp file capture).
Future<void> vgShareWidgetAsImage({
  required GlobalKey boundaryKey,
  required String textFallback,
}) async {
  await Share.share(textFallback);
}
