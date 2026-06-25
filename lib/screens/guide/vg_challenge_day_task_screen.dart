import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/challenge/vg_challenge_share_card.dart';
import '../../components/vg/challenge/vg_challenge_unlock_countdown.dart';
import '../../components/vg/vg_main_app_bar.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../models/vg_challenge_day.dart';
import '../../models/vg_challenge_plan.dart';
import '../../models/vg_feature_model.dart';
import '../../services/vg_analytics_service.dart';
import '../../services/vg_challenge_service.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../web/vg_web_breakpoints.dart';
import '../../web/vg_web_navigation.dart';
import '../../web/screens/challenge/vg_web_challenge_day_panel.dart';
import 'vg_challenge_reward_screen.dart';
/// Screen 3 — daily task detail for an unlocked day.
class VGChallengeDayTaskScreen extends StatefulWidget {
  final VGFeatureModel feature;
  final VGChallengePlan plan;
  final int dayNumber;

  const VGChallengeDayTaskScreen({
    super.key,
    required this.feature,
    required this.plan,
    required this.dayNumber,
  });

  @override
  State<VGChallengeDayTaskScreen> createState() => _VGChallengeDayTaskScreenState();
}

class _VGChallengeDayTaskScreenState extends State<VGChallengeDayTaskScreen> {
  late VGChallengePlan _plan;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
  }

  VGChallengeDay? get _day {
    for (final d in _plan.days) {
      if (d.dayNumber == widget.dayNumber) return d;
    }
    return null;
  }

  bool get _isCurrentDay =>
      widget.dayNumber == _plan.progress.currentDay && !_plan.progress.isCompleted;

  bool get _isDone => widget.dayNumber <= _plan.progress.completedDays;

  bool get _isLocked {
    if (_isDone) return false;
    if (widget.dayNumber > _plan.progress.currentDay) return true;
    if (widget.dayNumber < _plan.progress.currentDay) return true;
    return _isCurrentDay && VGChallengeService.isCurrentDayLocked(_plan);
  }

  Future<void> _markDone() async {
    if (!_isCurrentDay || _isLocked || _submitting) return;
    setState(() => _submitting = true);
    try {
      final updated = await VGChallengeService.markCurrentDayDone(_plan);
      if (!mounted) return;
      if (updated == null) {
        toast('Could not save progress');
        setState(() => _submitting = false);
        return;
      }
      setState(() {
        _plan = updated;
        _submitting = false;
      });
      VGAnalyticsService.logChallengeDayCompleted(updated.progress.completedDays);
      toast(VGCopy.guideCompletionToast(updated.progress.currentDay));
      if (updated.progress.isCompleted) {
        final reward = await VGChallengeService.latestRewardCard();
        if (!mounted) return;
        if (reward != null) {
          if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
            vgWebOpenReward(context, reward: reward, feature: widget.feature);
          } else {
            await VGChallengeRewardScreen(
              reward: reward,
              feature: widget.feature,
            ).launch(context);
          }
        }
        finish(context);
      } else {
        final unlockAt = updated.progress.nextUnlockAt;
        final completedDay = updated.progress.completedDays;
        final nextDay = completedDay + 1;
        if (unlockAt != null && mounted) {
          final shareCardKey = GlobalKey<VGChallengeShareCardState>();
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (ctx) {
              final bottomInset = MediaQuery.viewPaddingOf(ctx).bottom;
              return Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          VGCopy.guideDonePanelTitleForDay(completedDay),
                          style: boldTextStyle(size: 18),
                        ),
                        8.height,
                        Text(
                          VGCopy.guideDonePanelBodyForNextDay(nextDay),
                          style: secondaryTextStyle(size: 13, height: 1.45),
                        ),
                        12.height,
                        Text(
                          VGCopy.challengeUnlockCountdownLabel(nextDay),
                          style: boldTextStyle(color: bmSpecialColor, size: 13),
                        ),
                        6.height,
                        VGChallengeUnlockCountdown(unlockAt: unlockAt),
                        12.height,
                        VGChallengeShareCard(
                          key: shareCardKey,
                          plan: updated,
                          completedDay: completedDay,
                        ),
                        12.height,
                        VGPillButton(
                          label: VGCopy.guideShareProgress,
                          onTap: () => shareCardKey.currentState?.share(),
                        ),
                        10.height,
                        VGPillButton(
                          label: VGCopy.challengeBackToDashboard,
                          onTap: () => finish(ctx),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        if (mounted) finish(context, true);
      }
    } catch (_) {
      if (mounted) {
        toast('Saved locally for now. We will sync shortly.');
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
      return VGWebChallengeDayPanel(
        feature: widget.feature,
        plan: widget.plan,
        dayNumber: widget.dayNumber,
      );
    }

    final day = _day;
    if (day == null) {
      return Scaffold(
        appBar: VGMainAppBar(title: widget.plan.title),
        body: const Center(child: Text('Day not found')),
      );
    }

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: VGMainAppBar(title: widget.plan.title),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bmSpecialColor, bmSpecialColorDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VGCopy.challengeDayHeroTitle(widget.dayNumber, _plan.durationDays).toUpperCase(),
                  style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.8), size: 12),
                ),
                8.height,
                Text(day.title, style: boldTextStyle(color: Colors.white, size: 22)),
                12.height,
                Row(
                  children: [
                    _chip(VGCopy.challengeEstMinutes(day.estMinutes)),
                    if (_isDone) ...[
                      8.width,
                      _chip(VGCopy.guideCompleted),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TaskCard(
                    label: VGCopy.challengeMainFocusLabel,
                    title: day.mainTask,
                    body: null,
                  ),
                  14.height,
                  _TaskCard(
                    label: VGCopy.challengeSupportHabitLabel,
                    title: day.supportTask,
                    body: null,
                  ),
                  14.height,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: bmSecondBackgroundColorLight,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(left: BorderSide(color: bmSpecialColor, width: 3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          VGCopy.challengeWhyHelpsLabel.toUpperCase(),
                          style: boldTextStyle(color: bmSpecialColor, size: 11),
                        ),
                        6.height,
                        Text(day.whyLine, style: secondaryTextStyle(size: 13, height: 1.5)),
                      ],
                    ),
                  ),
                  12.height,
                  Text(widget.plan.disclaimer, style: secondaryTextStyle(size: 11)),
                  if (_isLocked && _plan.progress.nextUnlockAt != null) ...[
                    16.height,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bmSecondBackgroundColorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(VGCopy.challengeNextDayUnlockTitle, style: boldTextStyle(size: 13)),
                          6.height,
                          VGChallengeUnlockCountdown(unlockAt: _plan.progress.nextUnlockAt!),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: _isDone
                ? VGPillButton(
                    label: VGCopy.challengeBackToOverview,
                    onTap: () => finish(context),
                  )
                : _isLocked
                    ? VGPillButton(
                        label: VGCopy.guideLockedUntil,
                        onTap: null,
                      )
                    : _isCurrentDay
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _markDone,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bmSpecialColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(VGCopy.guideMarkDone, style: boldTextStyle(color: Colors.white, size: 16)),
                            ),
                          )
                        : VGPillButton(
                            label: VGCopy.challengeBackToOverview,
                            onTap: () => finish(context),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: boldTextStyle(color: Colors.white, size: 11)),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String label;
  final String title;
  final String? body;

  const _TaskCard({required this.label, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: boldTextStyle(color: bmSpecialColor, size: 11)),
          8.height,
          Text(title, style: boldTextStyle(size: 15)),
          if (body != null) ...[
            8.height,
            Text(body!, style: secondaryTextStyle(size: 13, height: 1.5)),
          ],
        ],
      ),
    );
  }
}
