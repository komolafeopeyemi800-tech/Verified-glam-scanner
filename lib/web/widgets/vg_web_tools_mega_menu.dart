import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_feature_data.dart';
import '../vg_feature_slugs.dart';
import '../vg_web_breakpoints.dart';
import 'vg_marketing_iframe_stub.dart'
    if (dart.library.html) 'vg_marketing_iframe_web.dart' as marketing_iframe;

/// Airbrush-style mega menu — featured column + categorized tool columns.
class VGWebToolsMegaMenu extends StatefulWidget {
  final String? activeSlug;
  final bool toolsIndexActive;

  const VGWebToolsMegaMenu({
    super.key,
    this.activeSlug,
    this.toolsIndexActive = false,
  });

  @override
  State<VGWebToolsMegaMenu> createState() => _VGWebToolsMegaMenuState();
}

class _VGWebToolsMegaMenuState extends State<VGWebToolsMegaMenu> {
  OverlayEntry? _overlay;
  bool _open = false;
  final _triggerKey = GlobalKey();
  Timer? _closeTimer;

  static const _faceTypes = [
    VGFeatureTypes.faceBeautyAnalysis,
    VGFeatureTypes.faceReading,
    VGFeatureTypes.facialSymmetry,
    VGFeatureTypes.goldenRatio,
  ];

  static const _styleTypes = [
    VGFeatureTypes.colorAnalysis,
    VGFeatureTypes.celebrityLookalike,
    VGFeatureTypes.beautyTips,
    VGFeatureTypes.facialResemblance,
  ];

  static const _programTypes = [
    VGFeatureTypes.glowUpGuide,
    VGFeatureTypes.beautyScoreShowdown,
  ];

