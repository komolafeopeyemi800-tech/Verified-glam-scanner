import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../services/vg_polar_checkout_service.dart';
import '../utils/vg_copy.dart';
import 'vg_web_app_prefs.dart';

/// After Polar payment, user lands on `/app/...?checkout=success` — sync Pro + credits.
Future<void> vgWebHandleCheckoutReturn(BuildContext context) async {
  if (Uri.base.queryParameters['checkout'] != 'success') return;

  final restored = await VGPolarCheckoutService.pollSubscriptionFromServer();
  if (!context.mounted) return;

  if (restored) {
    toast(VGCopy.checkoutSuccessToast);
    final path = Uri.base.path.isNotEmpty ? Uri.base.path : vgWebDefaultAppPath();
    context.go(path);
    return;
  }

  toast(VGCopy.checkoutPendingToast);
  context.go('/pricing?checkout=pending');
}
