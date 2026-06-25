import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/vg_pill_button.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_camera_utils.dart';
import '../../utils/vg_constants.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_image_utils.dart';
import '../../utils/vg_platform_file.dart';

class VGPhotoCropScreen extends StatefulWidget {
  final String originalPath;
  final bool twoFaceMode;

  const VGPhotoCropScreen({
    super.key,
    required this.originalPath,
    this.twoFaceMode = false,
  });

  @override
  State<VGPhotoCropScreen> createState() => _VGPhotoCropScreenState();
}

class _VGPhotoCropScreenState extends State<VGPhotoCropScreen> {
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
        finish(context, path);
      case CropFailure():
        if (!mounted) return;
        setState(() => _cropping = false);
        toast('Could not crop photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(VGCopy.cropTitle, style: boldTextStyle(color: Colors.white, size: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              VGCopy.cropSubtitle,
              style: primaryTextStyle(color: appTextColorSecondary),
              textAlign: TextAlign.center,
            ),
            16.height,
            Expanded(
              child: _loading || _imageBytes == null
                  ? Center(child: CircularProgressIndicator(color: bmSpecialColor))
                  : Crop(
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
            16.height,
            VGPillButton(
              label: VGCopy.cropApply,
              enabled: !_loading && !_cropping,
              onTap: _applyCrop,
            ),
            12.height,
            VGPillButton(
              label: VGCopy.cropChooseAnother,
              outline: true,
              onTap: () => finish(context),
            ),
          ],
        ),
      ),
    );
  }
}
