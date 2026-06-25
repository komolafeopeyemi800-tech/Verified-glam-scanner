import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/vg_challenge_plan.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_share_image_utils.dart';

/// Shareable progress card + share action for challenge days.
class VGChallengeShareCard extends StatefulWidget {
  final VGChallengePlan plan;
  final int completedDay;

  const VGChallengeShareCard({
    super.key,
    required this.plan,
    required this.completedDay,
  });

  @override
  State<VGChallengeShareCard> createState() => VGChallengeShareCardState();
}

class VGChallengeShareCardState extends State<VGChallengeShareCard> {
  final GlobalKey _boundaryKey = GlobalKey();

  String get _textFallback => VGCopy.challengeShareMessage(
        challengeName: widget.plan.title,
        completedDay: widget.completedDay,
        durationDays: widget.plan.durationDays,
      );

  Future<void> share() async {
    await vgShareWidgetAsImage(
      boundaryKey: _boundaryKey,
      textFallback: _textFallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bmSpecialColor, bmSpecialColorDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              VGCopy.challengeShareCardTitle.toUpperCase(),
              style: boldTextStyle(color: Colors.white.withValues(alpha: 0.85), size: 10),
            ),
            10.height,
            Text(
              VGCopy.challengeShareDayLine(widget.completedDay, widget.plan.durationDays),
              style: boldTextStyle(color: Colors.white, size: 20),
            ),
            6.height,
            Text(
              widget.plan.title,
              style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.9), size: 13),
            ),
            10.height,
            Text(
              VGCopy.challengeShareTagline,
              style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.85), size: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text-only share fallback for reward screen.
Future<void> vgShareChallengeText({
  required String challengeName,
  required int completedDay,
  required int durationDays,
}) async {
  await Share.share(VGCopy.challengeShareMessage(
    challengeName: challengeName,
    completedDay: completedDay,
    durationDays: durationDays,
  ));
}
