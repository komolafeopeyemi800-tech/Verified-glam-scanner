import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_result_download_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../vg_feature_slugs.dart';
import '../../vg_web_breakpoints.dart';
import '../vg_web_page_scaffold.dart';
import '../../../components/vg/vg_ad_banner.dart';
import '../../../components/vg/vg_pill_button.dart';

/// Desktop results — sticky photo hero left, scrollable report right.
class VGWebResultLayout extends StatelessWidget {
  final VGScanResult result;
  final VGFeatureModel feature;
  final Widget hero;
  final GlobalKey? heroCaptureKey;
  final List<Widget> reportChildren;
  final Widget? footerBeforeDone;
  final bool showReferralShare;

  const VGWebResultLayout({
    super.key,
    required this.result,
    required this.feature,
    required this.hero,
    this.heroCaptureKey,
    required this.reportChildren,
    this.footerBeforeDone,
    this.showReferralShare = true,
  });

  void _goBack(BuildContext context) {
    final slug = slugForFeatureType(feature.featureType);
    if (Navigator.of(context).canPop()) {
      finish(context);
    } else {
      context.go('/app/$slug');
    }
  }

  Future<void> _download(BuildContext context) async {
    final ok = await VGResultDownloadService.downloadResultPhoto(
      result,
      heroBoundaryKey: heroCaptureKey,
    );
    if (!context.mounted) return;
    if (ok) {
      toast(VGCopy.resultsDownloadSuccess);
    } else {
      toast(VGCopy.resultsDownloadFailed);
    }
  }

  List<Widget> _cleanReportChildren() {
    return reportChildren.where((w) {
      if (w is SizedBox && w.child == null) {
        final h = w.height ?? 0;
        if (h > 0 && h <= 24) return false;
      }
      return true;
    }).toList();
  }

  String _subtitle() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final date = '${months[result.createdAt.month - 1]} ${result.createdAt.day}, ${result.createdAt.year}';
    return '$date · ${VGCopy.resultsDownloadHint}';
  }

  Widget _heroColumn() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: hero,
        ),
        const SizedBox(height: 16),
        if (kDebugMode && result.usedMockAnalysis)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bmSecondBackgroundColorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              VGCopy.devMockAnalysisBanner,
              style: const TextStyle(fontSize: 11, height: 1.35, color: appTextColorSecondary),
            ),
          ),
      ],
    );
  }

  Widget _reportColumn(BuildContext context, {required bool stackActions}) {
    final shareFooter = footerBeforeDone;
    final slug = slugForFeatureType(feature.featureType);
    final cleaned = _cleanReportChildren();

    final downloadBtn = VGPillButton(
      label: VGCopy.resultsDownload,
      onTap: () => _download(context),
    );
    final doneBtn = OutlinedButton(
      onPressed: () => _goBack(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: bmSpecialColor,
        side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(VGCopy.resultsDone, style: boldTextStyle(color: bmSpecialColor, size: 14)),
    );
    final runAgainBtn = OutlinedButton(
      onPressed: () => context.go('/app/$slug'),
      style: OutlinedButton.styleFrom(
        foregroundColor: bmSpecialColor,
        side: BorderSide(color: bmPrimaryColor.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('Run again', style: boldTextStyle(color: bmSpecialColor, size: 14)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const VGAdBanner(),
        const SizedBox(height: 16),
        ...cleaned,
        if (shareFooter != null) ...[
          const SizedBox(height: 16),
          shareFooter,
        ],
        const SizedBox(height: 24),
        if (stackActions) ...[
          downloadBtn,
          const SizedBox(height: 12),
          doneBtn,
          const SizedBox(height: 12),
          runAgainBtn,
        ] else ...[
          Row(
            children: [
              Expanded(child: downloadBtn),
              const SizedBox(width: 12),
              Expanded(child: doneBtn),
            ],
          ),
          const SizedBox(height: 12),
          runAgainBtn,
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: VGWebPageScaffold(
          title: feature.title,
          subtitle: _subtitle(),
          onBack: () => _goBack(context),
          backLabel: 'Back to workspace',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < VGWebBreakpoints.compact;
              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _heroColumn(),
                    const SizedBox(height: 28),
                    _reportColumn(context, stackActions: true),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 42, child: _heroColumn()),
                  const SizedBox(width: 32),
                  Expanded(flex: 58, child: _reportColumn(context, stackActions: false)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
