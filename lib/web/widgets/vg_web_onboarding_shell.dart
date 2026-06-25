import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import '../vg_web_breakpoints.dart';
import 'vg_web_header.dart';

/// Web SaaS chrome for multi-step onboarding (header + centered workspace).
class VGWebOnboardingShell extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final Widget child;

  const VGWebOnboardingShell({
    super.key,
    required this.stepIndex,
    required this.totalSteps,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = VGWebBreakpoints.isDesktop(context);
    final compact = VGWebBreakpoints.isCompact(context);
    final progress = (stepIndex + 1) / totalSteps;

    Widget progressBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up $vgAppName',
            style: TextStyle(
              fontSize: compact ? 20 : 22,
              fontWeight: FontWeight.w800,
              color: bmSpecialColorDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${stepIndex + 1} of $totalSteps',
            style: const TextStyle(color: appTextColorSecondary),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: bmSpecialColor,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 24),
            const Text(
              'Your answers personalize scan results and beauty tips.',
              style: TextStyle(fontSize: 14, height: 1.55, color: appTextColorSecondary),
            ),
          ],
        ],
      );
    }

    final card = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: child,
      ),
    );

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: const VGWebHeader(),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? 960 : 560),
          child: Padding(
            padding: EdgeInsets.all(VGWebBreakpoints.contentPadding(context)),
            child: desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 220, child: progressBlock()),
                      const SizedBox(width: 32),
                      Expanded(child: card),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      progressBlock(),
                      const SizedBox(height: 20),
                      card,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
