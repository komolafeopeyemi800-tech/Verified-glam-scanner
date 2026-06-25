import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/subscription/vg_paywall_plans_section.dart';
import '../../../components/vg/vg_loading_overlay.dart';
import '../../../screens/subscription/vg_subscription_success_screen.dart';
import '../../../services/vg_subscription_store.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../vg_web_breakpoints.dart';

/// Desktop paywall — scrollable dialog (SaaS-style plan cards + compare table).
Future<void> showVGWebPaywallDialog(
  BuildContext context, {
  VoidCallback? onDismiss,
}) async {
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: VGWebBreakpoints.contentPadding(ctx),
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 960,
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
        ),
        child: _VGWebPaywallDialogBody(onDismiss: onDismiss),
      ),
    ),
  );
}

class _VGWebPaywallDialogBody extends StatefulWidget {
  final VoidCallback? onDismiss;

  const _VGWebPaywallDialogBody({this.onDismiss});

  @override
  State<_VGWebPaywallDialogBody> createState() => _VGWebPaywallDialogBodyState();
}

class _VGWebPaywallDialogBodyState extends State<_VGWebPaywallDialogBody> {
  final _plansKey = GlobalKey<VGPaywallPlansSectionState>();

  Future<void> _purchase() async {
    final planId = vgPaywallPlanIdFromSection(_plansKey);
    await VGSubscriptionStore.purchaseMock(planName: planId);
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onDismiss?.call();
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
      Navigator.of(context).pop();
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [bmSpecialColorDark, bmSpecialColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(VGCopy.paywallTitle, style: boldTextStyle(color: Colors.white, size: 20)),
                      const SizedBox(height: 2),
                      Text(VGCopy.paywallSubtitle, style: primaryTextStyle(color: Colors.white70, size: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDismiss?.call();
                  },
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: VGPaywallPlansSection(
                key: _plansKey,
                onPurchase: _purchase,
                onRestore: _restore,
                theme: VGPaywallTheme.light,
                compact: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
