import 'package:flutter/material.dart';

import '../../../utils/BMColors.dart';
import 'vg_overlay_label_layout.dart';

/// Leader-line symmetry score pills on the portrait hero.
class VGSymmetryCalloutOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> regions;

  const VGSymmetryCalloutOverlay({super.key, required this.regions});

  static const _edgeInset = 8.0;
  static const _pillMaxWidthFactor = 0.40;
  static const _pillHeight = 36.0;

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
              painter: _SymmetryCalloutPainter(layouts: layouts, size: size),
              size: Size.infinite,
            ),
            ...layouts.map((layout) => _pillWidget(layout, size)),
          ],
        );
      },
    );
  }

  List<_SymmetryLayout> _buildLayouts(Size size) {
    return regions.map((r) => _layoutFrom(r, size)).toList();
  }

  void _resolveCollisions(List<_SymmetryLayout> layouts, Size size) {
    final sides = layouts.map((l) => l.side).toList();
    final tops = layouts.map((l) => l.top).toList();
    VGOverlayLabelLayout.balanceVerticalSides(
      sides: sides,
      tops: tops,
      pillHeight: _pillHeight,
      proximity: 14,
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
        extraGap: 14,
      );
      for (var i = 0; i < items.length; i++) {
        items[i].top = itemTops[i];
      }
    }
  }

  _SymmetryLayout _layoutFrom(Map<String, dynamic> region, Size size) {
    final anchor = region['anchor'] as Map<String, dynamic>? ?? {};
    final ay = (anchor['y'] as num? ?? 0.5).toDouble();
    final side = (region['labelSide'] as String? ?? 'right').toLowerCase();
    final top = (ay * size.height - 14).clamp(_edgeInset, size.height - _edgeInset - _pillHeight);
    return _SymmetryLayout(region: region, side: side, top: top);
  }

  Widget _pillWidget(_SymmetryLayout layout, Size size) {
    final region = layout.region;
    final label = (region['label'] as String? ?? 'Symmetry').toUpperCase();
    final percent = (region['percent'] as num?)?.round() ?? 0;
    final color = Color(region['color'] as int? ?? 0xFFFFFFFF);
    final icon = region['icon'] as String? ?? 'circle';
    final maxW = size.width * _pillMaxWidthFactor;

    final pill = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: _SymmetryPill(
        text: '$label: $percent%',
        accentColor: color,
        iconKey: icon,
      ),
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

class _SymmetryLayout {
  final Map<String, dynamic> region;
  String side;
  double top;

  _SymmetryLayout({required this.region, required this.side, required this.top});
}

class _SymmetryPill extends StatelessWidget {
  final String text;
  final Color accentColor;
  final String iconKey;

  const _SymmetryPill({
    required this.text,
    required this.accentColor,
    required this.iconKey,
  });

  IconData get _icon {
    switch (iconKey) {
      case 'star':
        return Icons.star_rounded;
      case 'heart':
        return Icons.favorite_rounded;
      case 'check':
        return Icons.check_circle_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 10, color: accentColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: bmSpecialColorDark,
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SymmetryCalloutPainter extends CustomPainter {
  final List<_SymmetryLayout> layouts;
  final Size size;

  _SymmetryCalloutPainter({required this.layouts, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final layout in layouts) {
      final anchor = layout.region['anchor'] as Map<String, dynamic>? ?? {};
      final ax = (anchor['x'] as num? ?? 0.5).toDouble() * size.width;
      final ay = (anchor['y'] as num? ?? 0.5).toDouble() * size.height;
      final color = Color(layout.region['color'] as int? ?? 0xFFFFFFFF);

      final linePaint = Paint()
        ..color = color.withValues(alpha: 0.75)
        ..strokeWidth = 1;

      final anchorPx = Offset(ax, ay);
      final labelPx = _leaderEnd(anchorPx, layout.side, layout.top, size);
      canvas.drawLine(anchorPx, labelPx, linePaint);
    }
  }

  Offset _leaderEnd(Offset anchor, String side, double top, Size s) {
    const inset = VGSymmetryCalloutOverlay._edgeInset;
    switch (side) {
      case 'left':
        return Offset(inset + s.width * _pillMaxWidthFactor * 0.45, top + 18);
      case 'top':
        return Offset(anchor.dx, inset + 24);
      case 'bottom':
        return Offset(anchor.dx, s.height - inset - 24);
      default:
        return Offset(s.width - inset - s.width * _pillMaxWidthFactor * 0.45, top + 18);
    }
  }

  static const _pillMaxWidthFactor = 0.40;

  @override
  bool shouldRepaint(covariant _SymmetryCalloutPainter oldDelegate) =>
      oldDelegate.layouts != layouts;
}
