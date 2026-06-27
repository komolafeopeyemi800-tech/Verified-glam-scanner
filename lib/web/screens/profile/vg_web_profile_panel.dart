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
import '../../vg_web_breakpoints.dart';
import '../../widgets/vg_web_credits_panel.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Profile dashboard — badges hero, credits, active challenge (responsive web).
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
    final phone = VGWebBreakpoints.isPhone(context);
    return VGWebDesktopCard(
      padding: EdgeInsets.all(phone ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _featuredHero(),
          SizedBox(height: phone ? 16 : 24),
          Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: phone ? 15 : 16)),
          SizedBox(height: phone ? 12 : 16),
          VGChallengeBadgeGrid(earnedBadges: _badges, loading: false),
        ],
      ),
    );
  }

  Widget _heroRow({required Widget leading, required Widget content, Widget? trailing}) {
    final phone = VGWebBreakpoints.isPhone(context);
    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(child: content),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ],
      );
    }
    return Row(
      children: [
        leading,
        const SizedBox(width: 20),
        Expanded(child: content),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _featuredHero() {
    final reward = _reward;
    final topBadge = _badges.isNotEmpty ? _badges.first : null;

    if (reward == null && topBadge == null) {
      return _heroRow(
        leading: _emptyBadgeRing(),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
            const SizedBox(height: 8),
            Text(VGCopy.profileNoAchievementYet, style: secondaryTextStyle(size: 15, height: 1.45)),
          ],
        ),
      );
    }

    if (reward != null) {
      final title = reward['challenge_title']?.toString() ?? VGCopy.guideRoutineChallenge;
      final completedOn = reward['completed_on']?.toString() ?? '';
      return InkWell(
        onTap: () => vgWebOpenReward(context, reward: reward, feature: _routineFeature),
        borderRadius: BorderRadius.circular(12),
        child: _heroRow(
          leading: _rewardRing(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
              const SizedBox(height: 6),
              Text(
                title,
                style: boldTextStyle(
                  color: bmSpecialColorDark,
                  size: VGWebBreakpoints.isPhone(context) ? 18 : 22,
                ),
              ),
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
          trailing: const Icon(Icons.arrow_forward, color: bmSpecialColor, size: 22),
        ),
      );
    }

    final code = topBadge!['badge_code']?.toString() ?? '';
    final def = VGChallengeBadges.byCode(code);
    final earnedAt = topBadge['earned_at']?.toString() ?? '';
    return _heroRow(
      leading: _emojiRing(def?.emoji ?? '🏅'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
          const SizedBox(height: 6),
          Text(
            def?.title ?? code,
            style: boldTextStyle(
              color: bmSpecialColorDark,
              size: VGWebBreakpoints.isPhone(context) ? 18 : 22,
            ),
          ),
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
    );
  }

  double get _ringSize => VGWebBreakpoints.isPhone(context) ? 72 : 88;

  Widget _emptyBadgeRing() {
    final size = _ringSize;
    return Container(
      width: size,
      height: size,
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
    final size = _ringSize;
    return Container(
      width: size,
      height: size,
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
    final size = _ringSize;
    return Container(
      width: size,
      height: size,
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
    final phone = VGWebBreakpoints.isPhone(context);

    return VGWebDesktopCard(
      padding: EdgeInsets.all(phone ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          phone
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(VGCopy.profileActiveChallenge, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
                    const SizedBox(height: 4),
                    Text(plan.title, style: boldTextStyle(color: bmSpecialColor, size: 18)),
                    const SizedBox(height: 6),
                    Text(
                      isDone ? VGCopy.guideCompleted : VGCopy.profileChallengeProgress(completed, total),
                      style: secondaryTextStyle(size: 13),
                    ),
                    const SizedBox(height: 12),
                    Center(child: _challengeProgressRing(completed, total)),
                  ],
                )
              : Row(
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
                    _challengeProgressRing(completed, total),
                  ],
                ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: VGPillButton(
              label: isDone ? VGCopy.profileViewRoutine : VGCopy.profileContinueChallenge,
              onTap: () => vgWebOpenChallenge(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _challengeProgressRing(int completed, int total) {
    return SizedBox(
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
    );
  }
}
