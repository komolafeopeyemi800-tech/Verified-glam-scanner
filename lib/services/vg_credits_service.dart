import 'package:flutter/foundation.dart';

import '../utils/vg_credit_constants.dart';
import 'supabase/vg_supabase_auth_service.dart';
import 'supabase/vg_supabase_init.dart';
import 'vg_analysis_mode.dart';
import 'vg_subscription_store.dart';

/// Point-in-time subscription credit state from Supabase profiles.
class VGCreditSnapshot {
  final int balance;
  final int allocated;
  final String subscriptionPlan;
  final String subscriptionStatus;
  final bool isPro;
  final DateTime? periodEnd;

  const VGCreditSnapshot({
    required this.balance,
    required this.allocated,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    required this.isPro,
    this.periodEnd,
  });

  static const empty = VGCreditSnapshot(
    balance: 0,
    allocated: 0,
    subscriptionPlan: kSubscriptionPlanFree,
    subscriptionStatus: 'free',
    isPro: false,
  );

  String get planDisplayName {
    switch (subscriptionPlan) {
      case kSubscriptionPlanAnnual:
        return 'Yearly Pro';
      case kSubscriptionPlanProWeekly:
        return 'Pro Weekly';
      default:
        return 'Free plan';
    }
  }

  double get progressFraction {
    if (allocated <= 0) return 0;
    return (balance / allocated).clamp(0.0, 1.0);
  }
}

/// One row from credit_transactions.
class VGCreditTransaction {
  final String id;
  final int amount;
  final String kind;
  final String description;
  final String? featureType;
  final int? balanceAfter;
  final DateTime createdAt;

  const VGCreditTransaction({
    required this.id,
    required this.amount,
    required this.kind,
    required this.description,
    this.featureType,
    this.balanceAfter,
    required this.createdAt,
  });

  factory VGCreditTransaction.fromRow(Map<String, dynamic> row) {
    return VGCreditTransaction(
      id: row['id']?.toString() ?? '',
      amount: (row['amount'] as num?)?.toInt() ?? 0,
      kind: row['kind']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      featureType: row['feature_type']?.toString(),
      balanceAfter: (row['balance_after'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// Subscription credit balance from Supabase profiles.
class VGCreditsService {
  VGCreditsService._();

  static int? _cachedBalance;
  static String? _cachedPlan;
  static VGCreditSnapshot? _cachedSnapshot;

  static int? get cachedBalance => _cachedBalance;

  static String? get cachedPlan => _cachedPlan;

  static VGCreditSnapshot? get cachedSnapshot => _cachedSnapshot;

  static void setCachedBalance(int? balance, {String? plan}) {
    _cachedBalance = balance;
    if (plan != null) _cachedPlan = plan;
  }

  static Future<VGCreditSnapshot?> fetchSnapshot() async {
    if (!VGAnalysisMode.useCloud || !VGSupabaseAuthService.isSignedIn) {
      return null;
    }
    try {
      final userId = VGSupabaseAuthService.currentUser!.id;
      final row = await VGSupabaseInit.client
          .from('profiles')
          .select(
            'credits_balance, credits_allocated, subscription_plan, '
            'subscription_status, is_pro, subscription_current_period_end',
          )
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;

      final isPro = row['is_pro'] == true;
      final plan = row['subscription_plan'] as String? ?? kSubscriptionPlanFree;
      final status = row['subscription_status'] as String? ?? 'free';
      final balance = (row['credits_balance'] as num?)?.toInt() ?? 0;
      final allocated = isPro
          ? ((row['credits_allocated'] as num?)?.toInt() ?? creditsAllocationForPlan(plan))
          : 0;
      final periodEndRaw = row['subscription_current_period_end']?.toString();
      final periodEnd = periodEndRaw != null && periodEndRaw.isNotEmpty
          ? DateTime.tryParse(periodEndRaw)
          : null;

      final snapshot = VGCreditSnapshot(
        balance: isPro ? balance : 0,
        allocated: allocated,
        subscriptionPlan: isPro ? plan : kSubscriptionPlanFree,
        subscriptionStatus: status,
        isPro: isPro,
        periodEnd: periodEnd,
      );

      _cachedSnapshot = snapshot;
      _cachedBalance = snapshot.balance;
      _cachedPlan = snapshot.subscriptionPlan;
      await VGSubscriptionStore.setPro(value: isPro, planName: isPro ? plan : kSubscriptionPlanFree);
      return snapshot;
    } catch (e) {
      debugPrint('VGCreditsService.fetchSnapshot: $e');
      return _cachedSnapshot;
    }
  }

  static Future<int?> fetchBalance() async {
    final snapshot = await fetchSnapshot();
    return snapshot?.balance;
  }

  static Future<List<VGCreditTransaction>> fetchTransactions({
    DateTime? from,
    DateTime? to,
    bool earnedOnly = false,
    bool usedOnly = false,
    int limit = 50,
  }) async {
    if (!VGAnalysisMode.useCloud || !VGSupabaseAuthService.isSignedIn) {
      return const [];
    }
    try {
      final userId = VGSupabaseAuthService.currentUser!.id;
      var query = VGSupabaseInit.client
          .from('credit_transactions')
          .select()
          .eq('user_id', userId);

      if (from != null) {
        query = query.gte('created_at', from.toUtc().toIso8601String());
      }
      if (to != null) {
        final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
        query = query.lte('created_at', end.toUtc().toIso8601String());
      }
      if (earnedOnly) {
        query = query.gt('amount', 0);
      } else if (usedOnly) {
        query = query.lt('amount', 0);
      }

      final rows = await query.order('created_at', ascending: false).limit(limit);
      return (rows as List)
          .map((e) => VGCreditTransaction.fromRow(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      debugPrint('VGCreditsService.fetchTransactions: $e');
      return const [];
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
    _cachedSnapshot = VGCreditSnapshot(
      balance: allocated,
      allocated: allocated,
      subscriptionPlan: plan,
      subscriptionStatus: 'active',
      isPro: true,
    );

    if (!VGAnalysisMode.useCloud || !VGSupabaseAuthService.isSignedIn) {
      return;
    }

    final userId = VGSupabaseAuthService.currentUser!.id;
    await VGSupabaseInit.client.from('profiles').update({
      'is_pro': true,
      'subscription_plan': plan,
      'subscription_status': 'active',
      'credits_balance': allocated,
      'credits_allocated': allocated,
      'credits_period_key': periodKey,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  static Future<void> syncFromResponse(dynamic data) async {
    if (data is Map && data['creditsRemaining'] != null) {
      final remaining = data['creditsRemaining'];
      final balance = remaining is int
          ? remaining
          : remaining is num
              ? remaining.toInt()
              : null;
      if (balance != null) {
        _cachedBalance = balance;
        if (_cachedSnapshot != null) {
          _cachedSnapshot = VGCreditSnapshot(
            balance: balance,
            allocated: _cachedSnapshot!.allocated,
            subscriptionPlan: _cachedSnapshot!.subscriptionPlan,
            subscriptionStatus: _cachedSnapshot!.subscriptionStatus,
            isPro: _cachedSnapshot!.isPro,
            periodEnd: _cachedSnapshot!.periodEnd,
          );
        }
      }
    }
  }

  static Future<bool> hasEnoughForGeneration() async {
    final snapshot = await fetchSnapshot();
    if (snapshot == null || !snapshot.isPro) return false;
    return snapshot.balance >= kCreditsPerGeneration;
  }
}
