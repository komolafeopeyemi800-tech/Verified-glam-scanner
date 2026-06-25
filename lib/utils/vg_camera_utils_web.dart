import 'dart:ui';

import 'package:flutter/material.dart';

/// Web stub — ML Kit and live camera mapping are mobile-only.
dynamic vgInputImageFromCameraImage(dynamic image, dynamic camera) => null;

class VgCameraCoordinateMapper {
  final Size widgetSize;
  final Size analysisImageSize;
  final Size previewSourceSize;
  final dynamic rotation;
  final dynamic lensDirection;

  VgCameraCoordinateMapper({
    required this.widgetSize,
    required this.analysisImageSize,
    required this.previewSourceSize,
    required this.rotation,
    required this.lensDirection,
  });

  Offset mapPoint(double x, double y) => Offset.zero;

  Rect? mapRect(Rect rect) => null;

  List<Offset> mapContour(dynamic contour) => [];
}

Rect vgInflateFaceBounds(Rect bounds) => bounds;

List<Offset> vgOvalPointsFromRect(Rect bounds, {int segments = 32}) => [];

List<Offset> vgSmoothContourPoints(List<Offset>? previous, List<Offset> current, {double factor = 0.35}) =>
    current;

Rect? vgBoundsFromPoints(List<Offset> points) => null;

double vgMockTrackingScore(Rect faceRect, Size previewSize) => 7.5;

Rect vgGuideFaceBounds(Size previewSize) {
  return Rect.fromCenter(
    center: Offset(previewSize.width / 2, previewSize.height * 0.44),
    width: previewSize.width * 0.62,
    height: previewSize.height * 0.68,
  );
}

Future<Rect?> vgDetectFaceBoundsFromFile(String path, Size previewSize) async => null;

Future<List<Rect>> vgDetectAllFaceBoundsFromFile(String path, Size targetSize) async => [];

Future<List<Map<String, dynamic>>> vgDetectFaceContoursNormalized(String path) async => [];

Rect vgUnionFaceBounds(List<Rect> faces, Size imageSize, {double padding = 0.08}) {
  return Rect.fromCenter(
    center: Offset(imageSize.width / 2, imageSize.height / 2),
    width: imageSize.width * 0.8,
    height: imageSize.height * 0.8,
  );
}

Rect? vgMapFaceRectToPreview({
  required Rect faceRect,
  required Size imageSize,
  required Size previewSize,
  required dynamic lensDirection,
  required int sensorOrientation,
}) =>
    null;
