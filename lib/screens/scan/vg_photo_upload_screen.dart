import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/scan/vg_face_tracking_overlay.dart';
import '../../components/vg/vg_passport_photo_frame.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../components/vg/vg_upload_hero.dart';
import '../../models/vg_feature_model.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_camera_utils.dart';
import '../../utils/vg_constants.dart';
import '../../utils/vg_copy.dart';
import 'vg_photo_crop_screen.dart';
import 'vg_processing_screen.dart';

class VGPhotoUploadScreen extends StatefulWidget {
  final VGFeatureModel feature;

  const VGPhotoUploadScreen({super.key, required this.feature});

  @override
  State<VGPhotoUploadScreen> createState() => _VGPhotoUploadScreenState();
}

class _VGPhotoUploadScreenState extends State<VGPhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;
  List<Rect> _previewFaceBounds = [];
  bool _overlayScanning = false;
  bool _overlayReady = false;
  bool _faceDetected = false;
  String? _faceCountMessage;
  bool _twoFacesValid = false;
  Size? _previewSize;

  bool get _isTwoFaceFeature => widget.feature.featureType == VGFeatureTypes.facialResemblance;

  double _previewWidth(BuildContext context) {
    final w = context.width() - 88;
    return w.clamp(220.0, 360.0);
  }

  Size _previewSizeFor(BuildContext context) => vgPortraitSizeForWidth(_previewWidth(context));

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    if (kIsWeb) {
      await _applyPhoto(file.path);
      return;
    }

    final croppedPath = await VGPhotoCropScreen(
      originalPath: file.path,
      twoFaceMode: _isTwoFaceFeature,
    ).launch<String>(context);
    if (croppedPath == null || !mounted) return;

    await _applyPhoto(croppedPath);
  }

  Future<void> _applyPhoto(String croppedPath) async {
    final previewSize = _previewSizeFor(context);
    setState(() {
      _photo = XFile(croppedPath);
      _previewSize = previewSize;
      _previewFaceBounds = [];
      _overlayScanning = true;
      _overlayReady = false;
      _faceDetected = false;
      _faceCountMessage = null;
      _twoFacesValid = false;
    });

    final bounds = kIsWeb
        ? <Rect>[]
        : await vgDetectAllFaceBoundsFromFile(croppedPath, previewSize);
    if (!mounted) return;

    String? message;
    var valid = kIsWeb ? true : bounds.isNotEmpty;
    if (_isTwoFaceFeature) {
      if (kIsWeb) {
        valid = true;
        message = null;
      } else {
        valid = bounds.length == 2;
        if (bounds.isEmpty) {
          message = VGCopy.uploadTwoFacesRequired;
        } else if (bounds.length == 1) {
          message = VGCopy.uploadTwoFacesRequired;
        } else if (bounds.length > 2) {
          message = VGCopy.uploadTooManyFaces;
        } else {
          message = VGCopy.uploadFaceCountOk;
        }
      }
    } else if (!kIsWeb && bounds.isEmpty) {
      message = VGCopy.uploadNoFaceDetected;
    }

    setState(() {
      _previewFaceBounds = bounds;
      _faceDetected = bounds.isNotEmpty;
      _faceCountMessage = message;
      _twoFacesValid = valid;
    });

    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _overlayScanning = false;
      _overlayReady = true;
    });
  }

  bool get _canContinue {
    if (_photo == null) return false;
    if (kIsWeb) return true;
    if (_isTwoFaceFeature) return _twoFacesValid;
    return _faceDetected;
  }

  void _showPicker() {
    if (kIsWeb) {
      _pick(ImageSource.gallery);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(VGCopy.uploadCamera),
              onTap: () {
                finish(ctx);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(VGCopy.uploadGallery),
              onTap: () {
                finish(ctx);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _isTwoFaceFeature ? VGCopy.uploadSubtitleTwoFaces : VGCopy.uploadSubtitle;

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(VGCopy.uploadTitle, style: boldTextStyle(color: Colors.white, size: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(subtitle, style: primaryTextStyle(color: appTextColorSecondary), textAlign: TextAlign.center),
            8.height,
            Text(VGCopy.uploadPrivacy, style: secondaryTextStyle(color: appTextColorSecondary, size: 12), textAlign: TextAlign.center),
            if (_faceCountMessage != null) ...[
              8.height,
              Text(
                _faceCountMessage!,
                style: secondaryTextStyle(
                  color: _twoFacesValid ? Colors.green.shade700 : bmSpecialColor,
                  size: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: _photo != null ? _photoPreview(context) : const VGUploadHero(),
                ),
              ),
            ),
            VGPillButton(
              label: kIsWeb ? VGCopy.uploadGallery : VGCopy.uploadAction,
              onTap: _showPicker,
            ),
            12.height,
            VGPillButton(
              label: VGCopy.continueLabel,
              enabled: _canContinue,
              onTap: _canContinue
                  ? () => VGProcessingScreen(feature: widget.feature, photoPath: _photo!.path).launch(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPreview(BuildContext context) {
    final previewSize = _previewSize ?? _previewSizeFor(context);
    return SizedBox(
      width: previewSize.width,
      height: previewSize.height,
      child: VGPassportPhotoFrame(
        photoPath: _photo!.path,
        size: previewSize.width,
        overlay: _TwoFacePreviewOverlay(
          faceBounds: _previewFaceBounds,
          previewSize: previewSize,
          scanning: _overlayScanning,
          ready: _overlayReady,
          twoFaceMode: _isTwoFaceFeature,
        ),
      ),
    );
  }
}

class _TwoFacePreviewOverlay extends StatelessWidget {
  final List<Rect> faceBounds;
  final Size previewSize;
  final bool scanning;
  final bool ready;
  final bool twoFaceMode;

  const _TwoFacePreviewOverlay({
    required this.faceBounds,
    required this.previewSize,
    required this.scanning,
    required this.ready,
    required this.twoFaceMode,
  });

  @override
  Widget build(BuildContext context) {
    if (twoFaceMode && faceBounds.length >= 2) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ...faceBounds.take(2).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final bounds = entry.value;
            final color = i == 0 ? const Color(0xFFE07A9A) : const Color(0xFF5B8DEF);
            return CustomPaint(
              painter: _FaceRectPainter(bounds: bounds, color: color),
              size: Size.infinite,
            );
          }),
          if (scanning)
            Center(
              child: Text(
                VGCopy.processingSubtitle,
                style: boldTextStyle(color: Colors.white, size: 12),
              ),
            ),
          if (ready && !scanning)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Text(
                VGCopy.uploadFaceCountOk,
                style: boldTextStyle(color: Colors.white, size: 11),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    }

    return VGPhotoCaptureReviewOverlay(
      faceBounds: faceBounds.isNotEmpty ? faceBounds.first : null,
      previewSize: previewSize,
      scanning: scanning,
      ready: ready,
      faceDetected: faceBounds.isNotEmpty,
    );
  }
}

class _FaceRectPainter extends CustomPainter {
  final Rect bounds;
  final Color color;

  _FaceRectPainter({required this.bounds, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceRectPainter oldDelegate) =>
      oldDelegate.bounds != bounds || oldDelegate.color != color;
}
