import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

const _viewType = 'vg-marketing-iframe';

bool _registered = false;
web.HTMLIFrameElement? _marketingIframe;

/// Prevents the marketing iframe from stealing clicks while Flutter overlays (e.g. AI Tools menu) are open.
void setMarketingIframePointerEvents(bool enabled) {
  final iframe = _marketingIframe;
  if (iframe == null) return;
  iframe.style.pointerEvents = enabled ? 'auto' : 'none';
}

void _registerIframe() {
  if (_registered) return;
  _registered = true;
  ui_web.platformViewRegistry.registerViewFactory(
    _viewType,
    (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = '/_static/home/index.html?embed=1'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'clipboard-read; clipboard-write';
      _marketingIframe = iframe;
      return iframe;
    },
  );
}

/// Iframe body only — parent screen provides [VGWebHeader] app bar.
Widget buildMarketingHomeIframeBody() {
  _registerIframe();
  return const HtmlElementView(viewType: _viewType);
}
