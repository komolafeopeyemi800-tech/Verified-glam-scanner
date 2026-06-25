import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;

import 'package:flutter/material.dart';

const _viewType = 'vg-marketing-iframe';

bool _registered = false;

void _registerIframe() {
  if (_registered) return;
  _registered = true;
  ui_web.platformViewRegistry.registerViewFactory(
    _viewType,
    (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = '/marketing/index.html?embed=1'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'clipboard-read; clipboard-write';
      return iframe;
    },
  );
}

/// Marketing HTML below the Flutter app header.
Widget buildMarketingHomeIframeBody() {
  _registerIframe();
  return const HtmlElementView(viewType: _viewType);
}

/// @deprecated Use [VGWebMarketingHomeScreen] with app bar + [buildMarketingHomeIframeBody].
Widget buildMarketingHomeIframe() {
  _registerIframe();
  return const Scaffold(
    body: SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    ),
  );
}
