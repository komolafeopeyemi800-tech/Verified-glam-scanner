import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Converts a [CameraImage] stream frame to [InputImage] for ML Kit (Android).
InputImage? vgInputImageFromCameraImage(CameraImage image, CameraDescription camera) {
  if (!Platform.isAndroid) return null;
  if (image.planes.isEmpty) return null;

  final rotation = _rotationFromSensor(camera.sensorOrientation);

  return InputImage.fromBytes(
    bytes: _concatenatePlanes(image.planes),
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
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

Uint8List _concatenatePlanes(List<Plane> planes) {
  final buffer = WriteBuffer();
  for (final plane in planes) {
    buffer.putUint8List(plane.bytes);
  }
  return buffer.done().buffer.asUint8List();
}

/// Maps camera / ML Kit coordinates to the square preview widget (BoxFit.cover + front mirror).
class VgCameraCoordinateMapper {
  final Size widgetSize;
  final Size analysisImageSize;
  final Size previewSourceSize;
  final InputImageRotation rotation;
  final CameraLensDirection lensDirection;

  VgCameraCoordinateMapper({
    required this.widgetSize,
    required this.analysisImageSize,
    required this.previewSourceSize,
    required this.rotation,
    required this.lensDirection,
  });

  Size get _effectiveAnalysisSize {
    if (rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg) {
      return Size(analysisImageSize.height, analysisImageSize.width);
    }
    return analysisImageSize;
  }

  double get _coverScale {
    if (previewSourceSize.isEmpty || widgetSize.isEmpty) return 1;
    return math.max(
      widgetSize.width / previewSourceSize.width,
      widgetSize.height / previewSourceSize.height,
    );
  }

  Offset get _coverOffset {
    final scale = _coverScale;
    final scaledW = previewSourceSize.width * scale;
    final scaledH = previewSourceSize.height * scale;
    return Offset(
      (widgetSize.width - scaledW) / 2,
      (widgetSize.height - scaledH) / 2,
    );
  }

  Offset mapPoint(double x, double y) {
    final effective = _effectiveAnalysisSize;
    if (effective.isEmpty) return Offset.zero;

    final toPreviewX = previewSourceSize.width / effective.width;
    final toPreviewY = previewSourceSize.height / effective.height;
    var px = x * toPreviewX;
    var py = y * toPreviewY;

    final scale = _coverScale;
    final offset = _coverOffset;
    px = px * scale + offset.dx;
    py = py * scale + offset.dy;

    if (lensDirection == CameraLensDirection.front) {
      px = widgetSize.width - px;
    }

    return Offset(px, py);
  }

  Rect? mapRect(Rect rect) {
    if (widgetSize.isEmpty) return null;
    final topLeft = mapPoint(rect.left, rect.top);
    final bottomRight = mapPoint(rect.right, rect.bottom);
    return Rect.fromPoints(topLeft, bottomRight);
  }

  List<Offset> mapContour(FaceContour? contour) {
    if (contour == null || contour.points.isEmpty) return [];
    return contour.points.map((p) => mapPoint(p.x.toDouble(), p.y.toDouble())).toList();
  }
}

/// Inflates bounds so oval covers forehead and jaw beyond ML Kit box.
Rect vgInflateFaceBounds(Rect bounds) {
  return Rect.fromCenter(
    center: bounds.center,
    width: bounds.width * 1.18,
    height: bounds.height * 1.32,
  );
}

/// Oval points from contour or inflated bounding rect.
List<Offset> vgOvalPointsFromRect(Rect bounds, {int segments = 32}) {
  final oval = vgInflateFaceBounds(bounds);
  return List.generate(segments, (i) {
    final t = (i / segments) * 2 * math.pi;
    return Offset(
      oval.center.dx + (oval.width / 2) * math.cos(t),
      oval.center.dy + (oval.height / 2) * math.sin(t),
    );
  });
}

/// Smooth contour movement between frames.
List<Offset> vgSmoothContourPoints(List<Offset>? previous, List<Offset> current, {double factor = 0.35}) {
  if (previous == null || previous.isEmpty || previous.length != current.length) {
    return current;
  }
  return List.generate(current.length, (i) {
    return Offset.lerp(previous[i], current[i], factor)!;
  });
}

Rect? vgBoundsFromPoints(List<Offset> points) {
  if (points.isEmpty) return null;
  var left = points.first.dx;
  var top = points.first.dy;
  var right = points.first.dx;
  var bottom = points.first.dy;
  for (final p in points.skip(1)) {
    left = math.min(left, p.dx);
    top = math.min(top, p.dy);
    right = math.max(right, p.dx);
    bottom = math.max(bottom, p.dy);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

/// Mock scan score that drifts while tracking (7.0–9.5).
double vgMockTrackingScore(Rect faceRect, Size previewSize) {
  if (previewSize.isEmpty) return 7.5;
  final area = faceRect.width * faceRect.height;
  final previewArea = previewSize.width * previewSize.height;
  final ratio = (area / previewArea).clamp(0.05, 0.65);
  return (7.0 + ratio * 3.8).clamp(7.0, 9.5);
}

/// Centered guide bounds when no face is detected on a still photo.
Rect vgGuideFaceBounds(Size previewSize) {
  return Rect.fromCenter(
    center: Offset(previewSize.width / 2, previewSize.height * 0.44),
    width: previewSize.width * 0.62,
    height: previewSize.height * 0.68,
  );
}

/// Cosmetic face bounds for upload preview — maps ML Kit box into [previewSize].
Future<Rect?> vgDetectFaceBoundsFromFile(String path, Size previewSize) async {
  final faces = await vgDetectAllFaceBoundsFromFile(path, previewSize);
  if (faces.isEmpty) return null;
  return faces.first;
}

/// All face bounding boxes mapped into [targetSize], sorted left-to-right.
Future<List<Rect>> vgDetectAllFaceBoundsFromFile(String path, Size targetSize) async {
  if (targetSize.isEmpty) return [];

  final bytes = await File(path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return [];

  final imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
  final detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  try {
    final faces = await detector.processImage(InputImage.fromFilePath(path));
    if (faces.isEmpty) return [];

    final scaleX = targetSize.width / imageSize.width;
    final scaleY = targetSize.height / imageSize.height;

    final rects = faces.map((face) {
      final box = face.boundingBox;
      return Rect.fromLTRB(
        box.left * scaleX,
        box.top * scaleY,
        box.right * scaleX,
        box.bottom * scaleY,
      );
    }).toList();

    rects.sort((a, b) => a.center.dx.compareTo(b.center.dx));
    return rects;
  } finally {
    await detector.close();
  }
}

/// Face contour points normalized 0–1, sorted left-to-right (Face 1, Face 2).
Future<List<Map<String, dynamic>>> vgDetectFaceContoursNormalized(String path) async {
  final bytes = await File(path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return [];

  final imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
  final detector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  try {
    final faces = await detector.processImage(InputImage.fromFilePath(path));
    if (faces.isEmpty) return [];

    final sortedFaces = faces.toList()
      ..sort((a, b) => a.boundingBox.center.dx.compareTo(b.boundingBox.center.dx));

    const colors = [0xFFE07A9A, 0xFF5B8DEF];
    final results = <Map<String, dynamic>>[];

    for (var i = 0; i < sortedFaces.length; i++) {
      final face = sortedFaces[i];
      final contour = face.contours[FaceContourType.face];
      final points = <List<double>>[];

      if (contour != null && contour.points.isNotEmpty) {
        for (final p in contour.points) {
          points.add([
            (p.x / imageSize.width).clamp(0.0, 1.0),
            (p.y / imageSize.height).clamp(0.0, 1.0),
          ]);
        }
      } else {
        final box = face.boundingBox;
        points.addAll(_ovalContourFromRect(box, imageSize));
      }

      results.add({
        'id': 'face${i + 1}',
        'label': 'Face ${i + 1}',
        'color': colors[i % colors.length],
        'contourPoints': points,
        'center': {
          'x': (face.boundingBox.center.dx / imageSize.width).clamp(0.0, 1.0),
          'y': (face.boundingBox.top / imageSize.height).clamp(0.0, 1.0),
        },
      });
    }

    return results;
  } finally {
    await detector.close();
  }
}

List<List<double>> _ovalContourFromRect(Rect box, Size imageSize, {int segments = 24}) {
  final cx = box.center.dx / imageSize.width;
  final cy = box.center.dy / imageSize.height;
  final rx = (box.width / imageSize.width) * 0.55;
  final ry = (box.height / imageSize.height) * 0.62;
  return List.generate(segments, (i) {
    final t = (i / segments) * 2 * math.pi;
    return [
      (cx + rx * math.cos(t)).clamp(0.0, 1.0),
      (cy + ry * math.sin(t)).clamp(0.0, 1.0),
    ];
  });
}

/// Union rect of all faces with padding, clamped to image bounds.
Rect vgUnionFaceBounds(List<Rect> faces, Size imageSize, {double padding = 0.08}) {
  if (faces.isEmpty) {
    return Rect.fromCenter(
      center: Offset(imageSize.width / 2, imageSize.height / 2),
      width: imageSize.width * 0.8,
      height: imageSize.height * 0.8,
    );
  }

  var left = faces.first.left;
  var top = faces.first.top;
  var right = faces.first.right;
  var bottom = faces.first.bottom;
  for (final f in faces.skip(1)) {
    left = math.min(left, f.left);
    top = math.min(top, f.top);
    right = math.max(right, f.right);
    bottom = math.max(bottom, f.bottom);
  }

  final padX = imageSize.width * padding;
  final padY = imageSize.height * padding;
  return Rect.fromLTRB(
    (left - padX).clamp(0.0, imageSize.width),
    (top - padY).clamp(0.0, imageSize.height),
    (right + padX).clamp(0.0, imageSize.width),
    (bottom + padY).clamp(0.0, imageSize.height),
  );
}

/// Legacy wrapper — prefer [VgCameraCoordinateMapper].
Rect? vgMapFaceRectToPreview({
  required Rect faceRect,
  required Size imageSize,
  required Size previewSize,
  required CameraLensDirection lensDirection,
  required int sensorOrientation,
}) {
  final rotation = _rotationFromSensor(sensorOrientation);
  final mapper = VgCameraCoordinateMapper(
    widgetSize: previewSize,
    analysisImageSize: imageSize,
    previewSourceSize: previewSize,
    rotation: rotation,
    lensDirection: lensDirection,
  );
  return mapper.mapRect(faceRect);
}

extension SizeExt on Size {
  bool get isEmpty => width <= 0 || height <= 0;
}
