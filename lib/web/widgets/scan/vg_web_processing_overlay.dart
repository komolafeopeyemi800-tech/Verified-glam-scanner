import 'package:flutter/material.dart';

import '../../../components/vg/scan/vg_face_tracking_overlay.dart';
import '../../../components/vg/vg_passport_photo_frame.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';

/// Light-themed processing overlay for web workspace (not full-screen dark mobile UI).
class VGWebProcessingOverlay extends StatelessWidget {
  final String photoPath;
  final double progress;

  const VGWebProcessingOverlay({
    super.key,
    required this.photoPath,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    VGCopy.processingTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: bmSpecialColorDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    VGCopy.processingSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: appTextColorSecondary.withValues(alpha: 0.95)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    height: 250,
                    child: VGPassportPhotoFrame(
                      photoPath: photoPath,
                      size: 200,
                      overlay: VGPhotoCaptureReviewOverlay(
                        faceBounds: null,
                        previewSize: const Size(200, 250),
                        scanning: true,
                        ready: false,
                        faceDetected: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: bmSecondBackgroundColorLight,
                      color: bmSpecialColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
