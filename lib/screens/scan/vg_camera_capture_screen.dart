import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/scan/vg_face_tracking_overlay.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_camera_utils.dart';
import '../../utils/vg_copy.dart';
import '../../utils/vg_image_utils.dart';

class VGCameraCaptureScreen extends StatefulWidget {
  const VGCameraCaptureScreen({super.key});

  @override
  State<VGCameraCaptureScreen> createState() => _VGCameraCaptureScreenState();
}

class _VGCameraCaptureScreenState extends State<VGCameraCaptureScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  FaceDetector? _detector;
  bool _initializing = true;
  bool _processingFrame = false;
  bool _capturing = false;
  List<Offset>? _faceOvalPoints;
  Rect? _faceBounds;
  List<Offset>? _smoothedPoints;
  double _score = 7.5;
  Size _previewLayoutSize = Size.zero;
  DateTime _lastDetection = DateTime.fromMillisecondsSinceEpoch(0);
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      if (!mounted) return;

      await controller.startImageStream(_onCameraFrame);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (mounted) {
        toast('Camera unavailable');
        finish(context);
      }
    }
  }

  VgCameraCoordinateMapper? _mapper(Size imageSize) {
    if (_controller == null || _previewLayoutSize.isEmpty) return null;
    final previewSize = _controller!.value.previewSize;
    if (previewSize == null) return null;

    return VgCameraCoordinateMapper(
      widgetSize: _previewLayoutSize,
      analysisImageSize: imageSize,
      previewSourceSize: Size(previewSize.height, previewSize.width),
      rotation: _rotationFromSensor(_controller!.description.sensorOrientation),
      lensDirection: _controller!.description.lensDirection,
    );
  }

  InputImageRotation _rotationFromSensor(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _onCameraFrame(CameraImage image) async {
    if (_processingFrame || _capturing || _controller == null || _detector == null) return;
    if (_previewLayoutSize.isEmpty) return;

    final now = DateTime.now();
    if (now.difference(_lastDetection).inMilliseconds < 180) return;
    _lastDetection = now;
    _processingFrame = true;

    try {
      final input = vgInputImageFromCameraImage(image, _controller!.description);
      if (input == null) return;

      final faces = await _detector!.processImage(input);
      if (!mounted || _controller == null) return;

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final mapper = _mapper(imageSize);
      if (mapper == null) return;

      if (faces.isEmpty) {
        setState(() {
          _faceOvalPoints = null;
          _faceBounds = null;
          _smoothedPoints = null;
        });
        return;
      }

      final face = faces.first;
      final contour = face.contours[FaceContourType.face];
      var points = mapper.mapContour(contour);
      if (points.length < 8) {
        final mappedRect = mapper.mapRect(face.boundingBox);
        if (mappedRect == null) return;
        points = vgOvalPointsFromRect(mappedRect);
      }

      final smoothed = vgSmoothContourPoints(_smoothedPoints, points);
      final bounds = vgBoundsFromPoints(smoothed) ?? mapper.mapRect(face.boundingBox);

      if (bounds != null) {
        setState(() {
          _smoothedPoints = smoothed;
          _faceOvalPoints = smoothed;
          _faceBounds = bounds;
          _score = vgMockTrackingScore(bounds, _previewLayoutSize);
        });
      }
    } catch (_) {
      // Skip bad frames.
    } finally {
      _processingFrame = false;
    }
  }

  Future<void> _capture() async {
    if (_controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      await _controller!.stopImageStream();
      final file = await _controller!.takePicture();
      final cropped = await vgCenterCropToSquare(file.path);
      if (!mounted) return;
      Navigator.pop(context, cropped);
    } catch (_) {
      if (mounted) toast('Could not capture photo');
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.startImageStream(_onCameraFrame);
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _controller?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = context.width() - 48;

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(VGCopy.uploadCamera, style: boldTextStyle(color: Colors.white, size: 18)),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: bmSpecialColor))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _faceOvalPoints != null ? VGCopy.cameraScanning : VGCopy.cameraAlignFace,
                    style: primaryTextStyle(color: appTextColorSecondary),
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = frameSize.clamp(0.0, constraints.maxHeight);
                          if (_previewLayoutSize != Size(side, side)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) setState(() => _previewLayoutSize = Size(side, side));
                            });
                          }

                          return SizedBox(
                            width: side,
                            height: side,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_controller != null && _controller!.value.isInitialized)
                                    FittedBox(
                                      fit: BoxFit.cover,
                                      clipBehavior: Clip.hardEdge,
                                      child: SizedBox(
                                        width: _controller!.value.previewSize!.height,
                                        height: _controller!.value.previewSize!.width,
                                        child: CameraPreview(_controller!),
                                      ),
                                    ),
                                  AnimatedBuilder(
                                    animation: _scanController,
                                    builder: (context, _) {
                                      return VGFaceTrackingOverlay(
                                        faceOvalPoints: _faceOvalPoints,
                                        faceBounds: _faceBounds,
                                        scanProgress: _scanController.value,
                                        score: _score,
                                        showStatus: false,
                                        guideMode: _faceOvalPoints == null,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  16.height,
                  VGPillButton(
                    label: _capturing ? '…' : VGCopy.cameraCapture,
                    enabled: !_capturing,
                    onTap: _capture,
                  ),
                ],
              ),
            ),
    );
  }
}
