import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';
import 'vg_overlay_label_layout.dart';

/// Leader-line labels on the portrait (text-only pills, no score chips).
class VGBeautyAnnotationOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> annotations;

  const VGBeautyAnnotationOverlay({super.key, required this.annotations});

  static const _edgeInset = 10.0;
  static const _pillMaxWidthFactor = 0.36;
  static const _pillHeight = 48.0;

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
              painter: _BeautyAnnotationPainter(
                layouts: layouts,
                size: size,
              ),
              size: Size.infinite,
            ),
            ...layouts.map((layout) => _labelWidget(layout, size)),
          ],
        );
      },
    );
  }

  List<_BeautyAnnotationLayout> _buildLayouts(Size size) {
    return annotations.map((a) => _layoutFrom(a, size)).toList();
  }

  void _resolveCollisions(List<_BeautyAnnotationLayout> layouts, Size size) {
    final sides = layouts.map((l) => l.side).toList();
    final tops = layouts.map((l) => l.top).toList();
    VGOverlayLabelLayout.balanceVerticalSides(
      sides: sides,
      tops: tops,
      pillHeight: _pillHeight,
      proximity: 16,
    );
    for (var i = 0; i < layouts.length; i++) {
      layouts[i].side = sides[i];
    }

    final maxTop = size.height - _edgeInset - _pillHeight;
    for (final side in ['left', 'right']) {
      final items = layouts.where((l) => l.side == side).toList();
      if (items.length < 2) continue;
      final itemTops = items.map((l) => l.top).toList();
      VGOverlayLabelLayout.resolveVerticalCollisions(
        tops: itemTops,
        pillHeight: _pillHeight,
        minTop: _edgeInset,
        maxTop: maxTop,
        extraGap: 16,
      );
      for (var i = 0; i < items.length; i++) {
        items[i].top = itemTops[i];
      }
    }
  }

  _BeautyAnnotationLayout _layoutFrom(Map<String, dynamic> annotation, Size size) {
    final anchor = annotation['anchor'] as Map<String, dynamic>? ?? {};
    final ay = (anchor['y'] as num? ?? 0.5).toDouble();
    final side = (annotation['labelSide'] as String? ?? 'right').toLowerCase();
    final top = (ay * size.height - 24).clamp(_edgeInset, size.height - _edgeInset - _pillHeight);
    return _BeautyAnnotationLayout(
      annotation: annotation,
      side: side,
      top: top,
    );
  }

  Widget _labelWidget(_BeautyAnnotationLayout layout, Size size) {
    final text = layout.annotation['text'] as String? ?? '';
    final maxW = size.width * _pillMaxWidthFactor;
    final pill = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: _AnnotationPill(text: text),
    );

    switch (layout.side) {
      case 'left':
        return Positioned(left: _edgeInset, top: layout.top, child: pill);
      case 'top':
        return Positioned(
          top: _edgeInset,
          left: _edgeInset,
          right: _edgeInset,
          child: Align(alignment: Alignment.topCenter, child: pill),
        );
      case 'bottom':
        return Positioned(
          bottom: _edgeInset,
          left: _edgeInset,
          right: _edgeInset,
          child: Align(alignment: Alignment.bottomCenter, child: pill),
        );
      default:
        return Positioned(right: _edgeInset, top: layout.top, child: pill);
    }
  }
}

class _BeautyAnnotationLayout {
  final Map<String, dynamic> annotation;
  String side;
  double top;

  _BeautyAnnotationLayout({
    required this.annotation,
    required this.side,
    required this.top,
  });
}

class _AnnotationPill extends StatelessWidget {
  final String text;

  const _AnnotationPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFC5A373).withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: bmSpecialColorDark,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        maxLines: 4,
        softWrap: true,
      ),
    );
  }
}

class _BeautyAnnotationPainter extends CustomPainter {
  final List<_BeautyAnnotationLayout> layouts;
  final Size size;

  _BeautyAnnotationPainter({required this.layouts, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final linePaint = Paint()
      ..color = const Color(0xFFC5A373).withValues(alpha: 0.7)
      ..strokeWidth = 1;

    for (final layout in layouts) {
      final anchor = layout.annotation['anchor'] as Map<String, dynamic>? ?? {};
      final ax = (anchor['x'] as num? ?? 0.5).toDouble() * size.width;
      final ay = (anchor['y'] as num? ?? 0.5).toDouble() * size.height;
      final anchorPx = Offset(ax, ay);
      final labelPx = _leaderEnd(anchorPx, layout.side, layout.top, size);
      canvas.drawLine(anchorPx, labelPx, linePaint);
    }
  }

  Offset _leaderEnd(Offset anchor, String side, double top, Size s) {
    const inset = VGBeautyAnnotationOverlay._edgeInset;
    switch (side) {
      case 'left':
        return Offset(inset + s.width * _pillMaxWidthFactor * 0.5, top + 24);
      case 'top':
        return Offset(anchor.dx, inset + 28);
      case 'bottom':
        return Offset(anchor.dx, s.height - inset - 28);
      default:
        return Offset(s.width - inset - s.width * _pillMaxWidthFactor * 0.5, top + 24);
    }
  }

  static const _pillMaxWidthFactor = 0.36;

  @override
  bool shouldRepaint(covariant _BeautyAnnotationPainter oldDelegate) =>
      oldDelegate.layouts != layouts;
}
