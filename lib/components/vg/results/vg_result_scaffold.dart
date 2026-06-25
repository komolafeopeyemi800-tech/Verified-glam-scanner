import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_feature_model.dart';
import '../../../models/vg_scan_result.dart';
import '../../../services/vg_referral_service.dart';
import '../../../services/vg_result_download_service.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../web/widgets/results/vg_web_result_layout.dart';
import '../share/vg_share_result_bar.dart';
import '../vg_ad_banner.dart';
import '../vg_pill_button.dart';

class VGResultScaffold extends StatefulWidget {
  final VGScanResult result;
  final VGFeatureModel feature;
  final Widget hero;
  final List<Widget> children;
  final Widget? footerBeforeDone;
  final bool showReferralShare;

  const VGResultScaffold({
    super.key,
    required this.result,
    required this.feature,
    required this.hero,
    required this.children,
    this.footerBeforeDone,
    this.showReferralShare = true,
  });

  @override
  State<VGResultScaffold> createState() => _VGResultScaffoldState();
}

class _VGResultScaffoldState extends State<VGResultScaffold> {
  final _heroCaptureKey = GlobalKey();

  Widget get _capturedHero => RepaintBoundary(
        key: _heroCaptureKey,
        child: widget.hero,
      );

  Future<void> _download(BuildContext context) async {
    final ok = await VGResultDownloadService.downloadResultPhoto(
      widget.result,
      heroBoundaryKey: _heroCaptureKey,
    );
    if (!context.mounted) return;
    if (ok) {
      toast(VGCopy.resultsDownloadSuccess);
    } else {
      toast(VGCopy.resultsDownloadFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareFooter = widget.footerBeforeDone ??
        (widget.showReferralShare
            ? VGShareResultBar(
                buildShareMessage: () => VGReferralService.shareMessageForResult(widget.result, widget.feature),
              )
            : null);

    if (kIsWeb) {
      return VGWebResultLayout(
        result: widget.result,
        feature: widget.feature,
        hero: _capturedHero,
        heroCaptureKey: _heroCaptureKey,
        reportChildren: widget.children,
        footerBeforeDone: shareFooter,
        showReferralShare: widget.showReferralShare,
      );
    }

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(widget.feature.title, style: boldTextStyle(color: Colors.white, size: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const VGAdBanner(),
            if (kDebugMode && widget.result.usedMockAnalysis) ...[
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
                  style: secondaryTextStyle(size: 11, height: 1.35),
                ),
              ),
              12.height,
            ],
            Text(
              VGCopy.resultsDownloadHint,
              style: secondaryTextStyle(size: 13, height: 1.4),
            ),
            16.height,
            _capturedHero,
            ...widget.children,
            if (shareFooter != null) ...[
              16.height,
              shareFooter,
            ],
            24.height,
            VGPillButton(label: VGCopy.resultsDownload, onTap: () => _download(context)),
            12.height,
            VGPillButton(label: VGCopy.resultsDone, onTap: () => finish(context), outline: true),
          ],
        ),
      ),
    );
  }
}
