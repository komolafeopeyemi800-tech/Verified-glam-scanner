import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/vg_challenge_day.dart';

class VGChallengeTemplate {
  final String issueCode;
  final String issueLabel;
  final String challengeName;
  final int durationDays;
  final List<VGChallengeDay> days;

  const VGChallengeTemplate({
    required this.issueCode,
    required this.issueLabel,
    required this.challengeName,
    required this.durationDays,
    required this.days,
  });
}

class VGChallengeTemplates {
  static String _disclaimer = '';
  static Map<String, List<String>> _issueMap = {};
  static List<_ChallengeDef> _challenges = [];
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('lib/data/vg_viral_challenges_catalog.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _disclaimer = (json['disclaimer'] as String?) ?? '';
    _issueMap = (json['issueMap'] as Map<String, dynamic>? ?? const {}).map(
      (k, v) => MapEntry(
        k,
        v is List ? v.map((e) => e.toString()).toList() : const <String>[],
      ),
    );
    _challenges = ((json['challenges'] as List?) ?? const [])
        .map((e) => _ChallengeDef.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    _loaded = true;
  }

  static String get disclaimer => _disclaimer;

  static Future<VGChallengeTemplate> resolve({
    required String issueCode,
    required String issueLabel,
    required String severity,
  }) async {
    await ensureLoaded();
    final normalized = _normalizeIssueCode(issueCode);
    final duration = _routeDuration(issueCode: normalized, severity: severity);
    final picks = _issueMap[normalized] ?? _issueMap['acne'] ?? const [];

    final ranked = _challenges
        .where((c) => picks.contains(c.id))
        .toList()
      ..sort((a, b) => picks.indexOf(a.id).compareTo(picks.indexOf(b.id)));
    final chosen = ranked.isNotEmpty ? ranked.first : _challenges.first;
    final targetDuration = _nearestDuration(chosen.durations, duration);

    return VGChallengeTemplate(
      issueCode: normalized,
      issueLabel: issueLabel,
      challengeName: _challengeNameFor(issueCode: normalized, severity: severity, fallbackTitle: chosen.title),
      durationDays: targetDuration,
      days: _buildDays(chosen.steps, targetDuration),
    );
  }

  static int _nearestDuration(List<int> options, int target) {
    if (options.contains(target)) return target;
    final sorted = [...options]..sort((a, b) => (a - target).abs().compareTo((b - target).abs()));
    return sorted.first;
  }

  static List<VGChallengeDay> _buildDays(List<_StepDef> steps, int duration) {
    final out = <VGChallengeDay>[];
    for (var i = 0; i < duration; i++) {
      final step = steps[i % steps.length];
      out.add(
        VGChallengeDay(
          dayNumber: i + 1,
          title: step.title,
          mainTask: step.mainTask,
          supportTask: '${step.supportTask} Track your progress selfie today.',
          whyLine: step.whyLine,
          estMinutes: step.estMinutes,
        ),
      );
    }
    return out;
  }

  static String _normalizeIssueCode(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('acne') || v.contains('breakout') || v.contains('pimple')) return 'acne';
    if (v.contains('pigment') || v.contains('dark') || v.contains('spot')) return 'pigmentation';
    if (v.contains('texture') || v.contains('scar')) return 'texture';
    if (v.contains('aging') || v.contains('firm') || v.contains('sag')) return 'aging';
    if (v.contains('sensitive') || v.contains('redness')) return 'sensitivity';
    if (v.contains('oily') || v.contains('pore') || v.contains('sebum')) return 'oily';
    if (v.contains('dry') || v.contains('dehydrat')) return 'dryness';
    if (v.contains('uneven') || v.contains('tone') || v.contains('rosacea')) return 'uneven_tone';
    return 'acne';
  }

  static int _durationFromSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 7;
      case 'medium':
        return 5;
      default:
        return 3;
    }
  }

  static int _routeDuration({
    required String issueCode,
    required String severity,
  }) {
    final sev = severity.toLowerCase();
    if (issueCode == 'uneven_tone') return 7;
    if (issueCode == 'sensitivity') {
      return sev == 'high' ? 5 : 3;
    }
    return _durationFromSeverity(severity);
  }

  static String _challengeNameFor({
    required String issueCode,
    required String severity,
    required String fallbackTitle,
  }) {
    final sev = severity.toLowerCase();
    if (issueCode == 'acne') {
      if (sev == 'high') return 'Your 7-Day Acne Reset Challenge';
      if (sev == 'medium') return 'Your 5-Day Clear Skin Challenge';
      return 'Your 3-Day Skin Refresh';
    }
    if (issueCode == 'pigmentation') {
      if (sev == 'high') return 'Your 7-Day Brightening Challenge';
      return 'Your 5-Day Glow Challenge';
    }
    if (issueCode == 'texture') {
      if (sev == 'high') return 'Your 7-Day Skin Renewal Challenge';
      return 'Your 5-Day Smooth Skin Challenge';
    }
    if (issueCode == 'aging') {
      if (sev == 'high') return 'Your 7-Day Lift & Firm Challenge';
      return 'Your 5-Day Face Yoga Challenge';
    }
    if (issueCode == 'sensitivity') {
      if (sev == 'high') return 'Your 5-Day Calm Skin Challenge';
      return 'Your 3-Day Skin Reset';
    }
    if (issueCode == 'oily') {
      if (sev == 'high') return 'Your 7-Day Oil Control Challenge';
      return 'Your 5-Day Pore Minimising Challenge';
    }
    if (issueCode == 'dryness') {
      if (sev == 'high') return 'Your 7-Day Deep Hydration Challenge';
      return 'Your 5-Day Moisture Surge Challenge';
    }
    if (issueCode == 'uneven_tone') return 'Your 7-Day Even Tone Challenge';
    final d = _durationFromSeverity(severity);
    return 'Your $d-Day $fallbackTitle';
  }

}

class _ChallengeDef {
  final String id;
  final String title;
  final List<int> durations;
  final List<_StepDef> steps;

  _ChallengeDef({
    required this.id,
    required this.title,
    required this.durations,
    required this.steps,
  });

  factory _ChallengeDef.fromJson(Map<String, dynamic> json) {
    return _ChallengeDef(
      id: (json['id'] as String?) ?? 'challenge',
      title: (json['title'] as String?) ?? 'Skin Challenge',
      durations: ((json['durations'] as List?) ?? const [5]).map((e) => (e as num).toInt()).toList(),
      steps: ((json['steps'] as List?) ?? const [])
          .map((e) => _StepDef.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class _StepDef {
  final String title;
  final String mainTask;
  final String supportTask;
  final String whyLine;
  final int estMinutes;

  _StepDef({
    required this.title,
    required this.mainTask,
    required this.supportTask,
    required this.whyLine,
    required this.estMinutes,
  });

  factory _StepDef.fromJson(Map<String, dynamic> json) {
    return _StepDef(
      title: (json['title'] as String?) ?? 'Challenge Step',
      mainTask: (json['mainTask'] as String?) ?? '',
      supportTask: (json['supportTask'] as String?) ?? '',
      whyLine: (json['whyLine'] as String?) ?? '',
      estMinutes: (json['estMinutes'] as num?)?.toInt() ?? 8,
    );
  }
}
