import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/onboarding/vg_onboarding_flow.dart';
import '../services/supabase/vg_supabase_auth_service.dart';
import '../services/supabase/vg_supabase_config.dart';
import '../services/supabase/vg_supabase_init.dart';
import '../utils/vg_constants.dart';
import 'screens/vg_web_app_screen.dart';
import 'screens/vg_web_forgot_password_screen.dart';
import 'vg_web_app_prefs.dart';
import 'vg_web_page_nav_stub.dart'
    if (dart.library.html) 'package:verified_glam/web/vg_web_page_nav_web.dart' as page_nav;
import 'widgets/vg_web_tool_sidebar.dart';

String vgWebEntryLocation() {
  final path = Uri.base.path;
  if (path.isEmpty) return '/';
  return path;
}

/// Maps legacy /marketing/* paths to clean static URLs (one-time hard redirect).
String? _legacyMarketingRedirect(String path) {
  if (path == '/marketing' || path == '/marketing/' || path == '/marketing/index.html') {
    return '/';
  }
  const map = {
    '/marketing/about.html': '/about',
    '/marketing/privacy.html': '/privacy',
    '/marketing/terms.html': '/terms',
  };
  return map[path];
}

final GoRouter vgWebRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: vgWebEntryLocation(),
  overridePlatformDefaultLocation: true,
  redirect: (context, state) {
    final path = state.uri.path;

    if (path == '/walkthrough' || path == '/splash') {
      page_nav.vgWebHardRedirect('/');
      return path;
    }

    if (path.startsWith('/marketing')) {
      final legacy = _legacyMarketingRedirect(path);
      if (legacy != null) {
        page_nav.vgWebHardRedirect(legacy);
      } else {
        page_nav.vgWebHardRedirect('/');
      }
      return path;
    }

    final signedIn = kVGUseSupabase &&
        VGSupabaseConfig.isConfigured &&
        VGSupabaseInit.isReady &&
        VGSupabaseAuthService.isSignedIn;

    if (!signedIn && path.startsWith('/app')) {
      final redirect = Uri.encodeComponent(path);
      page_nav.vgWebHardRedirect('/login?redirect=$redirect');
      return path;
    }

    if (signedIn && path == '/forgot-password') {
      return vgWebDefaultAppPath();
    }

    if (path == '/dashboard') {
      return vgWebDefaultAppPath();
    }

    if (path == '/app/scans' || path.startsWith('/app/scans/')) {
      return vgWebDefaultAppPath();
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/dashboard',
      redirect: (_, __) => vgWebDefaultAppPath(),
    ),
    GoRoute(path: '/onboarding', builder: (_, __) => const VGOnboardingFlow()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const VGWebForgotPasswordScreen()),
    GoRoute(
      path: '/app/profile/challenge/day/:day',
      builder: (_, state) {
        final day = int.tryParse(state.pathParameters['day'] ?? '1') ?? 1;
        return VGWebAppScreen(
          section: VGWebAppSection.profile,
          profileSubview: VGWebProfileSubview.challengeDay,
          challengeDay: day,
        );
      },
    ),
    GoRoute(
      path: '/app/profile/challenge',
      builder: (_, __) => const VGWebAppScreen(
        section: VGWebAppSection.profile,
        profileSubview: VGWebProfileSubview.challenge,
      ),
    ),
    GoRoute(
      path: '/app/profile/reward',
      builder: (_, __) => const VGWebAppScreen(
        section: VGWebAppSection.profile,
        profileSubview: VGWebProfileSubview.reward,
      ),
    ),
    GoRoute(
      path: '/app/profile',
      builder: (_, __) => const VGWebAppScreen(section: VGWebAppSection.profile),
    ),
    GoRoute(
      path: '/app/:slug',
      builder: (_, state) {
        final slug = state.pathParameters['slug'] ?? vgDefaultWebToolSlug;
        return VGWebAppScreen(slug: slug, section: VGWebAppSection.tool);
      },
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
