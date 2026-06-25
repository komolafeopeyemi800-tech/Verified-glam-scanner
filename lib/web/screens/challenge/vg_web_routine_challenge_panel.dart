import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/challenge/vg_challenge_day_row.dart';
import '../../../components/vg/challenge/vg_challenge_unlock_countdown.dart';
import '../../../components/vg/challenge/vg_day_progress_strip.dart';
import '../../../components/vg/vg_pill_button.dart';
import '../../../models/vg_challenge_day.dart';
import '../../../models/vg_challenge_plan.dart';
import '../../../models/vg_feature_model.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_navigation.dart';
import '../../vg_web_navigation.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Desktop challenge overview — stays inside the SaaS shell.
class VGWebRoutineChallengePanel extends StatefulWidget {
  final VGFeatureModel feature;
  final int? initialDay;

  const VGWebRoutineChallengePanel({
    super.key,
    required this.feature,
    this.initialDay,
  });

  @override
  State<VGWebRoutineChallengePanel> createState() => _VGWebRoutineChallengePanelState();
}

class _VGWebRoutineChallengePanelState extends State<VGWebRoutineChallengePanel> {
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
      if (state == VGChallengeDayRowState.locked || state == VGChallengeDayRowState.upcoming) return;
      vgWebOpenChallengeDay(context, day);
    });
  }

  Future<void> _maybeOpenReward() async {
    final reward = await VGChallengeService.latestRewardCard();
    if (!mounted || reward == null) return;
    vgWebOpenReward(context, reward: reward, feature: widget.feature);
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
    vgWebOpenChallengeDay(context, day.dayNumber);
  }

  VGChallengeDayRowState _dayState(VGChallengePlan plan, VGChallengeDay day) {
    if (day.dayNumber <= plan.progress.completedDays) return VGChallengeDayRowState.completed;
    if (day.dayNumber == plan.progress.currentDay && !plan.progress.isCompleted) {
      if (VGChallengeService.isCurrentDayLocked(plan)) return VGChallengeDayRowState.locked;
      return VGChallengeDayRowState.active;
    }
    if (day.dayNumber < plan.progress.currentDay) return VGChallengeDayRowState.completed;
    return VGChallengeDayRowState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: bmSpecialColor));
    }

    final plan = _plan;
    if (plan == null) {
      return VGWebPageScaffold(
        title: VGCopy.guideRoutineChallenge,
        onBack: () => vgWebGoProfile(context),
        backLabel: VGCopy.challengeBackToDashboard,
        child: VGWebDesktopCard(
          child: Column(
            children: [
              Text(VGCopy.guideNoActiveChallenge, textAlign: TextAlign.center, style: secondaryTextStyle(size: 14)),
              const SizedBox(height: 16),
              VGPillButton(label: VGCopy.guideStartChallenge, onTap: () => vgStartAnalysis(context, widget.feature)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: bmSpecialColor,
      onRefresh: _load,
      child: VGWebPageScaffold(
        title: plan.title,
        subtitle: plan.introMessage,
        onBack: () => vgWebGoProfile(context),
        backLabel: VGCopy.challengeBackToDashboard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 880;
            final summary = Column(
              children: [
                VGWebDesktopCard(child: VGDayProgressStrip(plan: plan)),
                const SizedBox(height: 16),
                _streakCard(plan),
                if (!plan.progress.isCompleted &&
                    VGChallengeService.isCurrentDayLocked(plan) &&
                    plan.progress.nextUnlockAt != null) ...[
                  const SizedBox(height: 16),
                  _unlockCountdownCard(plan.progress.nextUnlockAt!),
                ],
                const SizedBox(height: 16),
                _reminderTimeCard(plan),
              ],
            );
            final days = VGWebDesktopCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(VGCopy.challengeDayOfLabel.toUpperCase(), style: boldTextStyle(color: appTextColorSecondary, size: 11)),
                  const SizedBox(height: 12),
                  ...plan.days.map((d) {
                    final state = _dayState(plan, d);
                    return VGChallengeDayRow(day: d, state: state, onTap: () => _openDay(plan, d, state));
                  }),
                  if (plan.progress.isCompleted) ...[
                    const SizedBox(height: 12),
                    VGPillButton(label: 'View reward card', onTap: _maybeOpenReward),
                  ] else if (plan.progress.currentDay <= plan.durationDays) ...[
                    const SizedBox(height: 12),
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
                  const SizedBox(height: 8),
                  Text(plan.disclaimer, style: secondaryTextStyle(size: 11)),
                ],
              ),
            );

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: summary),
                  const SizedBox(width: 24),
                  Expanded(flex: 3, child: days),
                ],
              );
            }
            return Column(children: [summary, const SizedBox(height: 20), days]);
          },
        ),
      ),
    );
  }

  Widget _unlockCountdownCard(DateTime unlockAt) {
    return VGWebDesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(VGCopy.challengeNextDayUnlockTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 14)),
          const SizedBox(height: 8),
          VGChallengeUnlockCountdown(unlockAt: unlockAt),
          const SizedBox(height: 6),
          Text(VGCopy.challengeNextDayUnlockHint, style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }

  Widget _reminderTimeCard(VGChallengePlan plan) {
    final pref = plan.progress.notificationPrefTime ?? '18:00';
    return VGWebDesktopCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.challengeReminderTimeLabel, style: boldTextStyle(size: 13)),
                const SizedBox(height: 4),
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
    final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await VGChallengeService.updateNotificationPrefTime(plan, formatted);
    toast(VGCopy.challengeReminderTimeSaved);
    _load();
  }

  Widget _streakCard(VGChallengePlan plan) {
    final streak = plan.progress.streakCount;
    final best = plan.progress.bestStreak;
    return VGWebDesktopCard(
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak ${VGCopy.challengeStreakTitle}', style: boldTextStyle(color: bmSpecialColorDark, size: 17)),
                const SizedBox(height: 4),
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

  String _formatDuration(Duration d) => '${d.inHours}h ${d.inMinutes.remainder(60)}m';
}
