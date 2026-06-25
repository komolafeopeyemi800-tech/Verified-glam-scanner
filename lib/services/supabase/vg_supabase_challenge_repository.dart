import '../../models/vg_challenge_day.dart';
import '../../models/vg_challenge_plan.dart';
import '../../models/vg_challenge_progress.dart';
import 'vg_supabase_auth_service.dart';
import 'vg_supabase_init.dart';

class VGSupabaseChallengeRepository {
  Future<void> enqueueNotificationJob({
    required String challengeId,
    required int dayNumber,
    required String kind,
    required DateTime scheduledFor,
    required Map<String, dynamic> payload,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return;
    final dedupeKey = '$challengeId:$dayNumber:$kind:${scheduledFor.toIso8601String()}';
    try {
      await VGSupabaseInit.client.from('challenge_notification_jobs').insert({
        'user_id': userId,
        'challenge_id': challengeId,
        'day_number': dayNumber,
        'kind': kind,
        'scheduled_for': scheduledFor.toIso8601String(),
        'payload': payload,
        'status': 'pending',
        'dedupe_key': dedupeKey,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Ignore duplicate notification jobs when dedupe_key already exists.
    }
  }

  Future<void> cancelPendingJobs({
    required String challengeId,
    required int dayNumber,
    List<String>? kinds,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return;
    var query = VGSupabaseInit.client
        .from('challenge_notification_jobs')
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('challenge_id', challengeId)
        .eq('day_number', dayNumber)
        .eq('status', 'pending');
    if (kinds != null && kinds.isNotEmpty) {
      query = query.inFilter('kind', kinds);
    }
    await query;
  }

  Future<void> updateNotificationPrefTime({
    required String challengeId,
    required String prefTime,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return;
    await VGSupabaseInit.client.from('challenge_plans').update({
      'notification_pref_time': prefTime,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', challengeId).eq('user_id', userId);
  }

  Future<VGChallengePlan?> fetchActivePlan() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return null;

    final row = await VGSupabaseInit.client
        .from('challenge_plans')
        .select()
        .eq('user_id', userId)
        .eq('is_completed', false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;

    final planRow = Map<String, dynamic>.from(row);
    final challengeId = planRow['id'] as String;
    final dayRows = await VGSupabaseInit.client
        .from('challenge_days')
        .select()
        .eq('challenge_id', challengeId)
        .order('day_number');
    final progressRows = await VGSupabaseInit.client
        .from('challenge_progress')
        .select()
        .eq('challenge_id', challengeId)
        .order('day_number');

    final progressRowsList = (progressRows as List).cast<Map<String, dynamic>>();
    await _unlockReadyDays(challengeId, progressRowsList);
    final refreshed = await VGSupabaseInit.client
        .from('challenge_progress')
        .select()
        .eq('challenge_id', challengeId)
        .order('day_number');
    return _toPlan(planRow, dayRows as List, refreshed as List);
  }

  Future<void> createPlan(VGChallengePlan plan) async {
    await VGSupabaseInit.client.from('challenge_plans').insert({
      'id': plan.challengeId,
      'user_id': plan.userId,
      'source_scan_id': plan.sourceScanId,
      'issue_tag': plan.issueTag,
      'severity': plan.severity,
      'duration_days': plan.durationDays,
      'title': plan.title,
      'intro_message': plan.introMessage,
      'disclaimer': plan.disclaimer,
      'completed_days': plan.progress.completedDays,
      'last_completed_at': plan.progress.lastCompletedAt?.toIso8601String(),
      'next_unlock_at': plan.progress.nextUnlockAt?.toIso8601String(),
      'is_completed': plan.progress.isCompleted,
      'streak_count': plan.progress.streakCount,
      'notification_pref_time': plan.progress.notificationPrefTime ?? '18:00',
      'created_at': plan.createdAt.toIso8601String(),
      'updated_at': plan.updatedAt.toIso8601String(),
    });

    await VGSupabaseInit.client.from('challenge_days').insert(
          plan.days
              .map((d) => {
                    'challenge_id': plan.challengeId,
                    'user_id': plan.userId,
                    'day_number': d.dayNumber,
                    'title': d.title,
                    'main_task': d.mainTask,
                    'support_task': d.supportTask,
                    'why_line': d.whyLine,
                    'est_minutes': d.estMinutes,
                  })
              .toList(),
        );

    await VGSupabaseInit.client.from('challenge_progress').insert(
          plan.days
              .map((d) => {
                    'challenge_id': plan.challengeId,
                    'user_id': plan.userId,
                    'day_number': d.dayNumber,
                    'status': d.dayNumber == 1 ? 'unlocked' : 'locked',
                    'unlocked_at': d.dayNumber == 1 ? DateTime.now().toIso8601String() : null,
                  })
              .toList(),
        );
  }

  Future<void> markDayComplete({
    required VGChallengePlan plan,
    required int dayNumber,
    required DateTime completedAt,
  }) async {
    await VGSupabaseInit.client.from('challenge_progress').update({
      'status': 'done',
      'completed_at': completedAt.toIso8601String(),
      'updated_at': completedAt.toIso8601String(),
    }).eq('challenge_id', plan.challengeId).eq('day_number', dayNumber).eq('status', 'unlocked');

    final nextDay = dayNumber + 1;
    final nextUnlockAt = completedAt.add(const Duration(hours: 24));
    if (nextDay <= plan.durationDays) {
      await VGSupabaseInit.client.from('challenge_progress').update({
        'status': 'locked',
        'unlocked_at': nextUnlockAt.toIso8601String(),
        'unlock_notified_at': null,
        'reminder_sent_at': null,
        'updated_at': completedAt.toIso8601String(),
      }).eq('challenge_id', plan.challengeId).eq('day_number', nextDay);
    }

    final completedDays = dayNumber;
    final today = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final lastDoneDate = plan.progress.lastCompletedAt != null
        ? DateTime(
            plan.progress.lastCompletedAt!.year,
            plan.progress.lastCompletedAt!.month,
            plan.progress.lastCompletedAt!.day,
          )
        : null;
    var streak = plan.progress.streakCount;
    if (lastDoneDate == null) {
      streak = 1;
    } else {
      final gap = today.difference(lastDoneDate).inDays;
      streak = gap <= 1 ? streak + 1 : 1;
    }
    final existingBest = plan.progress.bestStreak;
    final bestStreak = streak > existingBest ? streak : existingBest;

    await VGSupabaseInit.client.from('challenge_plans').update({
      'completed_days': completedDays,
      'last_completed_at': completedAt.toIso8601String(),
      'last_done_date': today.toIso8601String().split('T').first,
      'next_unlock_at': completedDays >= plan.durationDays ? null : nextUnlockAt.toIso8601String(),
      'is_completed': completedDays >= plan.durationDays,
      'streak_count': streak,
      'current_streak': streak,
      'best_streak': bestStreak,
      'updated_at': completedAt.toIso8601String(),
    }).eq('id', plan.challengeId);

    if (completedDays >= plan.durationDays) {
      await _awardCompletionArtifacts(
        plan: plan,
        completedAt: completedAt,
        streak: streak,
        bestStreak: bestStreak,
      );
    }
  }

  Future<void> _awardCompletionArtifacts({
    required VGChallengePlan plan,
    required DateTime completedAt,
    required int streak,
    required int bestStreak,
  }) async {
    final issueCode = _normalizeIssueCode(plan.issueTag);
    final completedCount = await _countCompletedChallenges(plan.userId);
    final consecutiveCount = await _countConsecutiveCompletedChallenges(plan.userId);

    await _insertBadgeIfNew(
      userId: plan.userId,
      badgeCode: 'skin_starter',
      badgeTitle: 'Skin Starter',
      challengeId: plan.challengeId,
      earnedAt: completedAt,
    );

    if (plan.durationDays >= 7) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'seven_day_champion',
        badgeTitle: '7-Day Champion',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    } else if (plan.durationDays >= 5) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'five_day_finisher',
        badgeTitle: '5-Day Finisher',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    } else {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'three_day_warrior',
        badgeTitle: '3-Day Warrior',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }

    if (issueCode == 'dryness' || plan.title.toLowerCase().contains('hydration')) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'hydration_hero',
        badgeTitle: 'Hydration Hero',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }
    if (issueCode == 'pigmentation' || plan.title.toLowerCase().contains('glow') || plan.title.toLowerCase().contains('bright')) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'glow_getter',
        badgeTitle: 'Glow Getter',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }
    if (issueCode == 'sensitivity' || plan.title.toLowerCase().contains('calm')) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'zen_skin',
        badgeTitle: 'Zen Skin',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }

    if (consecutiveCount >= 3) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'streak_master',
        badgeTitle: 'Streak Master',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }

    if (completedCount >= 5) {
      await _insertBadgeIfNew(
        userId: plan.userId,
        badgeCode: 'skin_royalty',
        badgeTitle: 'Skin Royalty',
        challengeId: plan.challengeId,
        earnedAt: completedAt,
      );
    }

    await VGSupabaseInit.client.from('challenge_reward_cards').insert({
      'user_id': plan.userId,
      'challenge_id': plan.challengeId,
      'challenge_title': plan.title,
      'issue_tag': plan.issueTag,
      'completed_on': completedAt.toIso8601String(),
      'message': 'You showed up for your skin every day. That is what glow is made of.',
    });
  }

  Future<int> _countCompletedChallenges(String userId) async {
    final rows = await VGSupabaseInit.client
        .from('challenge_plans')
        .select('id')
        .eq('user_id', userId)
        .eq('is_completed', true);
    return (rows as List).length;
  }

  Future<int> _countConsecutiveCompletedChallenges(String userId) async {
    final rows = await VGSupabaseInit.client
        .from('challenge_plans')
        .select('id,is_completed,completed_days,duration_days,last_completed_at')
        .eq('user_id', userId)
        .eq('is_completed', true)
        .order('last_completed_at', ascending: false)
        .limit(10);
    var streak = 0;
    for (final row in rows as List) {
      final completedDays = (row['completed_days'] as num?)?.toInt() ?? 0;
      final durationDays = (row['duration_days'] as num?)?.toInt() ?? 0;
      if (row['is_completed'] != true || completedDays < durationDays) break;
      streak++;
    }
    return streak;
  }

  String _normalizeIssueCode(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('acne') || v.contains('pimple') || v.contains('breakout')) return 'acne';
    if (v.contains('pigment') || v.contains('dark') || v.contains('spot') || v.contains('glow')) return 'pigmentation';
    if (v.contains('texture') || v.contains('scar')) return 'texture';
    if (v.contains('aging') || v.contains('sag') || v.contains('firm')) return 'aging';
    if (v.contains('sensitive') || v.contains('redness') || v.contains('calm')) return 'sensitivity';
    if (v.contains('oily') || v.contains('pore') || v.contains('sebum')) return 'oily';
    if (v.contains('dry') || v.contains('dehydrat') || v.contains('flaky') || v.contains('hydration')) return 'dryness';
    if (v.contains('uneven') || v.contains('tone') || v.contains('rosacea')) return 'uneven_tone';
    return 'acne';
  }

