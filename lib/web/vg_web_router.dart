import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../screens/onboarding/vg_onboarding_flow.dart';
import '../services/supabase/vg_supabase_auth_service.dart';
import '../services/supabase/vg_supabase_config.dart';
import '../services/supabase/vg_supabase_init.dart';
import '../utils/vg_constants.dart';
import 'screens/vg_web_about_screen.dart';
import 'screens/vg_web_privacy_screen.dart';
import 'screens/vg_web_terms_screen.dart';
import 'screens/vg_tool_landing_screen.dart';
import 'screens/vg_web_app_screen.dart';
import 'screens/vg_web_forgot_password_screen.dart';
import 'screens/vg_web_marketing_home_screen.dart';
import 'screens/vg_web_tools_index_screen.dart';
import 'screens/vg_web_login_screen.dart';
import 'screens/vg_web_pricing_screen.dart';
import 'screens/vg_web_register_screen.dart';
import 'vg_feature_slugs.dart';
import 'vg_web_app_prefs.dart';
import 'widgets/vg_web_tool_sidebar.dart';

/// Browser path at first router attach (must run after [usePathUrlStrategy] in main).
String vgWebEntryLocation() {
  final path = Uri.base.path;
  if (path.isEmpty) return '/';
  return path;
}

final GoRouter vgWebRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: vgWebEntryLocation(),
  overridePlatformDefaultLocation: true,
  redirect: (context, state) {
    final path = state.uri.path;
    if (path == '/walkthrough' || path == '/splash') {
      return '/';
    }

    if (path.startsWith('/marketing')) {
      if (path.endsWith('about.html')) return '/about';
      if (path.endsWith('privacy.html')) return '/privacy';
      if (path.endsWith('terms.html')) return '/terms';
      return '/';
    }

    final signedIn = kVGUseSupabase &&
        VGSupabaseConfig.isConfigured &&
        VGSupabaseInit.isReady &&
        VGSupabaseAuthService.isSignedIn;

    if (signedIn && (path == '/login' || path == '/register' || path == '/forgot-password')) {
      return vgWebDefaultAppPath();
    }

    if (!signedIn && path.startsWith('/app')) {
      final redirect = Uri.encodeComponent(path);
      return '/login?redirect=$redirect';
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
    GoRoute(path: '/', builder: (_, __) => const VGWebMarketingHomeScreen()),
    GoRoute(path: '/about', builder: (_, __) => const VGWebAboutScreen()),
    GoRoute(path: '/privacy', builder: (_, __) => const VGWebPrivacyScreen()),
    GoRoute(path: '/terms', builder: (_, __) => const VGWebTermsScreen()),
    GoRoute(
      path: '/marketing/:rest(.*)',
      redirect: (_, state) {
        final rest = state.pathParameters['rest'] ?? '';
        if (rest == 'about.html') return '/about';
        if (rest == 'privacy.html') return '/privacy';
        if (rest == 'terms.html') return '/terms';
        return '/';
      },
    ),
    GoRoute(path: '/marketing', redirect: (_, __) => '/'),
    GoRoute(path: '/tools', builder: (_, __) => const VGWebToolsIndexScreen()),
    GoRoute(path: '/pricing', builder: (_, __) => const VGWebPricingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const VGWebLoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const VGWebRegisterScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const VGWebForgotPasswordScreen()),
    GoRoute(
      path: '/dashboard',
      redirect: (_, __) => vgWebDefaultAppPath(),
    ),
    GoRoute(path: '/onboarding', builder: (_, __) => const VGOnboardingFlow()),
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
    GoRoute(
      path: '/walkthrough',
      redirect: (_, __) => '/',
    ),
    GoRoute(
      path: '/splash',
      redirect: (_, __) => '/',
    ),
    for (final slug in vgAllToolSlugs)
      GoRoute(
        path: '/$slug',
        builder: (_, __) => VGToolLandingScreen(slug: slug),
      ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
