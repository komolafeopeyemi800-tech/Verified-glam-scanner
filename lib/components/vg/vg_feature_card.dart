import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import 'vg_feature_thumbnail.dart';
import 'vg_pill_button.dart';

class VGFeatureCard extends StatelessWidget {
  final VGFeatureModel feature;
  final VoidCallback? onStartScan;
  final bool compact;
  /// Tighter layout for home carousel (fixed-height PageView).
  final bool carouselLayout;
  /// Two-column grid on Home / Explore — badge over thumbnail, no overflow.
  final bool gridLayout;

  const VGFeatureCard({
    super.key,
    required this.feature,
    this.onStartScan,
    this.compact = false,
    this.carouselLayout = false,
    this.gridLayout = false,
  });

  bool get _isCompactLike => compact || gridLayout;

  double get _padding => gridLayout ? 10 : 20;

  static const _gridTitleHeight = 38.0;

  double get _thumbnailSize {
    if (gridLayout) return 76;
    if (compact) return 88;
    if (carouselLayout) return 100;
    return 120;
  }

  double get _titleGap => gridLayout ? 4 : (compact ? 12 : (carouselLayout ? 10 : 16));

  int get _titleSize {
    if (gridLayout) return 13;
    if (compact) return 15;
    if (carouselLayout) return 17;
    return 18;
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: gridLayout ? double.infinity : (_isCompactLike ? null : context.width() * 0.78),
      height: gridLayout ? double.infinity : null,
      padding: EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
      ),
      child: gridLayout ? _gridContent() : _defaultContent(),
    );

    if (gridLayout) {
      return SizedBox(width: double.infinity, height: double.infinity, child: card);
    }
    return card;
  }

  Widget _gridContent() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _gridThumbnailSection()),
        SizedBox(height: _titleGap),
        SizedBox(
          height: _gridTitleHeight,
          child: Text(
            feature.title,
            style: boldTextStyle(
              color: appTextColorPrimary,
              size: _titleSize,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _defaultContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _thumbnailSection(),
        SizedBox(height: _titleGap),
        Text(
          feature.title,
          style: boldTextStyle(
            color: appTextColorPrimary,
            size: _titleSize,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (!_isCompactLike) ...[
          SizedBox(height: carouselLayout ? 6 : 8),
          Text(
            feature.description,
            style: secondaryTextStyle(color: appTextColorSecondary, size: carouselLayout ? 12 : 13),
            textAlign: TextAlign.center,
            maxLines: carouselLayout ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: carouselLayout ? 12 : 20),
          VGPillButton(
            label: VGCopy.beginAnalysis,
            width: double.infinity,
            onTap: onStartScan,
          ),
        ],
      ],
    );
  }

  Widget _gridThumbnailSection() {
    final thumbnail = AspectRatio(
      aspectRatio: 1,
      child: VGFeatureThumbnail(
        featureType: feature.featureType,
        assetPath: feature.thumbnailAsset,
        expand: true,
        fit: BoxFit.cover,
      ),
    );

    if (feature.badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          thumbnail,
          Positioned(
            top: -4,
            right: -4,
            child: _badgeChip(),
          ),
        ],
      );
    }

    return thumbnail;
  }

  Widget _thumbnailSection() {
    final thumbnail = VGFeatureThumbnail(
      featureType: feature.featureType,
      assetPath: feature.thumbnailAsset,
      size: _thumbnailSize,
    );

    if (!_isCompactLike && feature.badge != null) {
      return Column(
        children: [
          Align(alignment: Alignment.topRight, child: _badgeChip()),
          thumbnail,
        ],
      );
    }

    if (compact && feature.badge != null) {
      return Column(
        children: [
          Align(alignment: Alignment.topRight, child: _badgeChip()),
          thumbnail,
        ],
      );
    }

    return thumbnail;
  }

  Widget _badgeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bmSpecialColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(feature.badge!, style: boldTextStyle(color: Colors.white, size: 10)),
    );
  }
}
