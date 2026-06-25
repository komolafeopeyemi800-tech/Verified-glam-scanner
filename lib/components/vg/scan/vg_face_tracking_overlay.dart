import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/vg_camera_utils.dart';
import '../../../utils/vg_copy.dart';

/// KYC-style face tracking: oval frame + mesh clipped inside, follows detected face.
class VGFaceTrackingOverlay extends StatelessWidget {
  final List<Offset>? faceOvalPoints;
  final Rect? faceBounds;
  final double scanProgress;
  final double score;
  final bool showBadge;
  final bool showStatus;
  final bool guideMode;
  final String? statusText;

  const VGFaceTrackingOverlay({
    super.key,
    this.faceOvalPoints,
    this.faceBounds,
    this.scanProgress = 0,
    this.score = 7.5,
    this.showBadge = true,
    this.showStatus = true,
    this.guideMode = false,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final points = faceOvalPoints;
        final bounds = faceBounds ?? (points != null ? vgBoundsFromPoints(points) : null);
        final isTracking = !guideMode && (points != null || bounds != null);
        final ovalPoints = points ?? (bounds != null ? vgOvalPointsFromRect(bounds) : _guideOvalPoints(size));
        final displayScore = isTracking ? score : 7.2;

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _FaceTrackingPainter(
                ovalPoints: ovalPoints,
                bounds: bounds ?? vgBoundsFromPoints(ovalPoints),
                scanProgress: scanProgress,
                score: displayScore,
                showBadge: showBadge,
                guideMode: !isTracking,
              ),
            ),
            if (showStatus)
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Text(
                  statusText ?? (isTracking ? VGCopy.cameraFaceDetected : VGCopy.cameraAlignFace),
                  style: boldTextStyle(color: Colors.white, size: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }

  List<Offset> _guideOvalPoints(Size size) {
    return vgOvalPointsFromRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.44),
        width: size.width * 0.58,
        height: size.height * 0.68,
      ),
    );
  }
}

class _FaceTrackingPainter extends CustomPainter {
  final List<Offset> ovalPoints;
  final Rect? bounds;
  final double scanProgress;
  final double score;
  final bool showBadge;
  final bool guideMode;

  _FaceTrackingPainter({
    required this.ovalPoints,
    required this.bounds,
    required this.scanProgress,
    required this.score,
    required this.showBadge,
    required this.guideMode,
  });

  Path _ovalPath() {
    final path = Path();
    if (ovalPoints.isEmpty) return path;
    path.moveTo(ovalPoints.first.dx, ovalPoints.first.dy);
    for (final p in ovalPoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final oval = _ovalPath();
    if (ovalPoints.isEmpty) return;

    if (guideMode) {
      final dash = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      _drawDashedPath(canvas, oval, dash);
      return;
    }

    canvas.save();
    canvas.clipPath(oval);

    _drawMesh(canvas);
    _drawTriangle(canvas);
    _drawScanLine(canvas);

    canvas.restore();

    final frame = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(oval, frame);

    final glow = Paint()
      ..color = const Color(0xFF4ADE80).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(oval, glow);

    if (showBadge && bounds != null) _drawScoreBadge(canvas, bounds!);
  }

  void _drawMesh(Canvas canvas) {
    if (bounds == null) return;
    final b = bounds!;

    final mesh = Paint()
      ..color = const Color(0xFFE53935).withValues(alpha: 0.7)
      ..strokeWidth = 1;

    const rows = 6;
    const cols = 5;
    for (var r = 0; r <= rows; r++) {
      final t = r / rows;
      final y = b.top + b.height * t;
      canvas.drawLine(Offset(b.left, y), Offset(b.right, y), mesh);
    }
    for (var c = 0; c <= cols; c++) {
      final t = c / cols;
      final x = b.left + b.width * t;
      canvas.drawLine(Offset(x, b.top), Offset(x, b.bottom), mesh);
    }

    final radial = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    final center = b.center;
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final edge = Offset(
        center.dx + (b.width / 2) * math.cos(angle),
        center.dy + (b.height / 2) * math.sin(angle),
      );
      canvas.drawLine(center, edge, radial);
    }

    const metrics = ['17.36', '20.15', '36.04', '10.28'];
    final positions = [
      Offset(b.left + 6, b.top + 10),
      Offset(b.center.dx - 14, b.top + 6),
      Offset(b.right - 40, b.top + 14),
      Offset(b.left + 10, b.center.dy),
    ];
    for (var i = 0; i < metrics.length; i++) {
      _drawMetric(canvas, metrics[i], positions[i]);
    }
  }

