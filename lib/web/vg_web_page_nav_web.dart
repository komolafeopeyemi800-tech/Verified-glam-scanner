import 'package:web/web.dart' as web;

/// Navigates the top-level browser window to a static marketing page.
void vgOpenMarketingPage(String path) {
  web.window.location.href = path;
}
