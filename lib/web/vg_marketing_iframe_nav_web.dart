import 'dart:convert';

import 'dart:html' as html;

import 'vg_web_router.dart';

bool _registered = false;

/// Listens for navigation requests from the marketing homepage iframe.
void registerMarketingIframeNavListener() {
  if (_registered) return;
  _registered = true;

  html.window.onMessage.listen((event) {
    if (event.origin != html.window.location.origin) return;
    final raw = event.data;
    if (raw is! String) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['type'] != 'vg-navigate') return;
      final path = map['path'];
      if (path is! String || !path.startsWith('/')) return;
      vgWebRouter.go(path);
    } catch (_) {
      // Ignore malformed messages.
    }
  });
}
