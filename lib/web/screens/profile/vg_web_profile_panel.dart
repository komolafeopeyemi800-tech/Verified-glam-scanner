import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import '../../../components/vg/challenge/vg_challenge_badge_grid.dart';
import '../../../components/vg/vg_pill_button.dart';
import '../../../main.dart';
import '../../../models/vg_challenge_plan.dart';
import '../../../models/vg_feature_model.dart';
import '../../../screens/subscription/vg_paywall_screen.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../services/vg_credits_service.dart';
import '../../../services/vg_polar_checkout_service.dart';
import '../../../services/vg_subscription_store.dart';
import '../../../utils/BMConstants.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_challenge_badges.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_feature_data.dart';
import '../../../utils/vg_navigation.dart';
import '../../vg_web_navigation.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Desktop profile — wide two-column layout inside the SaaS shell.
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
        subtitle: VGCopy.profileDashboardSubtitle,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (wide) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _journeyColumn()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _sidebarColumn()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _badgesSection(),
                  const SizedBox(height: 24),
                  _quickActionsRow(),
                ],
              );
            }
            return Column(
              children: [
                _journeyColumn(),
                const SizedBox(height: 16),
                _sidebarColumn(),
                const SizedBox(height: 24),
                _badgesSection(),
                const SizedBox(height: 24),
                _quickActionsRow(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _journeyColumn() {
    return Column(
      children: [
        _featuredCard(),
        const SizedBox(height: 16),
        _activeChallengeCard(),
      ],
    );
  }

  Widget _sidebarColumn() {
    return Column(
      children: [
        _subscriptionCard(),
        const SizedBox(height: 16),
        _accountCard(),
      ],
    );
  }

  Widget _featuredCard() {
    final reward = _reward;
    final topBadge = _badges.isNotEmpty ? _badges.first : null;

    if (reward == null && topBadge == null) {
      return VGWebDesktopCard(
        child: Row(
          children: [
            _iconBox(Icons.emoji_events_outlined, bmLightScaffoldBackgroundColor, bmPrimaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
                  const SizedBox(height: 6),
                  Text(VGCopy.profileNoAchievementYet, style: secondaryTextStyle(size: 14, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (reward != null) {
      final title = reward['challenge_title']?.toString() ?? VGCopy.guideRoutineChallenge;
      final completedOn = reward['completed_on']?.toString() ?? '';
      return VGWebDesktopCard(
        onTap: () => vgWebOpenReward(context, reward: reward, feature: _routineFeature),
        child: Row(
          children: [
            _iconBox(Icons.emoji_events, const Color(0xFFF59E0B), Colors.white, gradient: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
                  const SizedBox(height: 4),
                  Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 18)),
                  if (completedOn.isNotEmpty)
                    Text(VGCopy.profileBadgeEarnedOn(completedOn.split('T').first), style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: bmSpecialColor, size: 20),
          ],
        ),
      );
    }

    final code = topBadge!['badge_code']?.toString() ?? '';
    final def = VGChallengeBadges.byCode(code);
    final earnedAt = topBadge['earned_at']?.toString() ?? '';
    return VGWebDesktopCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(def?.emoji ?? '🏅', style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.profileFeaturedAchievement, style: boldTextStyle(color: bmSpecialColorDark, size: 12)),
                const SizedBox(height: 4),
                Text(def?.title ?? code, style: boldTextStyle(color: bmSpecialColorDark, size: 18)),
                if (earnedAt.isNotEmpty)
                  Text(VGCopy.profileBadgeEarnedOn(earnedAt.split('T').first), style: secondaryTextStyle(size: 12)),
              ],
            ),
          ),
        ],
      ),
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

  Widget _subscriptionCard() {
    return FutureBuilder<(bool isPro, int? credits)>(
      future: _loadSubscriptionInfo(),
      builder: (context, snapshot) {
        final isPro = snapshot.data?.$1 == true;
        final credits = snapshot.data?.$2;
        return VGWebDesktopCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconBox(Icons.workspace_premium_outlined, bmSecondBackgroundColorLight, bmSpecialColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(VGCopy.profileSubscription, style: boldTextStyle(color: bmSpecialColorDark, size: 16)),
                        Text(
                          isPro ? VGCopy.profileSubscriptionPro : VGCopy.profileSubscriptionFree,
                          style: secondaryTextStyle(size: 13),
                        ),
                        if (isPro && credits != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            VGCopy.profileCreditsRemaining(credits),
                            style: boldTextStyle(color: bmSpecialColor, size: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (!isPro) ...[
                const SizedBox(height: 16),
                Text(
                  VGCopy.profileSubscriptionUpgradeHint,
                  style: secondaryTextStyle(size: 13, height: 1.45),
                ),
                const SizedBox(height: 14),
                VGPillButton(
                  label: VGCopy.profileActionPro,
                  width: double.infinity,
                  onTap: () => vgShowPaywall(context, entry: VGPaywallEntry.profile),
                ),
              ] else ...[
                const SizedBox(height: 16),
                VGPillButton(
                  label: VGCopy.profileManageSubscription,
                  width: double.infinity,
                  onTap: () async {
                    try {
                      await VGPolarCheckoutService.openCustomerPortal();
                    } catch (_) {
                      if (context.mounted) toast(VGCopy.paywallCheckoutError);
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<(bool, int?)> _loadSubscriptionInfo() async {
    final isPro = await VGSubscriptionStore.isPro();
    if (!isPro) return (false, null);
    final credits = await VGCreditsService.fetchBalance();
    return (true, credits);
  }

  Widget _accountCard() {
    return VGWebDesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(VGCopy.profileAccountSection, style: boldTextStyle(color: bmSpecialColorDark, size: 16)),
          const SizedBox(height: 16),
          _accountRow(
            Icons.brightness_6_outlined,
            VGCopy.profileTheme,
            trailing: Switch(
              value: appStore.isDarkModeOn,
              activeTrackColor: bmSpecialColor,
              onChanged: (val) async {
                appStore.toggleDarkMode(value: val);
                await setValue(isDarkModeOnPref, val);
              },
            ),
          ),
          const Divider(height: 24),
          _accountRow(Icons.mail_outline, VGCopy.settingsSupport, subtitle: vgSupportEmail),
          _accountRow(Icons.privacy_tip_outlined, VGCopy.settingsPrivacy),
          _accountRow(Icons.share_outlined, VGCopy.settingsShare, onTap: () {
            Share.share('${VGCopy.splashTagline} — $vgAppName');
          }),
        ],
      ),
    );
  }

  Widget _accountRow(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: bmSpecialColor, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: boldTextStyle(color: appTextColorPrimary, size: 14)),
                    if (subtitle != null)
                      Text(subtitle, style: secondaryTextStyle(size: 12)),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _badgesSection() {
    return VGWebDesktopCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 18)),
          const SizedBox(height: 6),
          Text('Your journey at a glance — tap a badge to see what you earned.', style: secondaryTextStyle(size: 13)),
          const SizedBox(height: 20),
          VGChallengeBadgeGrid(earnedBadges: _badges, loading: false),
        ],
      ),
    );
  }

  Widget _quickActionsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _actionChip(Icons.share_outlined, VGCopy.profileActionShare, () {
          Share.share('${VGCopy.splashTagline} — $vgAppName');
        }),
        _actionChip(Icons.workspace_premium_outlined, VGCopy.profileActionPro, () {
          vgShowPaywall(context, entry: VGPaywallEntry.profile);
        }),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: bmSpecialColor, size: 20),
              const SizedBox(width: 10),
              Text(label, style: boldTextStyle(color: bmSpecialColorDark, size: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color bg, Color fg, {bool gradient = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: gradient ? null : bg,
        gradient: gradient
            ? LinearGradient(colors: [const Color(0xFFF59E0B), bmSpecialColor])
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: fg, size: 30),
    );
  }
}
