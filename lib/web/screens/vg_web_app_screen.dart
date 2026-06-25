import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/vg_feature_model.dart';
import '../../services/vg_challenge_service.dart';
import '../../../utils/vg_constants.dart';
import '../../utils/vg_feature_data.dart';
import '../../utils/BMColors.dart';
import '../screens/challenge/vg_web_challenge_day_panel.dart';
import '../screens/challenge/vg_web_challenge_reward_panel.dart';
import '../screens/challenge/vg_web_routine_challenge_panel.dart';
import '../screens/profile/vg_web_profile_panel.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_app_prefs.dart';
import '../vg_web_profile_nav.dart';
import '../widgets/vg_web_app_shell.dart';
import '../widgets/vg_web_tool_sidebar.dart';
import 'vg_web_tool_workspace.dart';

enum VGWebProfileSubview { main, challenge, challengeDay, reward }

/// Authenticated web app — SaaS shell with one tool workspace at a time.
class VGWebAppScreen extends StatelessWidget {
  final String? slug;
  final VGWebAppSection section;
  final VGWebProfileSubview profileSubview;
  final int? challengeDay;

  const VGWebAppScreen({
    super.key,
    this.slug,
    this.section = VGWebAppSection.tool,
    this.profileSubview = VGWebProfileSubview.main,
    this.challengeDay,
  });

  VGFeatureModel get _routineFeature =>
      getVerifiedGlamFeatures().firstWhere((f) => f.featureType == VGFeatureTypes.glowUpGuide);

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (section) {
      case VGWebAppSection.profile:
        body = _profileBody(context);
      case VGWebAppSection.tool:
        final toolSlug = slug ?? vgDefaultWebToolSlug;
        if (!isToolSlug(toolSlug)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(vgWebDefaultAppPath());
          });
          body = const Center(child: CircularProgressIndicator(color: bmSpecialColor));
        } else {
          body = VGWebToolWorkspace(slug: toolSlug);
        }
    }

    return VGWebAppShell(
      activeSlug: section == VGWebAppSection.tool ? slug : null,
      section: section,
      child: body,
    );
  }

  Widget _profileBody(BuildContext context) {
    switch (profileSubview) {
      case VGWebProfileSubview.challenge:
        return VGWebRoutineChallengePanel(feature: _routineFeature);
      case VGWebProfileSubview.challengeDay:
        return _ChallengeDayLoader(feature: _routineFeature, dayNumber: challengeDay ?? 1);
      case VGWebProfileSubview.reward:
        final reward = VGWebProfileNavCache.reward;
        final feature = VGWebProfileNavCache.rewardFeature ?? _routineFeature;
        if (reward == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/app/profile');
          });
          return const Center(child: CircularProgressIndicator(color: bmSpecialColor));
        }
        return VGWebChallengeRewardPanel(reward: reward, feature: feature);
      case VGWebProfileSubview.main:
        return const VGWebProfilePanel();
    }
  }
}

class _ChallengeDayLoader extends StatefulWidget {
  final VGFeatureModel feature;
  final int dayNumber;

  const _ChallengeDayLoader({required this.feature, required this.dayNumber});

  @override
  State<_ChallengeDayLoader> createState() => _ChallengeDayLoaderState();
}

class _ChallengeDayLoaderState extends State<_ChallengeDayLoader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: VGChallengeService.loadOrAssign(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(color: bmSpecialColor));
        }
        final plan = snapshot.data;
        if (plan == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/app/profile/challenge');
          });
          return const SizedBox.shrink();
        }
        return VGWebChallengeDayPanel(
          feature: widget.feature,
          plan: plan,
          dayNumber: widget.dayNumber,
        );
      },
    );
  }
}
