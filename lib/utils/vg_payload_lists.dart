import 'vg_payload_values.dart';

/// Safe list extraction from analysis payloads (avoids null cast crashes).
class VGPayloadLists {
  VGPayloadLists._();

  static List<Map<String, dynamic>> maps(Map<String, dynamic> payload, String key) {
    return VGPayloadValues.asMapList(payload[key]);
  }

  static List<String> strings(Map<String, dynamic> payload, String key) {
    return VGPayloadValues.asStringList(payload[key]);
  }

  static List<List<int>> intPairs(Map<String, dynamic> payload, String key) {
    final raw = payload[key];
    if (raw is! List) return const [];
    return raw
        .whereType<List>()
        .map((row) => row.map((e) => VGPayloadValues.asIntOr(e, 0)).toList())
        .toList();
  }
}
