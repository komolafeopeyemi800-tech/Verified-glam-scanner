import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/BMColors.dart';
import '../../web/vg_web_breakpoints.dart';
import 'vg_pill_button.dart';
import 'vg_progress_bar.dart';

class VGOnboardingScaffold extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;
  final bool primaryEnabled;

  const VGOnboardingScaffold({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.primaryLabel,
    this.onPrimary,
    this.onBack,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (stepIndex + 1) / totalSteps;
    final useWebLayout = kIsWeb && VGWebBreakpoints.isDesktop(context);

    final content = Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack ?? () => finish(context),
                  icon: Icon(Icons.chevron_left, color: bmSpecialColor, size: 32),
                ),
                Expanded(child: VGProgressBar(progress: progress)),
                16.width,
              ],
            ).paddingSymmetric(horizontal: 8),
            24.height,
            Text(title, style: boldTextStyle(color: appTextColorPrimary, size: useWebLayout ? 30 : 26))
                .paddingSymmetric(horizontal: 20),
            8.height,
            Text(subtitle, style: secondaryTextStyle(color: appTextColorSecondary))
                .paddingSymmetric(horizontal: 20),
            24.height,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: VGPillButton(label: primaryLabel, onTap: onPrimary, enabled: primaryEnabled),
            ),
          ],
        ),
      ),
    );

    if (!useWebLayout) return content;

    // On web, VGWebOnboardingShell provides outer chrome — avoid nested cards.
    if (kIsWeb) return content;

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            margin: const EdgeInsets.all(32),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.25)),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: content),
          ),
        ),
      ),
    );
  }
}
