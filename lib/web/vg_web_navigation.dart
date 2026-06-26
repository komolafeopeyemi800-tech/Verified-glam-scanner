import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/vg_paywall_promo_sheet.dart';
import '../models/vg_feature_model.dart';
import '../screens/subscription/vg_paywall_screen.dart';
import '../services/vg_subscription_store.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_constants.dart';
import 'screens/subscription/vg_web_paywall_dialog.dart';
import 'vg_web_breakpoints.dart';
import 'vg_web_profile_nav.dart';

bool vgIsDesktopWeb(BuildContext context) =>
    kIsWeb && VGWebBreakpoints.isDesktop(context);

void vgWebGoProfile(BuildContext context) => context.go('/app/profile');

void vgWebOpenChallenge(BuildContext context) => context.go('/app/profile/challenge');

void vgWebOpenChallengeDay(BuildContext context, int day) =>
    context.go('/app/profile/challenge/day/$day');

void vgWebOpenReward(
  BuildContext context, {
  required Map<String, dynamic> reward,
  required VGFeatureModel feature,
}) {
  VGWebProfileNavCache.setReward(reward, feature);
  context.go('/app/profile/reward');
}

void vgWebPopOrProfile(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    vgWebGoProfile(context);
  }
}

Future<void> vgWebShowPaywall(
  BuildContext context, {
  VGPaywallEntry entry = VGPaywallEntry.feature,
  VoidCallback? onDismiss,
}) async {
  if (VGWebBreakpoints.isDesktop(context)) {
    await showVGWebPaywallDialog(context, onDismiss: onDismiss);
    return;
  }
  await VGPaywallScreen(entry: entry, onDismiss: onDismiss).launch(context);
}

Future<void> vgWebShowPaywallPromo(BuildContext context) async {
  await showVGPaywallPromoSheet(context);
}

Future<void> vgWebMaybeShowAdBeforeResults(BuildContext context) async {
  if (kVGLocalDevMode) return;
  if (await VGSubscriptionStore.isPro()) return;
  if (await VGSubscriptionStore.shouldShowPaywallBeforeResults()) {
    await vgWebShowPaywallPromo(context);
  } else {
    toast(VGCopy.adInterstitialStub);
  }
  await VGSubscriptionStore.incrementFreeScanCount();
}
