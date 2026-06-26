import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/vg_constants.dart';
import 'vg_web_page_nav_stub.dart'
    if (dart.library.html) 'vg_web_page_nav_web.dart' as page_nav;

const _emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';

bool vgIsValidAuthEmail(String email) => RegExp(_emailPattern).hasMatch(email);

bool vgIsValidAuthPassword(String password) => password.length >= 6;

String vgAuthErrorMessage(Object error) {
  if (error is AuthException) return error.message;
  final text = error.toString();
  if (text.contains('FormatException') || text.contains('Unexpected character')) {
    return 'Login failed — app cannot reach Supabase. Rebuild with .\\scripts\\build-web.ps1, then hard-refresh (Ctrl+Shift+R).';
  }
  if (text.startsWith('Exception: ')) return text.substring(11);
  return text;
}

/// Safe in-app path only (no open redirects).
bool vgIsSafeRedirectPath(String? path) {
  if (path == null || path.isEmpty) return false;
  if (!path.startsWith('/') || path.startsWith('//')) return false;
  const blocked = {'/login', '/register', '/forgot-password', '/walkthrough', '/splash', '/dashboard'};
  return !blocked.contains(path);
}

Future<void> vgSavePostAuthRedirect(String? path) async {
  if (vgIsSafeRedirectPath(path)) {
    await setValue(vgPostAuthRedirectKey, path!);
  }
}

Future<String?> vgTakePostAuthRedirect() async {
  final path = getStringAsync(vgPostAuthRedirectKey);
  if (path.isEmpty) return null;
  await removeKey(vgPostAuthRedirectKey);
  return vgIsSafeRedirectPath(path) ? path : null;
}

void vgCaptureRedirectFromUri(BuildContext context) {
  final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
  if (vgIsSafeRedirectPath(redirect)) {
    setValue(vgPostAuthRedirectKey, redirect!);
  }
}

/// Full-page navigation to static HTML login (marketing tier).
void vgWebGoLogin({String? redirect}) {
  if (!kIsWeb) return;
  final q = vgIsSafeRedirectPath(redirect)
      ? '?redirect=${Uri.encodeComponent(redirect!)}'
      : '';
  page_nav.vgWebHardRedirect('/login$q');
}
