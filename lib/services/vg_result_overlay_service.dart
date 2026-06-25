import '../utils/vg_payload_values.dart';

class VGResultOverlayService {
  VGResultOverlayService._();

  static List<Map<String, dynamic>> concernAnnotations(Map<String, dynamic> payload) {
    final detectedIssues = VGPayloadValues.asMapList(payload['detectedIssues']);
    if (detectedIssues.isNotEmpty) {
      return detectedIssues.take(5).toList().asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final anchors = VGPayloadValues.asMapList(item['anchors']);
        final anchor = anchors.isNotEmpty ? anchors.first : _anchorForIndex(idx);
        return {
          'text': item['label'] ?? item['issueId'] ?? 'Skin issue',
          'anchor': anchor,
          'labelSide': _sideForIndex(idx),
          'color': _colorForSeverity((item['severity'] ?? 'low').toString()),
        };
      }).toList();
    }

    final fromPayload = VGPayloadValues.asMapList(payload['annotations']);
    if (fromPayload.isNotEmpty) return fromPayload.take(5).toList();

    final findings = VGPayloadValues.asMapList(payload['findings']);
    if (findings.isNotEmpty) {
      return findings.take(5).toList().asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return {
          'text': item['shortLabel'] ?? item['categoryName'] ?? 'Skin concern',
          'anchor': _anchorFromCategory((item['categoryName'] ?? item['categoryId'] ?? '').toString(), idx),
          'labelSide': _sideForIndex(idx),
          'color': _colorForSeverity((item['severity'] ?? 'low').toString()),
        };
      }).toList();
    }

    final tags = VGPayloadValues.asStringList(payload['sharedTraits']);
    if (tags.isNotEmpty) {
      return tags.take(5).toList().asMap().entries.map((entry) {
        return {
          'text': entry.value,
          'anchor': _anchorForIndex(entry.key),
          'labelSide': _sideForIndex(entry.key),
          'color': 0xFFE07A9A,
        };
      }).toList();
    }

    return [];
  }

  static Map<String, double> _anchorFromCategory(String raw, int i) {
    final v = raw.toLowerCase();
    if (v.contains('eye')) return {'x': 0.52, 'y': 0.38};
    if (v.contains('forehead')) return {'x': 0.5, 'y': 0.22};
    if (v.contains('nose') || v.contains('pore')) return {'x': 0.5, 'y': 0.53};
    if (v.contains('jaw') || v.contains('chin')) return {'x': 0.56, 'y': 0.78};
    if (v.contains('cheek')) return {'x': 0.36, 'y': 0.56};
    return _anchorForIndex(i);
  }

  static Map<String, double> _anchorForIndex(int i) {
    switch (i % 5) {
      case 0:
        return {'x': 0.5, 'y': 0.24};
      case 1:
        return {'x': 0.34, 'y': 0.48};
      case 2:
        return {'x': 0.66, 'y': 0.5};
      case 3:
        return {'x': 0.44, 'y': 0.72};
      default:
        return {'x': 0.58, 'y': 0.76};
    }
  }

  static String _sideForIndex(int i) {
    switch (i % 4) {
      case 0:
        return 'left';
      case 1:
        return 'right';
      case 2:
        return 'top';
      default:
        return 'bottom';
    }
  }

  static int _colorForSeverity(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return 0xFFE45A74;
      case 'medium':
        return 0xFFD6788F;
      default:
        return 0xFFC892A1;
    }
  }
}
