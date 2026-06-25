import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/vg_pill_button.dart';
import '../../services/vg_subscription_store.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../screens/subscription/vg_subscription_success_screen.dart';

Future<void> showVGPaywallPromoSheet(BuildContext context) async {
  await VGSubscriptionStore.startPromoTimer();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const VGPaywallPromoSheet(),
  );
}

class VGPaywallPromoSheet extends StatefulWidget {
  const VGPaywallPromoSheet({super.key});

  @override
  State<VGPaywallPromoSheet> createState() => _VGPaywallPromoSheetState();
}

class _VGPaywallPromoSheetState extends State<VGPaywallPromoSheet> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _loadTimer());
  }

  Future<void> _loadTimer() async {
    final expiry = await VGSubscriptionStore.promoExpiry();
    if (expiry == null) {
      await VGSubscriptionStore.startPromoTimer();
      if (mounted) setState(() => _remaining = const Duration(minutes: 30));
      return;
    }
    final diff = expiry.difference(DateTime.now());
    if (mounted) setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '00 : 00 : $m : $s';
  }

  Future<void> _purchase() async {
    await VGSubscriptionStore.purchaseMock(planName: 'promo_annual');
    await VGSubscriptionStore.markPromoShownThisSession();
    if (!mounted) return;
    finish(context);
    VGSubscriptionSuccessScreen().launch(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bmSpecialColor, bmSpecialColorDark]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () async {
                  await VGSubscriptionStore.markPromoShownThisSession();
                  finish(context);
                },
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
            Text(VGCopy.paywallPromoTitle, style: boldTextStyle(color: Colors.white, size: 22), textAlign: TextAlign.center),
            8.height,
            Text(VGCopy.paywallPromoSubtitle, style: primaryTextStyle(color: Colors.white70), textAlign: TextAlign.center),
            16.height,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(8)),
              child: Text('${VGCopy.paywallYearlyPrice}${VGCopy.paywallYearlyPeriod} · ${VGCopy.paywallDiscountBadge}', style: boldTextStyle(color: Colors.white, size: 14)),
            ),
            12.height,
            Text(VGCopy.paywallExpiresIn, style: secondaryTextStyle(color: Colors.white70, size: 12)),
            Text(_format(_remaining), style: boldTextStyle(color: Colors.white, size: 18)),
            20.height,
            VGPillButton(label: VGCopy.paywallStartTrial, onTap: _purchase),
          ],
        ),
      ),
    );
  }
}
