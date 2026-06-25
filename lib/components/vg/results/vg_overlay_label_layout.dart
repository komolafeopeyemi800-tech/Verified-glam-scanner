/// Shared vertical/horizontal collision resolution for face overlay labels.
class VGOverlayLabelLayout {
  VGOverlayLabelLayout._();

  static double collisionGap(double pillHeight, {double extra = 8}) => pillHeight + extra;

  /// Flip vertically-close labels from one side to the other (left/right only).
  static void balanceVerticalSides({
    required List<String> sides,
    required List<double> tops,
    required double pillHeight,
    double proximity = 12,
  }) {
    for (var i = 0; i < sides.length; i++) {
      for (var j = i + 1; j < sides.length; j++) {
        final a = sides[i];
        final b = sides[j];
        if (a != b || a == 'top' || a == 'bottom') continue;
        if ((tops[i] - tops[j]).abs() > pillHeight + proximity) continue;
        sides[j] = a == 'left' ? 'right' : 'left';
      }
    }
  }

  /// Multi-pass vertical separation for left/right columns.
  static void resolveVerticalCollisions({
    required List<double> tops,
    required double pillHeight,
    required double minTop,
    required double maxTop,
    int maxPasses = 6,
    double extraGap = 8,
  }) {
    if (tops.isEmpty) return;
    final gap = collisionGap(pillHeight, extra: extraGap);
    final indices = List<int>.generate(tops.length, (i) => i)
      ..sort((a, b) => tops[a].compareTo(tops[b]));

    for (var pass = 0; pass < maxPasses; pass++) {
      var moved = false;
      for (var i = 1; i < indices.length; i++) {
        final prev = indices[i - 1];
        final curr = indices[i];
        if (tops[curr] - tops[prev] < gap) {
          tops[curr] = tops[prev] + gap;
          moved = true;
        }
      }
      for (final idx in indices) {
        final clamped = tops[idx].clamp(minTop, maxTop);
        if (clamped != tops[idx]) moved = true;
        tops[idx] = clamped;
      }
      if (!moved) break;
    }
  }

  /// Horizontal separation for top/bottom bands (left positions).
  static void resolveHorizontalCollisions({
    required List<double> lefts,
    required double pillWidth,
    required double minLeft,
    required double maxLeft,
    int maxPasses = 6,
  }) {
    if (lefts.isEmpty) return;
    final gap = 6.0;
    final indices = List<int>.generate(lefts.length, (i) => i)
      ..sort((a, b) => lefts[a].compareTo(lefts[b]));

    for (var pass = 0; pass < maxPasses; pass++) {
      var moved = false;
      for (var i = 1; i < indices.length; i++) {
        final prev = indices[i - 1];
        final curr = indices[i];
        if (lefts[curr] - lefts[prev] < pillWidth + gap) {
          lefts[curr] = lefts[prev] + pillWidth + gap;
          moved = true;
        }
      }
      for (final idx in indices) {
        final clamped = lefts[idx].clamp(minLeft, maxLeft);
        if (clamped != lefts[idx]) moved = true;
        lefts[idx] = clamped;
      }
      if (!moved) break;
    }
  }
}
