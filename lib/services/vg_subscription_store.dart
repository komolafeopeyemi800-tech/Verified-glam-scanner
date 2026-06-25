import 'package:nb_utils/nb_utils.dart';

import '../utils/vg_constants.dart';
import 'vg_referral_bonus_store.dart';

/// Mock subscription state before RevenueCat integration (Phase 7).
class VGSubscriptionStore {
  static Future<bool> isPro() async {
    return getBoolAsync(vgSubscriptionIsProKey, defaultValue: false);
  }

  static Future<String> plan() async {
    return getStringAsync(vgSubscriptionPlanKey, defaultValue: 'free');
  }

  static Future<void> setPro({required bool value, String planName = 'pro'}) async {
    await setValue(vgSubscriptionIsProKey, value);
    await setValue(vgSubscriptionPlanKey, value ? planName : 'free');
  }

  static Future<int> freeScanCount() async {
    return getIntAsync(vgSubscriptionFreeScanCountKey, defaultValue: 0);
  }

  static Future<void> incrementFreeScanCount() async {
    final count = await freeScanCount();
    await setValue(vgSubscriptionFreeScanCountKey, count + 1);
  }

  static Future<void> resetSessionCounters() async {
    await setValue(vgSubscriptionFreeScanCountKey, 0);
    await setValue(vgSubscriptionPromoShownSessionKey, false);
  }

  static Future<bool> purchaseMock({String planName = 'annual'}) async {
    await setPro(value: true, planName: planName);
    return true;
  }

  static Future<bool> restoreMock() async {
    return isPro();
  }

  static Future<bool> shouldShowPostOnboardingPaywall() async {
    if (await isPro()) return false;
    return !getBoolAsync(vgSubscriptionPostOnboardingPaywallShownKey, defaultValue: false);
  }

  static Future<void> markPostOnboardingPaywallShown() async {
    await setValue(vgSubscriptionPostOnboardingPaywallShownKey, true);
  }

  static Future<bool> shouldBlockProFeature() async {
    if (kVGLocalDevMode) return false;
    return !(await isPro());
  }

  static Future<bool> shouldShowPromoAfterDismiss() async {
    if (await isPro()) return false;
    if (getBoolAsync(vgSubscriptionPromoShownSessionKey, defaultValue: false)) return false;
    return getBoolAsync(vgSubscriptionPostOnboardingPaywallShownKey, defaultValue: false);
  }

  static Future<void> markPromoShownThisSession() async {
    await setValue(vgSubscriptionPromoShownSessionKey, true);
  }

  static Future<DateTime?> promoExpiry() async {
    final raw = getStringAsync(vgSubscriptionPromoExpiryKey);
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  static Future<void> startPromoTimer() async {
    if ((await promoExpiry()) != null) return;
    await setValue(vgSubscriptionPromoExpiryKey, DateTime.now().add(const Duration(minutes: 30)).toIso8601String());
  }

  static Future<bool> shouldShowPaywallBeforeResults() async {
    if (kVGLocalDevMode) return false;
    if (await isPro()) return false;
    if (await VGReferralBonusStore.consumeBonusScan()) return false;
    final count = await freeScanCount();
    return count > 0 && count % 3 == 0;
  }
}
