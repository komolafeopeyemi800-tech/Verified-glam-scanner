import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/challenge/vg_challenge_badge_grid.dart';
import '../../../components/vg/vg_pill_button.dart';
import '../../../models/vg_challenge_plan.dart';
import '../../../models/vg_feature_model.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_challenge_badges.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_feature_data.dart';
import '../../../utils/vg_navigation.dart';
import '../../vg_web_navigation.dart';
import '../../widgets/vg_web_credits_panel.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Desktop profile — SaaS layout: badges hero, credits dashboard, active challenge.
class VGWebProfilePanel extends StatefulWidget {
  const VGWebProfilePanel({super.key});

  @override
  State<VGWebProfilePanel> createState() => _VGWebProfilePanelState();
}

class _VGWebProfilePanelState extends State<VGWebProfilePanel> {
  List<Map<String, dynamic>> _badges = const [];
  Map<String, dynamic>? _reward;
  VGChallengePlan? _plan;
  bool _loading = true;

  VGFeatureModel get _routineFeature =>
      getVerifiedGlamFeatures().firstWhere((f) => f.featureType == VGFeatureTypes.glowUpGuide);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final badges = await VGChallengeService.fetchUserBadges();
      final reward = await VGChallengeService.latestRewardCard();
      final plan = await VGChallengeService.loadOrAssign();
      if (!mounted) return;
      setState(() {
        _badges = badges;
        _reward = reward;
        _plan = plan;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: bmSpecialColor));
    }

    return RefreshIndicator(
      color: bmSpecialColor,
      onRefresh: _load,
      child: VGWebPageScaffold(
        title: VGCopy.profileTitle,
        subtitle: VGCopy.profileDashboardSubtitleSaaS,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _badgeHeroSection(),
            const SizedBox(height: 24),
            const VGWebCreditsPanel(),
            const SizedBox(height: 24),
            _activeChallengeCard(),
          ],
        ),
      ),
    );
  }

  Widget _badgeHeroSection() {
    return VGWebDesktopCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _featuredHero(),
            const SizedBox(height: 24),
            Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 16)),
            const SizedBox(height: 16),
            VGChallengeBadgeGrid(earnedBadges: _badges, loading: false),
          ],
        ),
      ),
    );
  }

  Widget _featuredHero() {
    final reward = _reward;
    final topBadge = _badges.isNotEmpty ? _badges.first : null;

    if (reward == null && topBadge == null) {
      return Row(
        children: [
          _emptyBadgeRing(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
                const SizedBox(height: 8),
                Text(VGCopy.profileNoAchievementYet, style: secondaryTextStyle(size: 15, height: 1.45)),
              ],
            ),
          ),
        ],
      );
    }

    if (reward != null) {
      final title = reward['challenge_title']?.toString() ?? VGCopy.guideRoutineChallenge;
      final completedOn = reward['completed_on']?.toString() ?? '';
      return InkWell(
        onTap: () => vgWebOpenReward(context, reward: reward, feature: _routineFeature),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _rewardRing(),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
                  const SizedBox(height: 6),
                  Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
                  if (completedOn.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        VGCopy.profileBadgeEarnedOn(completedOn.split('T').first),
                        style: secondaryTextStyle(size: 13),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: bmSpecialColor, size: 22),
          ],
        ),
      );
    }

    final code = topBadge!['badge_code']?.toString() ?? '';
    final def = VGChallengeBadges.byCode(code);
    final earnedAt = topBadge['earned_at']?.toString() ?? '';
    return Row(
      children: [
        _emojiRing(def?.emoji ?? '🏅'),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
              const SizedBox(height: 6),
              Text(def?.title ?? code, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
              if (earnedAt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    VGCopy.profileBadgeEarnedOn(earnedAt.split('T').first),
                    style: secondaryTextStyle(size: 13),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyBadgeRing() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: bmLightScaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35), width: 2),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.emoji_events_outlined, color: bmPrimaryColor, size: 36),
    );
  }

  Widget _rewardRing() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [const Color(0xFFF59E0B), bmSpecialColor]),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.emoji_events, color: Colors.white, size: 40),
    );
  }

  Widget _emojiRing(String emoji) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 40)),
    );
  }

  Widget _activeChallengeCard() {
    final plan = _plan;
    if (plan == null) {
      return VGWebDesktopCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(VGCopy.profileActiveChallenge, style: boldTextStyle(color: bmSpecialColorDark, size: 16)),
            const SizedBox(height: 8),
            Text(VGCopy.guideNoActiveChallenge, style: secondaryTextStyle(size: 14, height: 1.45)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: VGPillButton(
                label: VGCopy.guideStartChallenge,
                onTap: () => vgStartAnalysis(context, _routineFeature),
              ),
            ),
          ],
        ),
      );
    }

    final completed = plan.progress.completedDays;
    final total = plan.durationDays;
    final isDone = plan.progress.isCompleted;

    return VGWebDesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(VGCopy.profileActiveChallenge, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
                    const SizedBox(height: 4),
                    Text(plan.title, style: boldTextStyle(color: bmSpecialColor, size: 20)),
                    const SizedBox(height: 6),
                    Text(
                      isDone ? VGCopy.guideCompleted : VGCopy.profileChallengeProgress(completed, total),
                      style: secondaryTextStyle(size: 13),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      strokeWidth: 6,
                      color: bmSpecialColor,
                      backgroundColor: bmSecondBackgroundColorLight,
                    ),
                    Text('$completed/$total', style: boldTextStyle(size: 12, color: bmSpecialColorDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VGPillButton(
            label: isDone ? VGCopy.profileViewRoutine : VGCopy.profileContinueChallenge,
            onTap: () => vgWebOpenChallenge(context),
          ),
        ],
      ),
    );
  }
}
