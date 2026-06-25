import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/subscription/vg_paywall_plans_section.dart';
import '../../components/vg/vg_loading_overlay.dart';
import '../../services/vg_subscription_store.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import 'vg_subscription_success_screen.dart';

enum VGPaywallEntry { onboarding, feature, profile, promo }

class VGPaywallScreen extends StatefulWidget {
  final VGPaywallEntry entry;
  final VoidCallback? onDismiss;

  const VGPaywallScreen({super.key, this.entry = VGPaywallEntry.onboarding, this.onDismiss});

  @override
  State<VGPaywallScreen> createState() => _VGPaywallScreenState();
}

class _VGPaywallScreenState extends State<VGPaywallScreen> {
  final _plansKey = GlobalKey<VGPaywallPlansSectionState>();

  Future<void> _purchase() async {
    final planId = vgPaywallPlanIdFromSection(_plansKey);
    await VGSubscriptionStore.purchaseMock(planName: planId);
    if (!mounted) return;
    finish(context);
    VGSubscriptionSuccessScreen().launch(context);
  }

  Future<void> _restore() async {
    VGLoadingOverlay.show(context);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    VGLoadingOverlay.hide(context);
    final restored = await VGSubscriptionStore.restoreMock();
    toast(restored ? VGCopy.paywallRestoreSuccess : VGCopy.paywallRestoreEmpty);
    if (restored && mounted) {
      finish(context);
      widget.onDismiss?.call();
    }
  }

  void _dismiss() {
    finish(context);
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: _dismiss,
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.workspace_premium, color: bmPrimaryColor, size: 56),
                    12.height,
                    Text(VGCopy.paywallTitle, style: boldTextStyle(color: Colors.white, size: 24), textAlign: TextAlign.center),
                    8.height,
                    Text(VGCopy.paywallSubtitle, style: primaryTextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    24.height,
                    VGPaywallPlansSection(
                      key: _plansKey,
                      onPurchase: _purchase,
                      onRestore: _restore,
                      theme: VGPaywallTheme.dark,
                      compact: true,
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
