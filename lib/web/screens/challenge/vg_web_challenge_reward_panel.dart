import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../components/vg/challenge/vg_challenge_badge_grid.dart';
import '../../../components/vg/vg_pill_button.dart';
import '../../../models/vg_feature_model.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_navigation.dart';
import '../../vg_web_navigation.dart';
import '../../widgets/vg_web_page_scaffold.dart';

/// Desktop reward screen — wide layout inside the SaaS shell.
class VGWebChallengeRewardPanel extends StatefulWidget {
  final Map<String, dynamic> reward;
  final VGFeatureModel feature;

  const VGWebChallengeRewardPanel({
    super.key,
    required this.reward,
    required this.feature,
  });

  @override
  State<VGWebChallengeRewardPanel> createState() => _VGWebChallengeRewardPanelState();
}

class _VGWebChallengeRewardPanelState extends State<VGWebChallengeRewardPanel> {
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

  @override
  Widget build(BuildContext context) {
    final title = widget.reward['challenge_title']?.toString() ?? VGCopy.guideRoutineChallenge;
    final message = widget.reward['message']?.toString() ?? VGCopy.challengeRewardSubtitle;
    final completedOn = widget.reward['completed_on']?.toString() ?? '';

    return VGWebPageScaffold(
      title: VGCopy.challengeRewardTitle,
      subtitle: message,
      onBack: () => vgWebGoProfile(context),
      backLabel: VGCopy.challengeBackToDashboard,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          final hero = _heroCard(title, completedOn);
          final badges = VGWebDesktopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.challengeBadgesTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 18)),
                const SizedBox(height: 16),
                VGChallengeBadgeGrid(earnedBadges: _badges, loading: _loading),
              ],
            ),
          );
          final actions = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 10),
              VGPillButton(label: VGCopy.guideRescanCta, onTap: () => vgStartAnalysis(context, widget.feature)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => vgWebOpenChallenge(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: bmSpecialColor,
                  side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(VGCopy.challengeBackToOverview, style: boldTextStyle(color: bmSpecialColor, size: 14)),
              ),
            ],
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: Column(children: [hero, const SizedBox(height: 20), actions])),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: badges),
              ],
            );
          }
          return Column(children: [hero, const SizedBox(height: 20), badges, const SizedBox(height: 20), actions]);
        },
      ),
    );
  }

  Widget _heroCard(String title, String completedOn) {
    return VGWebDesktopCard(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [const Color(0xFFF59E0B), bmSpecialColor]),
              boxShadow: [
                BoxShadow(color: bmSpecialColor.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            alignment: Alignment.center,
            child: const Text('🏆', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 20),
          Text(title, style: boldTextStyle(color: bmSpecialColor, size: 20), textAlign: TextAlign.center),
          if (completedOn.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Completed ${completedOn.split('T').first}', style: secondaryTextStyle(size: 12)),
          ],
        ],
      ),
    );
  }
}