  Future<void> _insertBadgeIfNew({
    required String userId,
    required String badgeCode,
    required String badgeTitle,
    required String challengeId,
    required DateTime earnedAt,
  }) async {
    final existing = await VGSupabaseInit.client
        .from('challenge_badges')
        .select('id')
        .eq('user_id', userId)
        .eq('badge_code', badgeCode)
        .maybeSingle();
    if (existing != null) return;
    await VGSupabaseInit.client.from('challenge_badges').insert({
      'user_id': userId,
      'badge_code': badgeCode,
      'badge_title': badgeTitle,
      'challenge_id': challengeId,
      'earned_at': earnedAt.toIso8601String(),
    });
  }

  Future<void> archiveActivePlans() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return;
    await VGSupabaseInit.client
        .from('challenge_plans')
        .update({
          'is_completed': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_completed', false);
  }

  Future<List<Map<String, dynamic>>> fetchUserBadges() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return const [];
    final rows = await VGSupabaseInit.client
        .from('challenge_badges')
        .select('badge_code,badge_title,earned_at')
        .eq('user_id', userId)
        .order('earned_at', ascending: false);
    return (rows as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> latestRewardCard() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return null;
    final row = await VGSupabaseInit.client
        .from('challenge_reward_cards')
        .select()
        .eq('user_id', userId)
        .order('completed_on', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  Future<void> _unlockReadyDays(
    String challengeId,
    List<Map<String, dynamic>> progressRows,
  ) async {
    final now = DateTime.now();
    for (final row in progressRows) {
      if (row['status'] != 'locked') continue;
      final unlockedAt = DateTime.tryParse((row['unlocked_at'] as String?) ?? '');
      if (unlockedAt != null && (unlockedAt.isBefore(now) || unlockedAt.isAtSameMomentAs(now))) {
        await VGSupabaseInit.client.from('challenge_progress').update({
          'status': 'unlocked',
          'updated_at': now.toIso8601String(),
        }).eq('id', row['id']);
      }
    }
  }

  VGChallengePlan _toPlan(
    Map<String, dynamic> planRow,
    List dayRows,
    List progressRows,
  ) {
    final days = dayRows
        .map(
          (e) => VGChallengeDay(
            dayNumber: (e['day_number'] as num).toInt(),
            title: (e['title'] as String?) ?? '',
            mainTask: (e['main_task'] as String?) ?? '',
            supportTask: (e['support_task'] as String?) ?? '',
            whyLine: (e['why_line'] as String?) ?? '',
            estMinutes: (e['est_minutes'] as num?)?.toInt() ?? 10,
          ),
        )
        .toList();

    var completedDays = 0;
    DateTime? nextUnlockAt;
    final planUnlockRaw = planRow['next_unlock_at'] as String?;
    if (planUnlockRaw != null) {
      nextUnlockAt = DateTime.tryParse(planUnlockRaw);
    }
    for (final p in progressRows) {
      if (p['status'] == 'done') completedDays++;
      if (nextUnlockAt == null) {
        final unlockedAt = p['unlocked_at'] as String?;
        if (p['status'] == 'locked' && unlockedAt != null) {
          nextUnlockAt = DateTime.tryParse(unlockedAt);
        }
      }
    }
    final duration = (planRow['duration_days'] as num?)?.toInt() ?? days.length;
    final currentDay = (completedDays + 1).clamp(1, duration).toInt();
    final existingBest = (planRow['best_streak'] as num?)?.toInt() ??
        (planRow['streak_count'] as num?)?.toInt() ??
        0;
    final progress = VGChallengeProgress(
      completedDays: completedDays,
      currentDay: currentDay,
      isCompleted: planRow['is_completed'] == true || completedDays >= duration,
      lastCompletedAt: planRow['last_completed_at'] != null
          ? DateTime.tryParse(planRow['last_completed_at'] as String)
          : null,
      nextUnlockAt: nextUnlockAt,
      streakCount: (planRow['streak_count'] as num?)?.toInt() ?? completedDays,
      bestStreak: existingBest,
      notificationPrefTime: planRow['notification_pref_time'] as String?,
    );

    return VGChallengePlan(
      challengeId: planRow['id'] as String,
      userId: planRow['user_id'] as String,
      sourceScanId: planRow['source_scan_id'] as String?,
      issueTag: (planRow['issue_tag'] as String?) ?? 'glow',
      severity: (planRow['severity'] as String?) ?? 'low',
      durationDays: duration,
      title: (planRow['title'] as String?) ?? 'Beauty Routine Challenge',
      introMessage: (planRow['intro_message'] as String?) ?? '',
      disclaimer: (planRow['disclaimer'] as String?) ?? '',
      days: days,
      progress: progress,
      createdAt: DateTime.tryParse(planRow['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(planRow['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
