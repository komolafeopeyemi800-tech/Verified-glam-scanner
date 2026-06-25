import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/vg/scan/vg_face_tracking_overlay.dart';
import '../../../components/vg/vg_passport_photo_frame.dart';
import '../../../components/vg/vg_upload_hero.dart';
import '../../../models/vg_feature_model.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_constants.dart';

/// Left column upload zone for the web tool workspace (wide desktop layout).
class VGWebUploadPanel extends StatefulWidget {
  final VGFeatureModel feature;
  final String? photoPath;
  final ValueChanged<String?> onPhotoChanged;

  const VGWebUploadPanel({
    super.key,
    required this.feature,
    required this.photoPath,
    required this.onPhotoChanged,
  });

  @override
  State<VGWebUploadPanel> createState() => _VGWebUploadPanelState();
}

class _VGWebUploadPanelState extends State<VGWebUploadPanel> {
  final ImagePicker _picker = ImagePicker();
  bool _overlayScanning = false;
  bool _overlayReady = false;
  bool _picking = false;

  Future<void> _pickPhoto() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (file == null || !mounted) return;

      setState(() {
        _overlayScanning = true;
        _overlayReady = false;
      });
      widget.onPhotoChanged(file.path);

      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() {
        _overlayScanning = false;
        _overlayReady = true;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Size _previewSize(BoxConstraints constraints) {
    final w = (constraints.maxWidth * 0.85).clamp(280.0, 480.0);
    return vgPortraitSizeForWidth(w);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.photoPath != null && widget.photoPath!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = _previewSize(constraints);

        return InkWell(
          onTap: _picking ? null : _pickPhoto,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 360),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bmSecondBackgroundColorLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: bmPrimaryColor.withValues(alpha: 0.45),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_picking)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: bmSpecialColor),
                  )
                else if (!hasPhoto) ...[
                  const VGUploadHero(),
                  const SizedBox(height: 16),
                  Text(
                    'Drag or click to upload a portrait photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: appTextColorPrimary.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'JPG, PNG, WEBP',
                    style: TextStyle(fontSize: 13, color: appTextColorSecondary),
                  ),
                ] else
                  SizedBox(
                    width: previewSize.width,
                    height: previewSize.height,
                    child: VGPassportPhotoFrame(
                      photoPath: widget.photoPath!,
                      size: previewSize.width,
                      overlay: VGPhotoCaptureReviewOverlay(
                        faceBounds: null,
                        previewSize: previewSize,
                        scanning: _overlayScanning,
                        ready: _overlayReady,
                        faceDetected: true,
                      ),
                    ),
                  ),
                if (hasPhoto && !_picking) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _pickPhoto,
                    child: const Text('Replace photo', style: TextStyle(color: bmSpecialColor, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
