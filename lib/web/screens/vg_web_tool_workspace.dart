import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/vg_pill_button.dart';
import '../../models/vg_feature_model.dart';
import '../../services/vg_analytics_service.dart';
import '../../services/vg_analysis_mode.dart';
import '../../utils/BMColors.dart';
import '../content/vg_tool_landing_content.dart';
import '../services/vg_web_analysis_runner.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_app_prefs.dart';
import '../vg_web_breakpoints.dart';
import '../widgets/scan/vg_web_guidelines_panel.dart';
import '../widgets/scan/vg_web_processing_overlay.dart';
import '../widgets/scan/vg_web_upload_panel.dart';

/// Cutout.pro-style tool workspace — upload left, tips right, Analyze CTA.
class VGWebToolWorkspace extends StatefulWidget {
  final String slug;

  const VGWebToolWorkspace({super.key, required this.slug});

  @override
  State<VGWebToolWorkspace> createState() => _VGWebToolWorkspaceState();
}

class _VGWebToolWorkspaceState extends State<VGWebToolWorkspace> {
  String? _photoPath;
  bool _analyzing = false;
  final _progress = ValueNotifier<double>(0);

  VGFeatureModel? get _feature => featureForSlug(widget.slug);

  @override
  void initState() {
    super.initState();
    vgSaveLastWebToolSlug(widget.slug);
  }

  @override
  void didUpdateWidget(covariant VGWebToolWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      vgSaveLastWebToolSlug(widget.slug);
      setState(() {
        _photoPath = null;
        _analyzing = false;
        _progress.value = 0;
      });
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final blockReason = VGAnalysisMode.blockReason;
    if (blockReason != null) {
      toast(blockReason);
      return;
    }

    final feature = _feature;
    if (feature == null || _photoPath == null) {
      toast('Upload a photo first');
      return;
    }
    setState(() => _analyzing = true);
    VGAnalyticsService.logScanStarted(feature.featureType);
    try {
      await vgRunWebScanAnalysis(
        context,
        feature: feature,
        photoPath: _photoPath!,
        progress: _progress,
      );
    } finally {
      if (mounted) {
        setState(() => _analyzing = false);
        _progress.value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feature = _feature;
    if (feature == null) {
      return const Center(child: Text('Tool not found'));
    }

    final content = landingContentForSlug(widget.slug);
    final headline = content?.headline ?? feature.title;
    final subheadline = content?.subheadline ?? feature.description;
    final phone = VGWebBreakpoints.isPhone(context);
    final cardPad = phone ? 16.0 : 28.0;
    final headlineSize = phone ? 24.0 : 32.0;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(VGWebBreakpoints.contentPadding(context)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: TextStyle(
                      fontSize: headlineSize,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      color: bmSpecialColorDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subheadline,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: appTextColorSecondary),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(cardPad),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.22)),
                      boxShadow: [
                        BoxShadow(
                          color: bmSpecialColor.withValues(alpha: 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stack = constraints.maxWidth < VGWebBreakpoints.compact;
                            final upload = VGWebUploadPanel(
                              feature: feature,
                              photoPath: _photoPath,
                              onPhotoChanged: (path) => setState(() => _photoPath = path),
                            );
                            final guidelines = VGWebGuidelinesPanel(feature: feature);
                            if (stack) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  upload,
                                  SizedBox(height: phone ? 20 : 28),
                                  guidelines,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 55, child: upload),
                                SizedBox(width: phone ? 16 : 28),
                                Expanded(flex: 45, child: guidelines),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        VGPillButton(
                          label: 'Analyze',
                          enabled: _photoPath != null && !_analyzing,
                          onTap: _analyze,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_analyzing)
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (context, value, _) => VGWebProcessingOverlay(
              photoPath: _photoPath ?? '',
              progress: value,
            ),
          ),
      ],
    );
  }
}
