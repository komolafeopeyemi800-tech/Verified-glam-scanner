import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';
import 'vg_overlay_label_layout.dart';

/// Per-spot skin concern callouts: anchor-aligned pills, collision nudging, leader lines.
class VGSkinConcernOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> annotations;

  const VGSkinConcernOverlay({super.key, required this.annotations});

  static const _edgeInset = 6.0;
  static const _pillMaxWidth = 88.0;

  bool get _dense => annotations.length > 6;

  double get _pillHeight => _dense ? 22.0 : 26.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final layouts = _buildLayouts(size);
        _resolveCollisions(layouts, size);

        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _SkinConcernPainter(layouts: layouts, size: size),
              size: Size.infinite,
            ),
            ...layouts.map((layout) => _pillAt(layout, size)),
          ],
        );
      },
    );
  }

  List<_SkinConcernLayout> _buildLayouts(Size size) {
    return annotations.map((a) => _layoutFromAnnotation(a, size)).toList();
  }

  _SkinConcernLayout _layoutFromAnnotation(Map<String, dynamic> a, Size size, {String? sideOverride}) {
    final anchor = a['anchor'] as Map<String, dynamic>? ?? {};
    final ax = (anchor['x'] as num? ?? 0.5).toDouble();
    final ay = (anchor['y'] as num? ?? 0.5).toDouble();
    final side = (sideOverride ?? a['labelSide'] as String? ?? 'right').toLowerCase();
    final color = Color((a['color'] as int?) ?? 0xFFE07A9A);
    final featurePx = Offset(ax * size.width, ay * size.height);
    final pillH = _pillHeight;

    double top;
    Offset labelCenter;
    Offset lineStart;

    if (side == 'left') {
      top = (ay * size.height - pillH / 2).clamp(_edgeInset, size.height - _edgeInset - pillH);
      labelCenter = Offset(_edgeInset + _pillMaxWidth / 2, top + pillH / 2);
      lineStart = Offset(_edgeInset + _pillMaxWidth, top + pillH / 2);
    } else if (side == 'top') {
      top = _edgeInset;
      final left = (ax * size.width - _pillMaxWidth / 2)
          .clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth);
      labelCenter = Offset(left + _pillMaxWidth / 2, _edgeInset + pillH / 2);
      lineStart = Offset(left + _pillMaxWidth / 2, _edgeInset + pillH);
    } else if (side == 'bottom') {
      top = size.height - _edgeInset - pillH;
      final leftB = (ax * size.width - _pillMaxWidth / 2)
          .clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth);
      labelCenter = Offset(leftB + _pillMaxWidth / 2, top + pillH / 2);
      lineStart = Offset(leftB + _pillMaxWidth / 2, top);
    } else {
      top = (ay * size.height - pillH / 2).clamp(_edgeInset, size.height - _edgeInset - pillH);
      labelCenter = Offset(size.width - _edgeInset - _pillMaxWidth / 2, top + pillH / 2);
      lineStart = Offset(size.width - _edgeInset - _pillMaxWidth, top + pillH / 2);
    }

    return _SkinConcernLayout(
      annotation: a,
      featurePoint: featurePx,
      labelCenter: labelCenter,
      lineStart: lineStart,
      top: top,
      side: side,
      color: color,
      pillHeight: pillH,
      dense: _dense,
    );
  }

  void _resolveCollisions(List<_SkinConcernLayout> layouts, Size size) {
    _balanceSides(layouts, size);
    final maxTop = size.height - _edgeInset - _pillHeight;

    final verticalSides = {'left', 'right'};
    for (final side in verticalSides) {
      final items = layouts.where((l) => l.side == side).toList();
      if (items.length < 2) continue;
      final tops = items.map((l) => l.top).toList();
      VGOverlayLabelLayout.resolveVerticalCollisions(
        tops: tops,
        pillHeight: _pillHeight,
        minTop: _edgeInset,
        maxTop: maxTop,
      );
      for (var i = 0; i < items.length; i++) {
        items[i].top = tops[i];
        items[i].labelCenter = Offset(items[i].labelCenter.dx, tops[i] + items[i].pillHeight / 2);
        items[i].lineStart = _lineStartFor(items[i], size);
      }
    }

    final topItems = layouts.where((l) => l.side == 'top').toList();
    if (topItems.length >= 2) {
      final lefts = topItems
          .map((l) => (l.labelCenter.dx - _pillMaxWidth / 2).clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth))
          .toList();
      VGOverlayLabelLayout.resolveHorizontalCollisions(
        lefts: lefts,
        pillWidth: _pillMaxWidth,
        minLeft: _edgeInset,
        maxLeft: size.width - _edgeInset - _pillMaxWidth,
      );
      for (var i = 0; i < topItems.length; i++) {
        topItems[i].labelCenter = Offset(lefts[i] + _pillMaxWidth / 2, topItems[i].labelCenter.dy);
        topItems[i].lineStart = _lineStartFor(topItems[i], size);
      }
    }

    final bottomItems = layouts.where((l) => l.side == 'bottom').toList();
    if (bottomItems.length >= 2) {
      final lefts = bottomItems
          .map((l) => (l.labelCenter.dx - _pillMaxWidth / 2).clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth))
          .toList();
      VGOverlayLabelLayout.resolveHorizontalCollisions(
        lefts: lefts,
        pillWidth: _pillMaxWidth,
        minLeft: _edgeInset,
        maxLeft: size.width - _edgeInset - _pillMaxWidth,
      );
      for (var i = 0; i < bottomItems.length; i++) {
        bottomItems[i].labelCenter = Offset(lefts[i] + _pillMaxWidth / 2, bottomItems[i].labelCenter.dy);
        bottomItems[i].lineStart = _lineStartFor(bottomItems[i], size);
      }
    }
  }

  void _balanceSides(List<_SkinConcernLayout> layouts, Size size) {
    for (var i = 0; i < layouts.length; i++) {
      for (var j = i + 1; j < layouts.length; j++) {
        final a = layouts[i];
        final b = layouts[j];
        if (a.side != b.side || a.side == 'top' || a.side == 'bottom') continue;
        if ((a.top - b.top).abs() > _pillHeight + 8) continue;
        final newSide = a.side == 'left' ? 'right' : 'left';
        layouts[j] = _layoutFromAnnotation(b.annotation, size, sideOverride: newSide);
      }
    }
  }

  Offset _lineStartFor(_SkinConcernLayout layout, Size size) {
    final pillH = layout.pillHeight;
    switch (layout.side) {
      case 'left':
        return Offset(_edgeInset + _pillMaxWidth, layout.top + pillH / 2);
      case 'top':
        return Offset(layout.labelCenter.dx, _edgeInset + pillH);
      case 'bottom':
        return Offset(layout.labelCenter.dx, layout.top);
      default:
        return Offset(size.width - _edgeInset - _pillMaxWidth, layout.top + pillH / 2);
    }
  }

  Widget _pillAt(_SkinConcernLayout layout, Size size) {
    final text = layout.annotation['text'] as String? ?? '';
    final pill = _ConcernPill(text: text, color: layout.color, dense: layout.dense);

    switch (layout.side) {
      case 'left':
        return Positioned(
          left: _edgeInset,
          top: layout.top,
          child: SizedBox(width: _pillMaxWidth, child: pill),
        );
      case 'top':
        return Positioned(
          top: _edgeInset,
          left: (layout.labelCenter.dx - _pillMaxWidth / 2)
              .clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth),
          child: SizedBox(width: _pillMaxWidth, child: pill),
        );
      case 'bottom':
        return Positioned(
          top: layout.top,
          left: (layout.labelCenter.dx - _pillMaxWidth / 2)
              .clamp(_edgeInset, size.width - _edgeInset - _pillMaxWidth),
          child: SizedBox(width: _pillMaxWidth, child: pill),
        );
      default:
        return Positioned(
          right: _edgeInset,
          top: layout.top,
          child: SizedBox(width: _pillMaxWidth, child: pill),
        );
    }
  }
}