  void _drawMetric(Canvas canvas, String value, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(color: Color(0xFFFFEB3B), fontSize: 9, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  void _drawTriangle(Canvas canvas) {
    if (bounds == null) return;
    final b = bounds!;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final eyeY = b.top + b.height * 0.32;
    final chin = Offset(b.center.dx, b.bottom - 6);
    final leftEye = Offset(b.left + b.width * 0.2, eyeY);
    final rightEye = Offset(b.right - b.width * 0.2, eyeY);

    canvas.drawLine(leftEye, rightEye, paint);
    canvas.drawLine(leftEye, chin, paint);
    canvas.drawLine(rightEye, chin, paint);
  }

  void _drawScanLine(Canvas canvas) {
    if (bounds == null) return;
    final b = bounds!;
    final y = b.top + b.height * scanProgress.clamp(0.0, 1.0);
    final scanPaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(b.left + 8, y), Offset(b.right - 8, y), scanPaint);
  }

  void _drawScoreBadge(Canvas canvas, Rect b) {
    final badgeCenter = Offset(b.center.dx, b.top - 18);
    const badgeW = 56.0;
    const badgeH = 28.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: badgeCenter, width: badgeW, height: badgeH),
      const Radius.circular(14),
    );

    final bg = Paint()..color = const Color(0xFF1A1A1A).withValues(alpha: 0.92);
    final border = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, bg);
    canvas.drawRRect(rrect, border);

    final scoreText = score.toStringAsFixed(2);
    final tp = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFF00BCD4), Color(0xFFE91E63)],
            ).createShader(Rect.fromLTWH(0, 0, badgeW, badgeH)),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(badgeCenter.dx - tp.width / 2, badgeCenter.dy - tp.height / 2));
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 8;
        canvas.drawPath(metric.extractPath(distance, math.min(next, metric.length)), paint);
        distance = next + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FaceTrackingPainter oldDelegate) {
    return oldDelegate.ovalPoints != ovalPoints ||
        oldDelegate.bounds != bounds ||
        oldDelegate.scanProgress != scanProgress ||
        oldDelegate.score != score ||
        oldDelegate.guideMode != guideMode;
  }
}

/// Animated overlay wrapper for processing / preview pulse.
class VGFaceTrackingOverlayAnimated extends StatefulWidget {
  final List<Offset>? faceOvalPoints;
  final Rect? faceBounds;
  final Size previewSize;

  const VGFaceTrackingOverlayAnimated({
    super.key,
    this.faceOvalPoints,
    this.faceBounds,
    required this.previewSize,
  });

  @override
  State<VGFaceTrackingOverlayAnimated> createState() => _VGFaceTrackingOverlayAnimatedState();
}

/// Post-capture preview overlay: cosmetic scan animation, then ready message.
class VGPhotoCaptureReviewOverlay extends StatefulWidget {
  final Rect? faceBounds;
  final Size previewSize;
  final bool scanning;
  final bool ready;
  final bool faceDetected;

  const VGPhotoCaptureReviewOverlay({
    super.key,
    required this.faceBounds,
    required this.previewSize,
    required this.scanning,
    required this.ready,
    required this.faceDetected,
  });

  @override
  State<VGPhotoCaptureReviewOverlay> createState() => _VGPhotoCaptureReviewOverlayState();
}

class _VGPhotoCaptureReviewOverlayState extends State<VGPhotoCaptureReviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Rect get _displayBounds {
    return widget.faceBounds ?? vgGuideFaceBounds(widget.previewSize);
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _displayBounds;
    final tracking = widget.faceDetected && widget.faceBounds != null;
    final statusText = widget.ready
        ? (tracking ? VGCopy.cameraPerfectCapture : VGCopy.cameraAlignFace)
        : VGCopy.cameraScanning;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return VGFaceTrackingOverlay(
          faceOvalPoints: vgOvalPointsFromRect(bounds),
          faceBounds: bounds,
          scanProgress: widget.scanning ? _controller.value : 1.0,
          score: vgMockTrackingScore(bounds, widget.previewSize),
          showBadge: false,
          showStatus: true,
          guideMode: !tracking,
          statusText: statusText,
        );
      },
    );
  }
}

class _VGFaceTrackingOverlayAnimatedState extends State<VGFaceTrackingOverlayAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bounds = widget.faceBounds ??
        Rect.fromCenter(
          center: Offset(widget.previewSize.width / 2, widget.previewSize.height * 0.45),
          width: widget.previewSize.width * 0.58,
          height: widget.previewSize.height * 0.68,
        );
    final score = vgMockTrackingScore(bounds, widget.previewSize);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return VGFaceTrackingOverlay(
          faceOvalPoints: widget.faceOvalPoints ?? vgOvalPointsFromRect(bounds),
          faceBounds: bounds,
          scanProgress: _controller.value,
          score: score,
          showStatus: false,
        );
      },
    );
  }
}
