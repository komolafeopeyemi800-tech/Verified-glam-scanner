/// Safe coercion for analysis payloads (OpenAI may return strings or wrong shapes).
class VGPayloadValues {
  VGPayloadValues._();

  static double? asDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final n = double.tryParse(v.trim());
      return n;
    }
    return null;
  }

  static int? asInt(dynamic v) {
    final d = asDouble(v);
    if (d == null) return null;
    return d.round();
  }

  static double asDoubleOr(dynamic v, double fallback) => asDouble(v) ?? fallback;

  static int asIntOr(dynamic v, int fallback) => asInt(v) ?? fallback;

  static Map<String, dynamic> asMap(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return const {};
  }

  static List<Map<String, dynamic>> asMapList(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (v is Map) return [Map<String, dynamic>.from(v)];
    return const [];
  }

  static List<String> asStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    if (v is String && v.trim().isNotEmpty) return [v.trim()];
    return const [];
  }

  static List<num> asNumList(dynamic v) {
    if (v is! List) return const [];
    return v.map(asDouble).whereType<num>().toList();
  }

  static bool isScoresFinalized(Map<String, dynamic> payload) =>
      payload['scoresFinalized'] == true;

  /// Encouraging display boost that preserves rank order (matches server scoring.ts).
  static int displayBoost(int score) {
    final s = score.clamp(0, 100);
    if (s <= 30) return (s * 2).clamp(0, 55);
    if (s <= 50) return (s + 20 + (50 - s) * 0.25).round().clamp(0, 100);
    if (s <= 75) return (s + 12).clamp(0, 100);
    if (s <= 90) return (s + 6).clamp(0, 100);
    return (s + 2).clamp(0, 96);
  }

  static double displayBoostOutOf10(double score) {
    final pct = displayBoost((score * 10).round());
    return (pct / 10).clamp(0.0, 10.0);
  }

  /// Coerce API values to 0–100 (handles 0–1 and 0–10 scales).
  static int normalizePercent(dynamic v, {int fallback = 75}) {
    var n = asDouble(v) ?? fallback.toDouble();
    if (n > 0 && n <= 1) {
      n *= 100;
    } else if (n > 1 && n <= 10) {
      n *= 10;
    }
    return displayBoost(n.round().clamp(0, 100));
  }

  /// Coerce API values to 0–10 display scale.
  static double normalizeOutOf10(dynamic v, {double fallback = 7.5}) {
    var n = asDouble(v) ?? fallback;
    if (n > 10 && n <= 100) {
      n /= 10;
    } else if (n > 0 && n <= 1) {
      n *= 10;
    }
    return displayBoostOutOf10(n.clamp(0.0, 10.0));
  }

  /// Read percent from payload — skips boost when server already finalized scores.
  static int displayPercent(
    Map<String, dynamic> payload,
    dynamic v, {
    int fallback = 75,
  }) {
    if (isScoresFinalized(payload)) return asIntOr(v, fallback);
    return normalizePercent(v, fallback: fallback);
  }

  /// Read /10 score from payload — skips boost when server already finalized scores.
  static double displayOutOf10(
    Map<String, dynamic> payload,
    dynamic v, {
    double fallback = 7.5,
  }) {
    if (isScoresFinalized(payload)) return asDoubleOr(v, fallback);
    return normalizeOutOf10(v, fallback: fallback);
  }

  /// Legacy alias — prefer [displayBoost].
  static int upliftPercent(int score) => displayBoost(score);

  /// Legacy alias — prefer [displayBoostOutOf10].
  static double upliftOutOf10(double score) => displayBoostOutOf10(score);

  /// Normalized face bounding box for attractiveness overlay (0–1 coords).
  static Map<String, double> normalizedFaceBox(
    dynamic raw, {
    double x = 0.21,
    double y = 0.18,
    double width = 0.58,
    double height = 0.48,
  }) {
    final box = asMap(raw);
    final topLeft = asMap(box['topLeft']);
    final bottomRight = asMap(box['bottomRight']);
    if (topLeft.isNotEmpty && bottomRight.isNotEmpty) {
      final x1 = (asDouble(topLeft['x']) ?? x).clamp(0.0, 1.0);
      final y1 = (asDouble(topLeft['y']) ?? y).clamp(0.0, 1.0);
      final x2 = (asDouble(bottomRight['x']) ?? (x1 + width)).clamp(0.0, 1.0);
      final y2 = (asDouble(bottomRight['y']) ?? (y1 + height)).clamp(0.0, 1.0);
      return {
        'x': x1.clamp(0.0, 0.75),
        'y': y1.clamp(0.0, 0.75),
        'width': (x2 - x1).abs().clamp(0.2, 0.85),
        'height': (y2 - y1).abs().clamp(0.2, 0.85),
      };
    }
    final nx = (asDouble(box['x']) ?? x).clamp(0.0, 0.75);
    final ny = (asDouble(box['y']) ?? y).clamp(0.0, 0.75);
    final nw = (asDouble(box['width']) ?? width).clamp(0.2, 0.85);
    final nh = (asDouble(box['height']) ?? height).clamp(0.2, 0.85);
    return {'x': nx, 'y': ny, 'width': nw, 'height': nh};
  }

  /// Landmark list for mesh overlay — accepts array or named-object API shapes.
  static List<Map<String, double>> normalizedLandmarkList(dynamic raw) {
    final points = <Map<String, double>>[];

    void addPoint(dynamic item) {
      if (item is! Map) return;
      final m = Map<String, dynamic>.from(item);
      final px = asDouble(m['x']);
      final py = asDouble(m['y']);
      if (px == null || py == null) return;
      if (px < 0 || px > 1 || py < 0 || py > 1) return;
      points.add({'x': px, 'y': py});
    }

    void addFromValue(dynamic value) {
      if (value is List) {
        for (final item in value) {
          addFromValue(item);
        }
        return;
      }
      addPoint(value);
    }

    if (raw is List) {
      for (final item in raw) {
        addFromValue(item);
      }
    } else if (raw is Map) {
      for (final value in raw.values) {
        addFromValue(value);
      }
    }

    if (points.length >= 4) return points;
    return List<Map<String, double>>.from(_defaultFaceReadingLandmarks);
  }

  static List<List<int>> defaultFaceReadingMeshConnections() {
    return [
      [0, 1], [1, 2], [2, 3],
      [4, 5], [6, 7], [5, 6],
      [8, 9], [9, 10], [9, 11], [10, 11],
      [12, 13], [13, 14], [14, 15], [12, 15],
      [16, 17], [17, 18], [19, 16], [20, 18],
      [1, 8], [2, 8],
      [5, 9], [6, 9],
      [10, 12], [11, 14],
    ];
  }

  static const _defaultFaceReadingLandmarks = [
    {'x': 0.28, 'y': 0.28},
    {'x': 0.38, 'y': 0.25},
    {'x': 0.62, 'y': 0.25},
    {'x': 0.72, 'y': 0.28},
    {'x': 0.32, 'y': 0.38},
    {'x': 0.40, 'y': 0.38},
    {'x': 0.60, 'y': 0.38},
    {'x': 0.68, 'y': 0.38},
    {'x': 0.50, 'y': 0.30},
    {'x': 0.50, 'y': 0.52},
    {'x': 0.44, 'y': 0.54},
    {'x': 0.56, 'y': 0.54},
    {'x': 0.38, 'y': 0.64},
    {'x': 0.50, 'y': 0.62},
    {'x': 0.62, 'y': 0.64},
    {'x': 0.50, 'y': 0.70},
    {'x': 0.24, 'y': 0.58},
    {'x': 0.50, 'y': 0.84},
    {'x': 0.76, 'y': 0.58},
    {'x': 0.22, 'y': 0.42},
    {'x': 0.78, 'y': 0.42},
  ];
}
