import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/challenge/vg_challenge_unlock_countdown.dart';
import '../../../components/vg/vg_pill_button.dart';
import '../../../models/vg_challenge_day.dart';
import '../../../models/vg_challenge_plan.dart';
import '../../../models/vg_feature_model.dart';
import '../../../services/vg_analytics_service.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../vg_web_navigation.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Desktop daily challenge task — two-column layout inside the SaaS shell.
class VGWebChallengeDayPanel extends StatefulWidget {
  final VGFeatureModel feature;
  final VGChallengePlan plan;
  final int dayNumber;

  const VGWebChallengeDayPanel({
    super.key,
    required this.feature,
    required this.plan,
    required this.dayNumber,
  });

  @override
  State<VGWebChallengeDayPanel> createState() => _VGWebChallengeDayPanelState();
}

class _VGWebChallengeDayPanelState extends State<VGWebChallengeDayPanel> {
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
          vgWebOpenReward(context, reward: reward, feature: widget.feature);
        } else {
          vgWebGoProfile(context);
        }
      } else {
        final unlockAt = updated.progress.nextUnlockAt;
        final completedDay = updated.progress.completedDays;
        final nextDay = completedDay + 1;
        if (unlockAt != null && mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(VGCopy.guideDonePanelTitleForDay(completedDay), style: boldTextStyle(size: 18)),
                      const SizedBox(height: 8),
                      Text(VGCopy.guideDonePanelBodyForNextDay(nextDay), style: secondaryTextStyle(size: 13, height: 1.45)),
                      const SizedBox(height: 12),
                      Text(VGCopy.challengeUnlockCountdownLabel(nextDay), style: boldTextStyle(color: bmSpecialColor, size: 13)),
                      const SizedBox(height: 6),
                      VGChallengeUnlockCountdown(unlockAt: unlockAt),
                      const SizedBox(height: 16),
                      VGPillButton(label: VGCopy.challengeBackToOverview, onTap: () => Navigator.of(ctx).pop()),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        if (mounted) vgWebOpenChallenge(context);
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
    final day = _day;
    if (day == null) {
      return VGWebPageScaffold(
        title: _plan.title,
        onBack: () => vgWebOpenChallenge(context),
        backLabel: VGCopy.challengeBackToOverview,
        child: const Center(child: Text('Day not found')),
      );
    }

    return VGWebPageScaffold(
      title: day.title,
      subtitle: VGCopy.challengeDayHeroTitle(widget.dayNumber, _plan.durationDays),
      onBack: () => vgWebOpenChallenge(context),
      backLabel: VGCopy.challengeBackToOverview,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          final tasks = Column(
            children: [
              _TaskCard(label: VGCopy.challengeMainFocusLabel, title: day.mainTask),
              const SizedBox(height: 14),
              _TaskCard(label: VGCopy.challengeSupportHabitLabel, title: day.supportTask),
              const SizedBox(height: 14),
              VGWebDesktopCard(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(VGCopy.challengeWhyHelpsLabel.toUpperCase(), style: boldTextStyle(color: bmSpecialColor, size: 11)),
                    const SizedBox(height: 8),
                    Text(day.whyLine, style: secondaryTextStyle(size: 14, height: 1.55)),
                  ],
                ),
              ),
            ],
          );
          final sidebar = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VGWebDesktopCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(VGCopy.challengeEstMinutes(day.estMinutes), style: boldTextStyle(size: 13)),
                    if (_isDone) ...[
                      const SizedBox(height: 8),
                      Text(VGCopy.guideCompleted, style: boldTextStyle(color: bmSpecialColor, size: 13)),
                    ],
                    if (_isLocked && _plan.progress.nextUnlockAt != null) ...[
                      const SizedBox(height: 12),
                      Text(VGCopy.challengeNextDayUnlockTitle, style: boldTextStyle(size: 13)),
                      const SizedBox(height: 6),
                      VGChallengeUnlockCountdown(unlockAt: _plan.progress.nextUnlockAt!),
                    ],
                    const SizedBox(height: 12),
                    Text(_plan.disclaimer, style: secondaryTextStyle(size: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _actionButton(),
            ],
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: tasks),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: sidebar),
              ],
            );
          }
          return Column(children: [tasks, const SizedBox(height: 20), sidebar]);
        },
      ),
    );
  }

  Widget _actionButton() {
    if (_isDone) {
      return VGPillButton(label: VGCopy.challengeBackToOverview, onTap: () => vgWebOpenChallenge(context));
    }
    if (_isLocked) {
      return VGPillButton(label: VGCopy.guideLockedUntil, onTap: null);
    }
    if (_isCurrentDay) {
      return SizedBox(
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
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(VGCopy.guideMarkDone, style: boldTextStyle(color: Colors.white, size: 16)),
        ),
      );
    }
    return VGPillButton(label: VGCopy.challengeBackToOverview, onTap: () => vgWebOpenChallenge(context));
  }
}

class _TaskCard extends StatelessWidget {
  final String label;
  final String title;

  const _TaskCard({required this.label, required this.title});

  @override
  Widget build(BuildContext context) {
    return VGWebDesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: boldTextStyle(color: bmSpecialColor, size: 11)),
          const SizedBox(height: 8),
          Text(title, style: boldTextStyle(size: 16)),
        ],
      ),
    );
  }
}
