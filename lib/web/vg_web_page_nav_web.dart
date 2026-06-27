import 'package:web/web.dart' as web;

/// Navigates the top-level browser window to a static marketing page.
void vgOpenMarketingPage(String path) {
  web.window.location.href = path;
}

/// Full-page redirect (e.g. unsigned user → static /login).
void vgWebHardRedirect(String path) {
  web.window.location.assign(path);
}

/// Static marketing login with optional post-auth return path.
void vgWebGoLogin({String? redirectPath}) {
  if (redirectPath != null && redirectPath.isNotEmpty) {
    vgWebHardRedirect('/login?redirect=${Uri.encodeComponent(redirectPath)}');
  } else {
    vgWebHardRedirect('/login');
  }
}
