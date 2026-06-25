import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:nb_utils/nb_utils.dart';

import '../../../components/vg/vg_pill_button.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_camera_utils.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_image_utils.dart';
import '../../../utils/vg_platform_file.dart';

/// Desktop crop dialog (~800px) instead of full-screen mobile crop.
Future<String?> showVGWebCropDialog(
  BuildContext context, {
  required String originalPath,
  bool twoFaceMode = false,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _VGWebCropDialog(originalPath: originalPath, twoFaceMode: twoFaceMode),
  );
}

class _VGWebCropDialog extends StatefulWidget {
  final String originalPath;
  final bool twoFaceMode;

  const _VGWebCropDialog({required this.originalPath, this.twoFaceMode = false});

  @override
  State<_VGWebCropDialog> createState() => _VGWebCropDialogState();
}

class _VGWebCropDialogState extends State<_VGWebCropDialog> {
  final CropController _controller = CropController();
  Uint8List? _imageBytes;
  InitialRectBuilder? _initialRectBuilder;
  bool _loading = true;
  bool _cropping = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final bytes = await vgReadFileBytes(widget.originalPath);
    var initialBuilder = InitialRectBuilder.withSizeAndRatio(
      size: 0.65,
      aspectRatio: vgPortraitAspectRatio,
    );

    final decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
      if (widget.twoFaceMode) {
        final allFaces = await vgDetectAllFaceBoundsFromFile(widget.originalPath, imageSize);
        if (allFaces.length >= 2) {
          final union = vgUnionFaceBounds(allFaces.take(2).toList(), imageSize);
          initialBuilder = InitialRectBuilder.withArea(_portraitCropAroundFace(union, imageSize));
        }
      } else {
        final faceBounds = await vgDetectFaceBoundsFromFile(widget.originalPath, imageSize);
        if (faceBounds != null) {
          initialBuilder = InitialRectBuilder.withArea(_portraitCropAroundFace(faceBounds, imageSize));
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _initialRectBuilder = initialBuilder;
      _loading = false;
    });
  }

  Rect _portraitCropAroundFace(Rect face, Size imageSize) {
    final inflated = vgInflateFaceBounds(face);
    var cropWidth = inflated.width * 1.35;
    var cropHeight = cropWidth / vgPortraitAspectRatio;

    if (cropHeight > imageSize.height) {
      cropHeight = imageSize.height;
      cropWidth = cropHeight * vgPortraitAspectRatio;
    }
    if (cropWidth > imageSize.width) {
      cropWidth = imageSize.width;
      cropHeight = cropWidth / vgPortraitAspectRatio;
    }

    var left = inflated.center.dx - cropWidth / 2;
    var top = inflated.center.dy - cropHeight * 0.42;
    if (left < 0) left = 0;
    if (top < 0) top = 0;
    if (left + cropWidth > imageSize.width) left = imageSize.width - cropWidth;
    if (top + cropHeight > imageSize.height) top = imageSize.height - cropHeight;
    return Rect.fromLTWH(left, top, cropWidth, cropHeight);
  }

  void _applyCrop() {
    if (_cropping || _loading) return;
    setState(() => _cropping = true);
    _controller.crop();
  }

  Future<void> _handleCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        final path = await vgExportCroppedImage(croppedImage);
        if (!mounted) return;
        Navigator.of(context).pop(path);
      case CropFailure():
        if (!mounted) return;
        setState(() => _cropping = false);
        toast('Could not crop photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(VGCopy.cropTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 20)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                VGCopy.cropSubtitle,
                style: primaryTextStyle(color: appTextColorSecondary, size: 14),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading || _imageBytes == null
                    ? Center(child: CircularProgressIndicator(color: bmSpecialColor))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Crop(
                          image: _imageBytes!,
                          controller: _controller,
                          aspectRatio: vgPortraitAspectRatio,
                          initialRectBuilder: _initialRectBuilder,
                          interactive: true,
                          baseColor: bmLightScaffoldBackgroundColor,
                          maskColor: Colors.black.withValues(alpha: 0.55),
                          radius: 8,
                          cornerDotBuilder: (size, edgeAlignment) => DotControl(color: bmSpecialColor),
                          onCropped: _handleCropped,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: VGPillButton(
                      label: VGCopy.cropChooseAnother,
                      outline: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VGPillButton(
                      label: VGCopy.cropApply,
                      enabled: !_loading && !_cropping,
                      onTap: _applyCrop,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