  bool get _isActive => widget.toolsIndexActive || widget.activeSlug != null;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeOverlay(restoreIframe: true);
    super.dispose();
  }

  void _cancelCloseTimer() => _closeTimer?.cancel();

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted && _open) _close();
    });
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (_open) return;
    if (!VGWebBreakpoints.isDesktop(context)) {
      _showMobileSheet();
      return;
    }
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    marketing_iframe.setMarketingIframePointerEvents(false);
    setState(() => _open = true);
  }

  void _close() {
    _removeOverlay(restoreIframe: true);
    if (mounted) setState(() => _open = false);
  }

  void _removeOverlay({bool restoreIframe = false}) {
    _overlay?.remove();
    _overlay = null;
    if (restoreIframe) {
      marketing_iframe.setMarketingIframePointerEvents(true);
    }
  }

  void _navigate(String path) {
    _close();
    context.go(path);
  }

  void _showMobileSheet() {
    final tools = getVerifiedGlamFeatures();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: bmGreyColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(VGCopy.webNavAiTools, style: boldTextStyle(color: bmSpecialColorDark, size: 20)),
                const SizedBox(height: 16),
                _mobileSection(ctx, VGCopy.webMegaMenuColFace, _toolsForTypes(tools, _faceTypes)),
                _mobileSection(ctx, VGCopy.webMegaMenuColStyle, _toolsForTypes(tools, _styleTypes)),
                _mobileSection(ctx, VGCopy.webMegaMenuColPrograms, _toolsForTypes(tools, _programTypes)),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(VGCopy.webNavPricing, style: boldTextStyle(color: bmSpecialColor)),
                  trailing: const Icon(Icons.arrow_forward, color: bmSpecialColor, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/pricing');
                  },
                ),
                ListTile(
                  title: Text(VGCopy.webMegaMenuExploreAll, style: boldTextStyle(color: bmSpecialColor)),
                  trailing: const Icon(Icons.arrow_forward, color: bmSpecialColor, size: 18),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/tools');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _mobileSection(BuildContext ctx, String title, List<VGFeatureModel> tools) {
    if (tools.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 13)),
        ),
        ...tools.map((tool) {
          final slug = slugForFeatureType(tool.featureType);
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(tool.title),
            trailing: tool.badge != null ? _badge(tool.badge!) : null,
            onTap: () {
              Navigator.pop(ctx);
              context.go('/$slug');
            },
          );
        }),
      ],
    );
  }

  OverlayEntry _buildOverlay() {
    final tools = getVerifiedGlamFeatures();
    final featured = tools.firstWhere((f) => f.featureType == VGFeatureTypes.faceBeautyAnalysis);
    final top = MediaQuery.paddingOf(context).top + 72;
    const bridgeHeight = 20.0;

    return OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withValues(alpha: 0.12)),
              ),
            ),
            Positioned(
              top: top - bridgeHeight,
              left: 0,
              right: 0,
              child: MouseRegion(
                onEnter: (_) => _cancelCloseTimer(),
                onExit: (_) => _scheduleClose(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: bridgeHeight,
                      width: double.infinity,
                    ),
                    Material(
                      elevation: 12,
                      shadowColor: Colors.black26,
                      color: Colors.white,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: VGWebBreakpoints.maxContent),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: VGWebBreakpoints.contentPadding(context),
                              vertical: 28,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 34, child: _featuredColumn(featured)),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 22,
                                  child: _categoryColumn(
                                    VGCopy.webMegaMenuColFace,
                                    _toolsForTypes(tools, _faceTypes),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 22,
                                  child: _categoryColumn(
                                    VGCopy.webMegaMenuColStyle,
                                    _toolsForTypes(tools, _styleTypes),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 22,
                                  child: _categoryColumn(
                                    VGCopy.webMegaMenuColPrograms,
                                    _toolsForTypes(tools, _programTypes),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<VGFeatureModel> _toolsForTypes(List<VGFeatureModel> all, List<String> types) {
    return [
      for (final type in types)
        all.firstWhere((f) => f.featureType == type),
    ];
  }

  Widget _featuredColumn(VGFeatureModel featured) {
    final slug = slugForFeatureType(featured.featureType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: featured.thumbnailAsset != null
                ? Image.asset(featured.thumbnailAsset!, fit: BoxFit.cover)
                : Container(
                    color: bmSecondBackgroundColorLight,
                    child: Icon(featured.icon, size: 48, color: bmSpecialColor),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          VGCopy.webMegaMenuFeaturedTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: bmSpecialColorDark),
        ),
        const SizedBox(height: 8),
        Text(
          VGCopy.webMegaMenuFeaturedBody,
          style: const TextStyle(fontSize: 14, height: 1.55, color: appTextColorSecondary),
        ),
        const SizedBox(height: 16),
        Material(
          color: bmSpecialColor,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: () => _navigate('/$slug'),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Text(
                VGCopy.webMegaMenuStartCta,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _navigate('/tools'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  VGCopy.webMegaMenuExploreAll,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: bmSpecialColor, fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: bmSpecialColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _navigate('/pricing'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  VGCopy.webNavPricing,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: bmSpecialColor, fontSize: 14),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 16, color: bmSpecialColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            _close();
            final uri = Uri.parse(vgGooglePlayUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shop_outlined, size: 16, color: bmSpecialColor),
                const SizedBox(width: 6),
                Text(
                  VGCopy.webNavPlayStore,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: bmSpecialColor, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryColumn(String title, List<VGFeatureModel> tools) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: bmSpecialColorDark),
        ),
        const SizedBox(height: 12),
        ...tools.map((tool) => _toolLink(tool)),
      ],
    );
  }

  Widget _toolLink(VGFeatureModel tool) {
    final slug = slugForFeatureType(tool.featureType);
    final selected = slug == widget.activeSlug;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? bmSecondBackgroundColorLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _navigate('/$slug'),
          borderRadius: BorderRadius.circular(8),
          hoverColor: bmLightScaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tool.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? bmSpecialColor : appTextColorPrimary,
                    ),
                  ),
                ),
                if (tool.badge != null) _badge(tool.badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String label) {
    final hot = label.toUpperCase() == 'HOT';
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: hot ? bmSpecialColor : bmPrimaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (VGWebBreakpoints.isDesktop(context)) {
          _cancelCloseTimer();
          _openMenu();
        }
      },
      child: InkWell(
        key: _triggerKey,
        onTap: _toggle,
        borderRadius: BorderRadius.circular(8),
        hoverColor: bmLightScaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                VGCopy.webNavAiTools,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _isActive || _open ? FontWeight.w700 : FontWeight.w500,
                  color: _isActive || _open ? bmSpecialColor : appTextColorSecondary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                _open ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: _isActive || _open ? bmSpecialColor : appTextColorSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
