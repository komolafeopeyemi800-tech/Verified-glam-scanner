import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../components/vg/challenge/vg_challenge_badge_grid.dart';
import '../../components/vg/vg_main_app_bar.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../models/vg_feature_model.dart';
import '../../services/vg_challenge_service.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_navigation.dart';
import '../../web/vg_web_breakpoints.dart';
import '../../web/screens/challenge/vg_web_challenge_reward_panel.dart';

/// Screen 4 — completion reward, badges, re-scan.
class VGChallengeRewardScreen extends StatefulWidget {
  final Map<String, dynamic> reward;
  final VGFeatureModel feature;

  const VGChallengeRewardScreen({
    super.key,
    required this.reward,
    required this.feature,
    this.onRescan,
  });

  /// Legacy callback — prefer [feature] + built-in navigation.
  final VoidCallback? onRescan;

  @override
  State<VGChallengeRewardScreen> createState() => _VGChallengeRewardScreenState();
}

class _VGChallengeRewardScreenState extends State<VGChallengeRewardScreen> {
  List<Map<String, dynamic>> _badges = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final badges = await VGChallengeService.fetchUserBadges();
      if (!mounted) return;
      setState(() {
        _badges = badges;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _rescan() {
    if (widget.onRescan != null) {
      widget.onRescan!();
      return;
    }
    vgStartAnalysis(context, widget.feature);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
      return VGWebChallengeRewardPanel(reward: widget.reward, feature: widget.feature);
    }

    final title = widget.reward['challenge_title']?.toString() ?? VGCopy.guideRoutineChallenge;
    final message = widget.reward['message']?.toString() ?? VGCopy.challengeRewardSubtitle;
    final completedOn = widget.reward['completed_on']?.toString() ?? '';

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bmSecondBackgroundColorLight, bmLightScaffoldBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const VGMainAppBar(title: 'Reward'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [const Color(0xFFF59E0B), bmSpecialColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: bmSpecialColor.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('🏆', style: TextStyle(fontSize: 52)),
                      ),
                      24.height,
                      Text(VGCopy.challengeRewardTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 26)),
                      8.height,
                      Text(message, style: secondaryTextStyle(size: 14), textAlign: TextAlign.center),
                      8.height,
                      Text(title, style: boldTextStyle(size: 15, color: bmSpecialColor), textAlign: TextAlign.center),
                      if (completedOn.isNotEmpty) ...[
                        6.height,
                        Text(
                          'Completed ${completedOn.split('T').first}',
                          style: secondaryTextStyle(size: 12),
                        ),
                      ],
                      24.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          children: [
                            Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 15)),
                            16.height,
                            VGChallengeBadgeGrid(earnedBadges: _badges, loading: _loading),
                          ],
                        ),
                      ),
                      28.height,
                      VGPillButton(
                        label: VGCopy.guideShareProgress,
                        onTap: () {
                          Share.share(
                            '${VGCopy.challengeRewardTitle}\n'
                            '$title\n'
                            '${VGCopy.challengeShareTagline}\n'
                            '— ${VGCopy.challengeShareCardTitle}',
                          );
                        },
                      ),
                      10.height,
                      VGPillButton(label: VGCopy.guideRescanCta, onTap: _rescan),
                      10.height,
                      VGPillButton(
                        label: VGCopy.guideNextChallengeCta,
                        onTap: _rescan,
                      ),
                      10.height,
                      VGPillButton(
                        label: VGCopy.challengeBackToOverview,
                        onTap: () => finish(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