class _SkinConcernLayout {
  final Map<String, dynamic> annotation;
  final Offset featurePoint;
  Offset labelCenter;
  Offset lineStart;
  double top;
  final String side;
  final Color color;
  final double pillHeight;
  final bool dense;

  _SkinConcernLayout({
    required this.annotation,
    required this.featurePoint,
    required this.labelCenter,
    required this.lineStart,
    required this.top,
    required this.side,
    required this.color,
    required this.pillHeight,
    required this.dense,
  });
}

class _ConcernPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool dense;

  const _ConcernPill({required this.text, required this.color, required this.dense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 7, vertical: dense ? 3 : 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: bmSpecialColorDark,
          fontSize: dense ? 7 : 8,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SkinConcernPainter extends CustomPainter {
  final List<_SkinConcernLayout> layouts;
  final Size size;

  _SkinConcernPainter({required this.layouts, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final layout in layouts) {
      final zonePaint = Paint()
        ..color = layout.color.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(layout.featurePoint, denseRadius(layout.dense), zonePaint);

      final dotPaint = Paint()
        ..color = layout.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(layout.featurePoint, 3.5, dotPaint);

      final ringPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.92)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(layout.featurePoint, 3.5, ringPaint);

      final linePaint = Paint()
        ..color = layout.color.withValues(alpha: 0.8)
        ..strokeWidth = 1.0;
      canvas.drawLine(layout.lineStart, layout.featurePoint, linePaint);
    }
  }

  double denseRadius(bool dense) => dense ? 12 : 16;

  @override
  bool shouldRepaint(covariant _SkinConcernPainter oldDelegate) =>
      oldDelegate.layouts != layouts;
}
