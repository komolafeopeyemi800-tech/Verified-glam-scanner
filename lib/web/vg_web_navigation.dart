import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/vg_feature_model.dart';
import 'vg_web_breakpoints.dart';
import 'vg_web_profile_nav.dart';

bool vgIsDesktopWeb(BuildContext context) =>
    kIsWeb && VGWebBreakpoints.isDesktop(context);

void vgWebGoProfile(BuildContext context) => context.go('/app/profile');

void vgWebOpenChallenge(BuildContext context) => context.go('/app/profile/challenge');

void vgWebOpenChallengeDay(BuildContext context, int day) =>
    context.go('/app/profile/challenge/day/$day');

void vgWebOpenReward(
  BuildContext context, {
  required Map<String, dynamic> reward,
  required VGFeatureModel feature,
}) {
  VGWebProfileNavCache.setReward(reward, feature);
  context.go('/app/profile/reward');
}

void vgWebPopOrProfile(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    vgWebGoProfile(context);
  }
}
