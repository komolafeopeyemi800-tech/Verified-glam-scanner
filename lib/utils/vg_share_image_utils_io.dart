import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a widget subtree as PNG and shares it, with text fallback.
Future<void> vgShareWidgetAsImage({
  required GlobalKey boundaryKey,
  required String textFallback,
}) async {
  try {
    final boundary =
        boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      await Share.share(textFallback);
      return;
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      await Share.share(textFallback);
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/vg_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());
    await Share.shareXFiles([XFile(file.path)], text: textFallback);
  } catch (_) {
    await Share.share(textFallback);
  }
}
