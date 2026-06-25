import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/challenge/vg_challenge_cta_card.dart';
import '../../../components/vg/challenge/vg_issue_pill.dart';
import '../../../components/vg/results/vg_face_photo_hero.dart';
import '../../../components/vg/results/vg_result_scaffold.dart';
import '../../../components/vg/results/vg_skin_concern_overlay.dart';
import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_challenge_service.dart';
import '../../../services/vg_skin_scan_payload.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../web/vg_web_breakpoints.dart';
import '../../../web/vg_web_navigation.dart';
import '../../guide/vg_routine_challenge_screen.dart';

/// Post-scan skin analysis + personalised challenge CTA (matches standard result shell).
class VGGlowUpResult extends StatefulWidget {
  final VGScanResult result;
  final VGFeatureModel feature;

  const VGGlowUpResult({super.key, required this.result, required this.feature});

  @override
  State<VGGlowUpResult> createState() => _VGGlowUpResultState();
}

class _VGGlowUpResultState extends State<VGGlowUpResult> {
  VGChallengePreview? _preview;
  bool _loadingPreview = true;
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final preview = await VGChallengeService.previewTemplateForScan(widget.result);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _loadingPreview = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPreview = false);
    }
  }

  Future<void> _startChallenge() async {
    if (_loadingPreview || _assigning) return;

    final tied = VGChallengeService.tiedTopIssuesForScan(widget.result);
    String? issueOverride;
    if (tied.length >= 2) {
      issueOverride = await _pickIssue(tied);
      if (!mounted) return;
      if (issueOverride == null) return;
    }

    setState(() => _assigning = true);
    try {
      final plan = await VGChallengeService.assignFromScan(
        widget.result,
        issueCodeOverride: issueOverride,
      );
      if (!mounted) return;
      if (plan == null) {
        toast('Sign in to start your challenge');
        setState(() => _assigning = false);
        return;
      }
      if (kIsWeb && VGWebBreakpoints.isDesktop(context)) {
        vgWebOpenChallenge(context);
        if (mounted) finish(context);
        return;
      }
      await VGRoutineChallengeScreen(feature: widget.feature).launch(context);
      if (mounted) finish(context);
    } catch (_) {
      if (mounted) {
        toast('Could not start challenge. Try again.');
        setState(() => _assigning = false);
      }
    }
  }

  Future<String?> _pickIssue(List<VGChallengeIssueChoice> choices) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(VGCopy.challengePickIssueTitle, style: boldTextStyle(size: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(VGCopy.challengePickIssueBody, style: secondaryTextStyle(size: 13, height: 1.4)),
            16.height,
            ...choices.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, c.code),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bmSpecialColorDark,
                    side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(c.label, style: boldTextStyle(size: 13)),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(VGCopy.challengeNotNow)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.result.payload;
    final legacy = VGSkinScanPayload.isLegacyGlowUpPayload(p);
    final annotations = VGSkinScanPayload.resolveAnnotations(p);
    final issues = VGSkinScanPayload.detectedIssues(p);
    final preview = _preview;
    final summary = p['summary'] as String? ?? '';

    return VGResultScaffold(
      result: widget.result,
      feature: widget.feature,
      footerBeforeDone: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (legacy) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bmSecondBackgroundColorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                VGCopy.challengeLegacyRescanPrompt,
                style: secondaryTextStyle(size: 13, height: 1.45),
              ),
            ),
            12.height,
          ],
          VGChallengeCtaCard(
            headline: preview != null
                ? VGCopy.challengeCtaHeadline(preview.durationDays, preview.challengeName)
                : VGCopy.guideRoutineChallenge,
            body: preview?.introMessage ?? VGCopy.challengeCtaBody,
            buttonLabel: VGCopy.challengeViewMyChallenge,
            secondaryLabel: VGCopy.challengeNotNow,
            loading: _loadingPreview || _assigning,
            onTap: _loadingPreview || _assigning ? null : _startChallenge,
            onSecondaryTap: _loadingPreview || _assigning ? null : () => finish(context),
          ),
        ],
      ),
      hero: VGFacePhotoHero(
        photoPath: widget.result.photoPath,
        passport: true,
        overlay: annotations.isEmpty
            ? null
            : VGSkinConcernOverlay(annotations: annotations),
      ),
      children: [
        16.height,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                VGCopy.challengeWhatWeFound.toUpperCase(),
                style: boldTextStyle(color: bmSpecialColor, size: 11),
              ),
              8.height,
              if (summary.isNotEmpty)
                Text(summary, style: secondaryTextStyle(size: 12, height: 1.4)),
              if (summary.isNotEmpty && issues.isNotEmpty) 10.height,
              if (issues.isEmpty && !legacy)
                Text(
                  VGCopy.challengeNoIssuesDetected,
                  style: secondaryTextStyle(size: 13),
                )
              else if (issues.isEmpty && legacy)
                Text(
                  VGCopy.challengeLegacyRescanPrompt,
                  style: secondaryTextStyle(size: 13, height: 1.4),
                )
              else
                ...issues.map((issue) {
                  final anchors = (issue['anchors'] as List?)?.length ?? 0;
                  final subtitle = anchors > 0
                      ? 'Visible on ${anchors > 1 ? 'multiple areas' : 'your portrait'}'
                      : null;
                  return VGIssuePill(
                    label: issue['label'] as String? ?? 'Skin concern',
                    subtitle: subtitle,
                    severity: (issue['severity'] as String? ?? 'medium').toLowerCase(),
                  );
                }),
              if ((p['globalDisclaimer'] as String?)?.isNotEmpty == true) ...[
                12.height,
                Text(
                  p['globalDisclaimer'] as String,
                  style: secondaryTextStyle(size: 11),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
