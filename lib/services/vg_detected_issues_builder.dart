/// Builds ranked `detectedIssues` from beauty scan spots/findings (mirrors analyze-scan edge function).
class VGDetectedIssuesBuilder {
  VGDetectedIssuesBuilder._();

  static List<Map<String, dynamic>> fromPayload(Map<String, dynamic> payload) {
    final existing = (payload['detectedIssues'] as List?)?.cast<Map<String, dynamic>>();
    if (existing != null && existing.isNotEmpty) return existing.take(5).toList();

    final spots = (payload['spots'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final findings = (payload['findings'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    if (spots.isEmpty && findings.isEmpty) return const [];

    final byIssue = <String, _Agg>{};

    void push({
      required String rawId,
      String? categoryName,
      required String severity,
      double? confidence,
      Map<String, dynamic>? anchor,
    }) {
      final issueId = _canonicalIssueId('$rawId ${categoryName ?? ''}');
      final item = byIssue.putIfAbsent(
        issueId,
        () => _Agg(
          issueId: issueId,
          label: _issueLabel(issueId),
          severity: 'low',
        ),
      );
      if (_severityWeight(severity) > _severityWeight(item.severity)) {
        item.severity = severity;
      }
      if (confidence != null) {
        item.confidenceSum += confidence;
        item.confidenceCount += 1;
      }
      if (anchor != null && item.anchors.length < 5) {
        item.anchors.add(anchor);
      }
    }

    for (final spot in spots) {
      push(
        rawId: spot['categoryId']?.toString() ?? '',
        categoryName: spot['label']?.toString(),
        severity: (spot['severity'] as String? ?? 'low').toLowerCase(),
        confidence: (spot['confidence'] as num?)?.toDouble(),
        anchor: spot['anchor'] is Map ? Map<String, dynamic>.from(spot['anchor'] as Map) : null,
      );
    }
    for (final finding in findings) {
      push(
        rawId: finding['categoryId']?.toString() ?? '',
        categoryName: finding['categoryName']?.toString(),
        severity: (finding['severity'] as String? ?? 'low').toLowerCase(),
        confidence: 0.7,
        anchor: finding['anchor'] is Map ? Map<String, dynamic>.from(finding['anchor'] as Map) : null,
      );
    }

    final result = byIssue.values
        .map(
          (i) => {
            'issueId': i.issueId,
            'label': i.label,
            'severity': i.severity,
            'confidence': i.confidenceCount > 0 ? i.confidenceSum / i.confidenceCount : 0.7,
            'anchors': i.anchors,
          },
        )
        .toList();
    result.sort((a, b) {
      final sev = _severityWeight(b['severity'] as String) - _severityWeight(a['severity'] as String);
      if (sev != 0) return sev;
      return ((b['confidence'] as num?) ?? 0).compareTo((a['confidence'] as num?) ?? 0);
    });
    return result.take(5).toList();
  }

  static String _canonicalIssueId(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('acne') || v.contains('breakout') || v.contains('pimple')) return 'acne';
    if (v.contains('pigment') || v.contains('dark') || v.contains('spot')) return 'hyperpigmentation';
    if (v.contains('texture') || v.contains('scar')) return 'texture_scars';
    if (v.contains('aging') || v.contains('sag') || v.contains('firm')) return 'aging';
    if (v.contains('sensitive') || v.contains('redness')) return 'sensitivity';
    if (v.contains('oily') || v.contains('pore') || v.contains('sebum')) return 'oily_pores';
    if (v.contains('dry') || v.contains('dehydrat') || v.contains('flaky')) return 'dryness';
    if (v.contains('uneven') || v.contains('tone') || v.contains('rosacea')) return 'uneven_tone';
    return 'acne';
  }

  static String _issueLabel(String issueId) {
    switch (issueId) {
      case 'hyperpigmentation':
        return 'Hyperpigmentation & Dark Spots';
      case 'texture_scars':
        return 'Texture & Acne Scars';
      case 'aging':
        return 'Aging & Sagging Skin';
      case 'sensitivity':
        return 'Sensitivity & Redness';
      case 'oily_pores':
        return 'Oily Skin & Enlarged Pores';
      case 'dryness':
        return 'Dry & Dehydrated Skin';
      case 'uneven_tone':
        return 'Uneven Skin Tone & Rosacea';
      default:
        return 'Acne & Active Breakouts';
    }
  }

  static int _severityWeight(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }
}

class _Agg {
  final String issueId;
  final String label;
  String severity;
  double confidenceSum = 0;
  int confidenceCount = 0;
  final List<Map<String, dynamic>> anchors = [];

  _Agg({required this.issueId, required this.label, required this.severity});
}
