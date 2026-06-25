import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/challenge/vg_challenge_day_row.dart';
import '../../components/vg/challenge/vg_challenge_unlock_countdown.dart';
import '../../components/vg/challenge/vg_day_progress_strip.dart';
import '../../components/vg/vg_main_app_bar.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../main.dart';
import '../../models/vg_challenge_day.dart';
import '../../models/vg_feature_model.dart';
import '../../models/vg_challenge_plan.dart';
import '../../services/vg_challenge_service.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_navigation.dart';
import '../../web/vg_web_breakpoints.dart';
import '../../web/vg_web_navigation.dart';
import '../../web/screens/challenge/vg_web_routine_challenge_panel.dart';
import 'vg_challenge_day_task_screen.dart';
import 'vg_challenge_reward_screen.dart';

/// Screen 2 — challenge overview (progress, streak, day list).
class VGRoutineChallengeScreen extends StatefulWidget {
  final VGFeatureModel feature;
  final int? initialDay;

  const VGRoutineChallengeScreen({super.key, required this.feature, this.initialDay});

  @override
  State<VGRoutineChallengeScreen> createState() => _VGRoutineChallengeScreenState();
}

class _VGRoutineChallengeScreenState extends State<VGRoutineChallengeScreen> {
  VGChallengePlan? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final plan = await VGChallengeService.loadOrAssign();
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _loading = false;
    });
    if (plan?.progress.isCompleted == true) {
      _maybeOpenReward();
      return;
    }
    _maybeOpenInitialDay(plan);
  }

  void _maybeOpenInitialDay(VGChallengePlan? plan) {
    final day = widget.initialDay;
    if (plan == null || day == null || day < 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final match = plan.days.where((d) => d.dayNumber == day).firstOrNull;
      if (match == null) return;
      final state = _dayState(plan, match);
      if (state == VGChallengeDayRowState.locked || state == VGChallengeDayRowState.upcoming) {
        return;
      }
      if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
        vgWebOpenChallengeDay(context, day);
        return;
      }
      VGChallengeDayTaskScreen(
        feature: widget.feature,
        plan: plan,
        dayNumber: day,
      ).launch(context).then((_) => _load());
    });
  }

  Future<void> _maybeOpenReward() async {
    final reward = await VGChallengeService.latestRewardCard();
    if (!mounted || reward == null) return;
    if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
      vgWebOpenReward(context, reward: reward, feature: widget.feature);
      return;
    }
    await VGChallengeRewardScreen(reward: reward, feature: widget.feature).launch(context);
  }

  void _openDay(VGChallengePlan plan, VGChallengeDay day, VGChallengeDayRowState state) {
    if (state == VGChallengeDayRowState.locked || state == VGChallengeDayRowState.upcoming) {
      if (state == VGChallengeDayRowState.locked &&
          day.dayNumber == plan.progress.currentDay &&
          VGChallengeService.isCurrentDayLocked(plan)) {
        final remain = VGChallengeService.remainingToUnlock(plan);
        if (remain != null) {
          toast('${VGCopy.guideLockedUntil} ${_formatDuration(remain)}');
        }
      }
      return;
    }
    if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
      vgWebOpenChallengeDay(context, day.dayNumber);
      return;
    }
    VGChallengeDayTaskScreen(
      feature: widget.feature,
      plan: plan,
      dayNumber: day.dayNumber,
    ).launch(context).then((_) => _load());
  }

  VGChallengeDayRowState _dayState(VGChallengePlan plan, VGChallengeDay day) {
    if (day.dayNumber <= plan.progress.completedDays) {
      return VGChallengeDayRowState.completed;
    }
    if (day.dayNumber == plan.progress.currentDay && !plan.progress.isCompleted) {
      if (VGChallengeService.isCurrentDayLocked(plan)) {
        return VGChallengeDayRowState.locked;
      }
      return VGChallengeDayRowState.active;
    }
    if (day.dayNumber < plan.progress.currentDay) {
      return VGChallengeDayRowState.completed;
    }
    return VGChallengeDayRowState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
      return VGWebRoutineChallengePanel(feature: widget.feature, initialDay: widget.initialDay);
    }

    final plan = _plan;

    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      appBar: VGMainAppBar(title: plan?.title ?? VGCopy.guideRoutineChallenge),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : plan == null
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
                        8.height,
                        Text(plan.introMessage, style: secondaryTextStyle(size: 13, height: 1.45)),
                        16.height,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
                          ),
                          child: VGDayProgressStrip(plan: plan),
                        ),
                        14.height,
                        _streakCard(plan),
                        12.height,
                        _reminderTimeCard(plan),
                        if (!plan.progress.isCompleted &&
                            VGChallengeService.isCurrentDayLocked(plan) &&
                            plan.progress.nextUnlockAt != null) ...[
                          12.height,
                          _unlockCountdownCard(plan.progress.nextUnlockAt!),
                        ],
                        16.height,
                        Text(
                          VGCopy.challengeDayOfLabel.toUpperCase(),
                          style: boldTextStyle(color: appTextColorSecondary, size: 11),
                        ),
                        12.height,
                        ...plan.days.map((d) {
                          final state = _dayState(plan, d);
                          return VGChallengeDayRow(
                            day: d,
                            state: state,
                            onTap: () => _openDay(plan, d, state),
                          );
                        }),
                        if (plan.progress.isCompleted) ...[
                          8.height,
                          VGPillButton(
                            label: 'View reward card',
                            onTap: _maybeOpenReward,
                          ),
                          10.height,
                          VGPillButton(
                            label: VGCopy.guideRescanCta,
                            onTap: () => vgStartAnalysis(context, widget.feature),
                          ),
                        ] else if (plan.progress.currentDay <= plan.durationDays) ...[
                          8.height,
                          VGPillButton(
                            label: '${VGCopy.guideOpenRoutine} — Day ${plan.progress.currentDay}',
                            onTap: () {
                              final day = plan.days.firstWhere(
                                (d) => d.dayNumber == plan.progress.currentDay,
                                orElse: () => plan.days.first,
                              );
                              _openDay(plan, day, _dayState(plan, day));
                            },
                          ),
                        ],
                        12.height,
                        Text(plan.disclaimer, style: secondaryTextStyle(size: 11)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _unlockCountdownCard(DateTime unlockAt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bmSpecialColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(VGCopy.challengeNextDayUnlockTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 14)),
          8.height,
          VGChallengeUnlockCountdown(unlockAt: unlockAt),
          6.height,
          Text(VGCopy.challengeNextDayUnlockHint, style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }

  Widget _reminderTimeCard(VGChallengePlan plan) {
    final pref = plan.progress.notificationPrefTime ?? '18:00';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.challengeReminderTimeLabel, style: boldTextStyle(size: 13)),
                4.height,
                Text(pref, style: secondaryTextStyle(size: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _pickReminderTime(plan),
            child: Text('Change', style: boldTextStyle(color: bmSpecialColor, size: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderTime(VGChallengePlan plan) async {
    final parts = (plan.progress.notificationPrefTime ?? '18:00').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 18,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await VGChallengeService.updateNotificationPrefTime(plan, formatted);
    toast(VGCopy.challengeReminderTimeSaved);
    _load();
  }

  Widget _streakCard(VGChallengePlan plan) {
    final streak = plan.progress.streakCount;
    final best = plan.progress.bestStreak;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bmSecondBackgroundColorLight, bmLightScaffoldBackgroundColor],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak ${VGCopy.challengeStreakTitle}',
                  style: boldTextStyle(color: bmSpecialColorDark, size: 16),
                ),
                4.height,
                Text(
                  best > streak
                      ? '${VGCopy.challengeBestStreakLabel(best)} · ${VGCopy.challengeStreakSubtitle}'
                      : VGCopy.challengeStreakSubtitle,
                  style: secondaryTextStyle(size: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(VGCopy.guideNoActiveChallenge, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
            12.height,
            VGPillButton(
              label: VGCopy.guideStartChallenge,
              onTap: () => vgStartAnalysis(context, widget.feature),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }
}
