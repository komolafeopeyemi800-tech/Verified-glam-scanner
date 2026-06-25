import 'package:flutter/material.dart';

import '../../utils/BMColors.dart';
import '../../utils/vg_constants.dart';
import 'vg_scan_photo_image.dart';

/// Portrait photo frame (default 3:4). Photo fills frame with [photoFit] (default [BoxFit.cover]).
class VGPassportPhotoFrame extends StatelessWidget {
  final String? photoPath;
  /// Frame width when not [fullWidth]; height derived from [aspectRatio].
  final double? size;
  final Widget? overlay;
  final BorderRadius borderRadius;
  final bool showBorder;
  final bool fullWidth;
  final double aspectRatio;
  final BoxFit photoFit;

  const VGPassportPhotoFrame({
    super.key,
    required this.photoPath,
    this.size,
    this.overlay,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.showBorder = true,
    this.fullWidth = false,
    this.aspectRatio = vgPortraitAspectRatio,
    this.photoFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final frame = ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          ColoredBox(
            color: bmLightScaffoldBackgroundColor,
            child: _photo(),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );

    Widget child = frame;
    if (size != null) {
      child = SizedBox(
        width: size,
        height: size! / aspectRatio,
        child: frame,
      );
    } else if (fullWidth) {
      child = AspectRatio(aspectRatio: aspectRatio, child: frame);
    }

    if (!showBorder) return child;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: bmPrimaryColor, width: 2),
      ),
      clipBehavior: overlay != null ? Clip.none : Clip.antiAlias,
      child: child,
    );
  }

  Widget _photo() {
    return VGScanPhotoImage(
      photoPath: photoPath,
      fit: photoFit,
      alignment: Alignment.center,
      placeholder: Icon(Icons.face_outlined, size: 80, color: bmSpecialColor.withValues(alpha: 0.5)),
    );
  }
}
