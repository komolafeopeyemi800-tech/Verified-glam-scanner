import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../models/vg_makeup_state.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../vg_scan_photo_image.dart';
import 'vg_makeup_zone_painter.dart';

class VGMakeupPreview extends StatelessWidget {
  final String photoPath;
  final Size previewSize;
  final VGMakeupState state;
  final VoidCallback onReset;

  const VGMakeupPreview({
    super.key,
    required this.photoPath,
    required this.previewSize,
    required this.state,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: previewSize.width,
      height: previewSize.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            _basePhoto(),
            CustomPaint(
              painter: VGMakeupZonePainter(
                color: state.lipsColor,
                intensity: state.intensity,
                regions: [state.regions.lips],
                blendMode: BlendMode.multiply,
              ),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: VGMakeupZonePainter(
                color: state.eyesColor,
                intensity: state.intensity * 0.85,
                regions: state.regions.eyes,
                blendMode: BlendMode.softLight,
              ),
              size: Size.infinite,
            ),
            CustomPaint(
              painter: VGMakeupZonePainter(
                color: state.blushColor,
                intensity: state.intensity,
                regions: state.regions.blush,
                blendMode: BlendMode.softLight,
              ),
              size: Size.infinite,
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white, size: 18),
                        6.width,
                        Text(VGCopy.makeupReset, style: boldTextStyle(color: Colors.white, size: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basePhoto() {
    return VGScanPhotoImage(
      photoPath: photoPath,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: ColoredBox(
        color: bmPrimaryColor.withValues(alpha: 0.2),
        child: Icon(Icons.face_outlined, size: 80, color: bmSpecialColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
