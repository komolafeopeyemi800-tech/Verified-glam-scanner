import 'package:web/web.dart' as web;

/// Navigates the top-level browser window to a static marketing page.
void vgOpenMarketingPage(String path) {
  web.window.location.href = path;
}

/// Full-page redirect (e.g. unsigned user → static /login).
void vgWebHardRedirect(String path) {
  web.window.location.assign(path);
}
