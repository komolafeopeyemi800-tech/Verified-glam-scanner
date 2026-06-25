/// Stable mock variation from photo path (local dev only — not real ML).
class VGMockAnalysisSeed {
  final int seed;

  VGMockAnalysisSeed(String? photoPath) : seed = photoPath?.hashCode ?? 0;

  double unit(int salt) {
    final combined = (seed ^ salt).abs();
    return (combined % 1000) / 1000.0;
  }

  double range(double min, double max, int salt) => min + unit(salt) * (max - min);

  int percent(int salt, {int min = 82, int max = 98}) =>
      (range(min.toDouble(), max.toDouble(), salt)).round();

  double scoreOutOf10(int salt) => double.parse(range(7.2, 9.2, salt).toStringAsFixed(1));
}
