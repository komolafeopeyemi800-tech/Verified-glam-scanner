import 'package:flutter/foundation.dart';

import '../utils/vg_credit_constants.dart';
import 'supabase/vg_supabase_auth_service.dart';
import 'supabase/vg_supabase_init.dart';
import 'vg_analysis_mode.dart';
import 'vg_subscription_store.dart';

/// Subscription credit balance from Supabase profiles.
class VGCreditsService {
  VGCreditsService._();

  static int? _cachedBalance;
  static String? _cachedPlan;

  static int? get cachedBalance => _cachedBalance;

  static String? get cachedPlan => _cachedPlan;

  static void setCachedBalance(int? balance, {String? plan}) {
    _cachedBalance = balance;
    if (plan != null) _cachedPlan = plan;
  }

  static Future<int?> fetchBalance() async {
    if (!VGAnalysisMode.useCloud || !VGSupabaseAuthService.isSignedIn) {
      return null;
    }
    try {
      final userId = VGSupabaseAuthService.currentUser!.id;
      final row = await VGSupabaseInit.client
          .from('profiles')
          .select('credits_balance, subscription_plan, is_pro')
          .eq('id', userId)
          .maybeSingle();
      if (row == null || row['is_pro'] != true) {
        _cachedBalance = null;
        _cachedPlan = kSubscriptionPlanFree;
        await VGSubscriptionStore.setPro(value: false);
        return null;
      }
      final balance = row['credits_balance'] as int?;
      final plan = row['subscription_plan'] as String? ?? kSubscriptionPlanAnnual;
      _cachedBalance = balance;
      _cachedPlan = plan;
      await VGSubscriptionStore.setPro(value: true, planName: plan);
      return balance;
    } catch (e) {
      debugPrint('VGCreditsService.fetchBalance: $e');
      return _cachedBalance;
    }
  }

  static Future<void> grantOnMockPurchase(String planId) async {
    final plan = planId == kSubscriptionPlanProWeekly
        ? kSubscriptionPlanProWeekly
        : kSubscriptionPlanAnnual;
    final allocated = creditsAllocationForPlan(plan);
    final periodKey = currentCreditsPeriodKey(plan);

    _cachedBalance = allocated;
    _cachedPlan = plan;

    if (!VGAnalysisMode.useCloud || !VGSupabaseAuthService.isSignedIn) {
      return;
    }

    final userId = VGSupabaseAuthService.currentUser!.id;
    await VGSupabaseInit.client.from('profiles').update({
      'is_pro': true,
      'subscription_plan': plan,
      'credits_balance': allocated,
      'credits_allocated': allocated,
      'credits_period_key': periodKey,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  static Future<void> syncFromResponse(dynamic data) async {
    if (data is Map && data['creditsRemaining'] != null) {
      final remaining = data['creditsRemaining'];
      if (remaining is int) {
        _cachedBalance = remaining;
      } else if (remaining is num) {
        _cachedBalance = remaining.toInt();
      }
    }
  }

  static Future<bool> hasEnoughForGeneration() async {
    final balance = await fetchBalance();
    if (balance == null) return true;
    return balance >= kCreditsPerGeneration;
  }
}
