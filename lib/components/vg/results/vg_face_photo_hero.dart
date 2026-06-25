import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_constants.dart';
import '../vg_passport_photo_frame.dart';
import '../vg_scan_photo_image.dart';

class VGFacePhotoHero extends StatelessWidget {
  final String? photoPath;
  final double height;
  final Widget? overlay;
  final BorderRadius borderRadius;
  /// Full-width portrait frame (default 3:4) with center-cropped photo.
  final bool passport;
  final double aspectRatio;
  final BoxFit photoFit;

  const VGFacePhotoHero({
    super.key,
    required this.photoPath,
    this.height = 280,
    this.overlay,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.passport = false,
    this.aspectRatio = vgPortraitAspectRatio,
    this.photoFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (passport) {
      return VGPassportPhotoFrame(
        photoPath: photoPath,
        fullWidth: true,
        aspectRatio: aspectRatio,
        borderRadius: borderRadius,
        showBorder: false,
        photoFit: photoFit,
        overlay: overlay != null
            ? Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Container(color: Colors.black.withValues(alpha: 0.28)),
                  overlay!,
                ],
              )
            : null,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _photo(fit: photoFit),
            Container(color: Colors.black.withValues(alpha: 0.28)),
            if (overlay != null) overlay!,
          ],
        ),
      ),
    );
  }

  Widget _photo({required BoxFit fit}) {
    return VGScanPhotoImage(
      photoPath: photoPath,
      fit: fit,
      alignment: Alignment.center,
      placeholder: Container(
        color: bmPrimaryColor.withValues(alpha: 0.2),
        child: Icon(Icons.face_outlined, size: 80, color: bmSpecialColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
