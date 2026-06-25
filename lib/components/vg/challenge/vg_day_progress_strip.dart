import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_challenge_plan.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

class VGDayProgressStrip extends StatelessWidget {
  final VGChallengePlan plan;

  const VGDayProgressStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final current = plan.progress.currentDay;
    final completed = plan.progress.completedDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(VGCopy.challengeProgressLabel, style: secondaryTextStyle(size: 12)),
            Text(
              VGCopy.challengeDayProgress(current, plan.durationDays),
              style: boldTextStyle(color: bmSpecialColorDark, size: 13),
            ),
          ],
        ),
        10.height,
        Row(
          children: List.generate(plan.durationDays, (index) {
            final day = index + 1;
            final isDone = day <= completed;
            final isActive = day == current && !plan.progress.isCompleted;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index < plan.durationDays - 1 ? 6 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: isActive
                      ? LinearGradient(colors: [bmSpecialColor, bmPrimaryColor])
                      : null,
                  color: isActive
                      ? null
                      : isDone
                          ? bmSpecialColor
                          : bmPrimaryColor.withValues(alpha: 0.35),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
