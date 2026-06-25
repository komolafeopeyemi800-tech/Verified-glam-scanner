import 'dart:math' as math;

import '../data/vg_beauty_tips_catalog.dart';
import '../models/vg_feature_model.dart';
import '../services/vg_detected_issues_builder.dart';
import 'vg_constants.dart';
import 'vg_copy.dart';
import 'vg_mock_analysis.dart';

Map<String, dynamic> buildMockResultPayload(
  VGFeatureModel feature, {
  String? photoPath,
  List<Map<String, dynamic>>? detectedFaces,
}) {
  final s = VGMockAnalysisSeed(photoPath);
  switch (feature.featureType) {
    case VGFeatureTypes.faceBeautyAnalysis:
      return _faceBeautyPayload(s);
    case VGFeatureTypes.celebrityLookalike:
      return _celebrityLookalikePayload(s);
    case VGFeatureTypes.facialSymmetry:
      return _facialSymmetryPayload(s);
    case VGFeatureTypes.beautyScoreShowdown:
      return _showdownPayload(s);
    case VGFeatureTypes.facialResemblance:
      return _faceComparisonPayload(s, detectedFaces: detectedFaces);
    case VGFeatureTypes.faceReading:
      return _attractivenessPayload(s, detectedFaces: detectedFaces);
    case VGFeatureTypes.beautyTips:
      // Future: if (kVGBeautyTipsApiEnabled) return VGBeautyTipsApi.analyze(photoPath!, detectedFaces);
      return _beautyTipsPayload(s, detectedFaces: detectedFaces);
    case VGFeatureTypes.goldenRatio:
      return _goldenRatioPayload(s, detectedFaces: detectedFaces);
    case VGFeatureTypes.colorAnalysis:
      return {
        'season': s.unit(80) > 0.5 ? 'Soft Autumn' : 'Warm Spring',
        'skin': '#C4956A',
        'hair': '#3D2B1F',
        'eyes': '#5C6B4A',
        'samplePoint': {'x': 0.42, 'y': 0.55},
        'palette': ['Terracotta', 'Olive green', 'Warm taupe', 'Deep teal'],
        'paletteHex': ['#C67B5C', '#6B7A4A', '#9C8575', '#1E4D4A'],
        'avoid': ['Cool neon pink', 'Icy silver highlights'],
      };
    case VGFeatureTypes.glowUpGuide:
      return _glowUpChallengeScanPayload(s, detectedFaces: detectedFaces);
    case VGFeatureTypes.bestFacePart:
      return {'bestFeature': 'Eyes', 'reason': 'Symmetry, spacing, and brightness stand out most.'};
    default:
      return {'message': 'Analysis complete.'};
  }
}

List<Map<String, double>> _defaultLandmarks() {
  return [
    {'x': 0.35, 'y': 0.38},
    {'x': 0.65, 'y': 0.38},
    {'x': 0.50, 'y': 0.52},
    {'x': 0.50, 'y': 0.68},
    {'x': 0.50, 'y': 0.22},
    {'x': 0.50, 'y': 0.88},
  ];
}

Map<String, dynamic> _faceBeautyPayload(VGMockAnalysisSeed s) {
  final beautyScore = s.percent(1, min: 88, max: 96);
  final symmetry = s.percent(10, min: 90, max: 98);
  final featureBalance = s.percent(11, min: 88, max: 97);
  final skinQuality = s.percent(12, min: 86, max: 95);
  final youthfulCues = s.percent(13, min: 87, max: 96);
  final overallBeauty = s.percent(14, min: 88, max: 96);

  return {
    'beautyScore': beautyScore,
    'subscores': {
      'symmetry': symmetry,
      'featureBalance': featureBalance,
      'skinQuality': skinQuality,
      'youthfulCues': youthfulCues,
      'overallBeauty': overallBeauty,
    },
    'annotations': [
      {
        'text': 'Symmetry overall is very high',
        'anchor': {'x': 0.50, 'y': 0.20},
        'labelSide': 'top',
      },
      {
        'text': 'Balanced eye and lip placement',
        'anchor': {'x': 0.62, 'y': 0.40},
        'labelSide': 'right',
      },
      {
        'text': 'Skin clarity and natural tone evenness',
        'anchor': {'x': 0.35, 'y': 0.52},
        'labelSide': 'left',
      },
      {
        'text': 'Good nasal proportions',
        'anchor': {'x': 0.55, 'y': 0.50},
        'labelSide': 'right',
      },
      {
        'text': 'Soft youthful contours enhance beauty impression',
        'anchor': {'x': 0.50, 'y': 0.72},
        'labelSide': 'bottom',
      },
      {
        'text': 'Visual regularity feels well-matched',
        'anchor': {'x': 0.32, 'y': 0.68},
        'labelSide': 'left',
      },
    ],
    'guides': {
      'verticalCenter': 0.5,
      'eyeLineY': 0.38,
      'lipLineY': 0.62,
      'browCurve': [
        {'x': 0.28, 'y': 0.30},
        {'x': 0.38, 'y': 0.26},
        {'x': 0.50, 'y': 0.25},
        {'x': 0.62, 'y': 0.26},
        {'x': 0.72, 'y': 0.30},
      ],
      'noseBridge': [
        {'x': 0.50, 'y': 0.28},
        {'x': 0.50, 'y': 0.42},
        {'x': 0.50, 'y': 0.55},
      ],
      'jawCurve': [
        {'x': 0.22, 'y': 0.58},
        {'x': 0.32, 'y': 0.78},
        {'x': 0.50, 'y': 0.86},
        {'x': 0.68, 'y': 0.78},
        {'x': 0.78, 'y': 0.58},
      ],
    },
    'landmarks': _defaultLandmarks(),
    'scoresFinalized': true,
    'ratingLabel': VGCopy.beautyHarmonyTierFor(beautyScore),
  };
}

/// Maps a raw deviation to a 0–100 symmetry score (0 deviation = 100).
int _scoreFromDeviation(double deviation, double maxDeviation) {
  final ratio = (deviation.abs() / maxDeviation).clamp(0.0, 1.0);
  return (100 - ratio * 28).round().clamp(72, 98);
}

/// Maps facial-third percentages toward ideal 33.3% each.
int _scoreFromThirds(Map<String, double> thirds) {
  const ideal = 33.3;
  final avgDev = ((thirds['upper']! - ideal).abs() +
          (thirds['middle']! - ideal).abs() +
          (thirds['lower']! - ideal).abs()) /
      3;
  return _scoreFromDeviation(avgDev, 12);
}

Map<String, dynamic> _facialSymmetryPayload(VGMockAnalysisSeed s) {
  // Raw measurements — mirrors future API response shape.
  final chinOffsetPx = double.parse(s.range(-22, -12, 30).toStringAsFixed(1));
  final jawAngleL = double.parse(s.range(-150, -140, 31).toStringAsFixed(1));
  final jawAngleR = double.parse(s.range(-148, -138, 32).toStringAsFixed(1));
  final jawLengthDiffPx = double.parse(s.range(18, 32, 33).toStringAsFixed(1));

  final eyeVerticalOffsetPx = double.parse(s.range(10, 20, 34).toStringAsFixed(1));
  final eyeWidthRatio = double.parse(s.range(1.05, 1.12, 35).toStringAsFixed(3));
  final eyeHeightRatio = double.parse(s.range(1.03, 1.10, 36).toStringAsFixed(3));

  final upperThird = double.parse(s.range(17, 22, 37).toStringAsFixed(1));
  final middleThird = double.parse(s.range(38, 44, 38).toStringAsFixed(1));
  final lowerThird = double.parse((100 - upperThird - middleThird).toStringAsFixed(1));

  final hwRatio = double.parse(s.range(1.18, 1.28, 39).toStringAsFixed(3));
  const goldenIdeal = 1.618;
  final goldenDeviation = double.parse((hwRatio - goldenIdeal).toStringAsFixed(3));

  final mouthTiltPx = double.parse(s.range(-14, -8, 40).toStringAsFixed(1));
  final mouthCornerL = double.parse(s.range(45, 55, 41).toStringAsFixed(1));
  final mouthCornerR = double.parse(s.range(32, 42, 42).toStringAsFixed(1));
  final mouthPeakDiffPx = double.parse(s.range(-5, -1, 43).toStringAsFixed(1));

  final noseTipOffsetPx = double.parse(s.range(14, 22, 44).toStringAsFixed(1));
  final noseAngleDeg = double.parse(s.range(-6, -3, 45).toStringAsFixed(1));
  final nostrilL = double.parse(s.range(2, 6, 46).toStringAsFixed(1));
  final nostrilR = double.parse(s.range(18, 26, 47).toStringAsFixed(1));

  final measurements = {
    'jawChin': {
      'chinOffsetPx': chinOffsetPx,
      'jawAngles': [jawAngleL, jawAngleR],
      'jawLengthDiffPx': jawLengthDiffPx,
    },
    'eyes': {
      'verticalOffsetPx': eyeVerticalOffsetPx,
      'widthRatio': eyeWidthRatio,
      'heightRatio': eyeHeightRatio,
    },
    'facialThirds': {
      'upper': upperThird,
      'middle': middleThird,
      'lower': lowerThird,
    },
    'goldenRatio': {
      'hwRatio': hwRatio,
      'deviation': goldenDeviation,
    },
    'mouth': {
      'tiltPx': mouthTiltPx,
      'cornerOffsetsPx': [mouthCornerL, mouthCornerR],
      'peakHeightDiffPx': mouthPeakDiffPx,
    },
    'nose': {
      'tipOffsetPx': noseTipOffsetPx,
      'angleDeg': noseAngleDeg,
      'nostrilOffsetsPx': [nostrilL, nostrilR],
    },
  };

  // Derive region scores from measurement deviations (local mock math).
  final eyesScore = _scoreFromDeviation(eyeVerticalOffsetPx, 25);
  final noseScore = _scoreFromDeviation(noseTipOffsetPx, 25);
  final mouthScore = _scoreFromDeviation(mouthTiltPx.abs() + mouthPeakDiffPx.abs(), 20);
  final cheeksScore = _scoreFromDeviation(jawLengthDiffPx, 35);

  final faceShapeScore = _scoreFromThirds({
    'upper': upperThird,
    'middle': middleThird,
    'lower': lowerThird,
  });
  final goldenScore = _scoreFromDeviation(goldenDeviation, 0.5);

  final regionScores = [eyesScore, noseScore, mouthScore, cheeksScore];
  final overallSymmetryScore = double.parse(
    (regionScores.reduce((a, b) => a + b) / regionScores.length).toStringAsFixed(1),
  );
  final overallPercent = overallSymmetryScore.round();

  final beauty = s.percent(48, min: 88, max: 96);
  final cuteness = s.percent(49, min: 72, max: 82);
  final skinSmoothness = s.percent(50, min: 86, max: 94);
  final handsomeness = s.percent(51, min: 74, max: 84);
  final facialSymmetry = overallPercent;

  return {
    'overallSymmetryScore': overallSymmetryScore,
    'overallPercent': overallPercent,
    'tierLabel': VGCopy.symmetryTierFor(overallPercent),
    'scoresFinalized': true,
    'note': 'Left-right balance is strong with subtle natural asymmetry.',
    'guides': {
      'verticalCenter': 0.5,
      'verticalSideLines': [0.35, 0.65],
      'horizontalLines': [0.18, 0.28, 0.38, 0.52, 0.64, 0.78, 0.88],
    },
    'regions': [
      {
        'id': 'eyes',
        'label': 'Eyes symmetry',
        'percent': eyesScore,
        'color': 0xFF5B8DEF,
        'icon': 'star',
        'anchor': {'x': 0.32, 'y': 0.38},
        'labelSide': 'left',
        'outlinePoints': [
          [0.26, 0.34],
          [0.38, 0.32],
          [0.42, 0.40],
          [0.30, 0.42],
          [0.58, 0.32],
          [0.70, 0.34],
          [0.74, 0.42],
          [0.62, 0.40],
        ],
      },
      {
        'id': 'nose',
        'label': 'Nose symmetry',
        'percent': noseScore,
        'color': 0xFF4CAF7A,
        'icon': 'check',
        'anchor': {'x': 0.52, 'y': 0.50},
        'labelSide': 'right',
        'outlinePoints': [
          [0.44, 0.42],
          [0.56, 0.42],
          [0.54, 0.58],
          [0.46, 0.58],
        ],
      },
      {
        'id': 'mouth',
        'label': 'Mouth symmetry',
        'percent': mouthScore,
        'color': 0xFFE07A9A,
        'icon': 'heart',
        'anchor': {'x': 0.34, 'y': 0.66},
        'labelSide': 'left',
        'outlinePoints': [
          [0.36, 0.60],
          [0.64, 0.60],
          [0.60, 0.70],
          [0.40, 0.70],
        ],
      },
      {
        'id': 'cheeks',
        'label': 'Cheeks symmetry',
        'percent': cheeksScore,
        'color': 0xFFE8A04C,
        'icon': 'circle',
        'anchor': {'x': 0.68, 'y': 0.52},
        'labelSide': 'right',
        'outlinePolygons': [
          [
            [0.18, 0.48],
            [0.30, 0.44],
            [0.32, 0.58],
            [0.22, 0.60],
          ],
          [
            [0.70, 0.44],
            [0.82, 0.48],
            [0.78, 0.60],
            [0.68, 0.58],
          ],
        ],
      },
    ],
    'measurements': measurements,
    'subscores': {
      'beauty': beauty,
      'cuteness': cuteness,
      'skinSmoothness': skinSmoothness,
      'handsomeness': handsomeness,
      'faceShape': faceShapeScore,
      'facialSymmetry': facialSymmetry,
      'goldenRatio': goldenScore,
    },
    // Reserved for future threshold-gated tips UI.
    'exercises': ['Smile & hold', 'Cheek puffs', 'Eye yoga', 'Lip purses'],
  };
}

/// Normalized face landmarks for celebrity mesh overlay replay on result hero.
List<Map<String, double>> _celebrityFaceLandmarks() {
  return [
    {'x': 0.28, 'y': 0.28}, // 0 left brow outer
    {'x': 0.38, 'y': 0.25}, // 1 left brow inner
    {'x': 0.62, 'y': 0.25}, // 2 right brow inner
    {'x': 0.72, 'y': 0.28}, // 3 right brow outer
    {'x': 0.32, 'y': 0.38}, // 4 left eye outer
    {'x': 0.40, 'y': 0.38}, // 5 left eye inner
    {'x': 0.60, 'y': 0.38}, // 6 right eye inner
    {'x': 0.68, 'y': 0.38}, // 7 right eye outer
    {'x': 0.50, 'y': 0.30}, // 8 nose bridge top
    {'x': 0.50, 'y': 0.52}, // 9 nose tip
    {'x': 0.44, 'y': 0.54}, // 10 nostril left
    {'x': 0.56, 'y': 0.54}, // 11 nostril right
    {'x': 0.38, 'y': 0.64}, // 12 mouth left
    {'x': 0.50, 'y': 0.62}, // 13 mouth top
    {'x': 0.62, 'y': 0.64}, // 14 mouth right
    {'x': 0.50, 'y': 0.70}, // 15 mouth bottom
    {'x': 0.24, 'y': 0.58}, // 16 jaw left
    {'x': 0.50, 'y': 0.84}, // 17 chin
    {'x': 0.76, 'y': 0.58}, // 18 jaw right
    {'x': 0.22, 'y': 0.42}, // 19 temple left
    {'x': 0.78, 'y': 0.42}, // 20 temple right
  ];
}

List<List<int>> _celebrityMeshConnections() {
  return [
    [0, 1], [1, 2], [2, 3], // brows
    [4, 5], [6, 7], [5, 6], // eyes
    [8, 9], [9, 10], [9, 11], [10, 11], // nose
    [12, 13], [13, 14], [14, 15], [12, 15], // lips
    [16, 17], [17, 18], [19, 16], [20, 18], // jaw
    [1, 8], [2, 8], // brow to nose
    [5, 9], [6, 9], // eyes to nose
    [10, 12], [11, 14], // nose to mouth
  ];
}

Map<String, dynamic> _celebrityLookalikePayload(VGMockAnalysisSeed s) {
  final isFemale = s.unit(19) >= 0.5;
  final gender = isFemale ? 'female' : 'male';

  final femaleMatches = [
    {
      'name': 'Margot Robbie',
      'percent': s.percent(20, min: 88, max: 95),
      'traits': ['Similar eye shape', 'High cheekbones', 'Full lip shape'],
      'why': 'Similar eye shape, high cheekbones, and full lip shape.',
      'imageAsset': 'images/vg/mock/celebrities/female_01.png',
    },
    {
      'name': 'Gigi Hadid',
      'percent': s.percent(21, min: 82, max: 91),
      'traits': ['Freckles', 'Nose structure', 'Jawline definition'],
      'why': 'Shared freckles, nose structure, and jawline definition.',
      'imageAsset': 'images/vg/mock/celebrities/female_02.png',
    },
    {
      'name': 'Elsa Hosk',
      'percent': s.percent(22, min: 78, max: 88),
      'traits': ['Hair colour', 'Eye colour', 'Overall face shape'],
      'why': 'Comparable hair colour, eye colour, and overall face shape.',
      'imageAsset': 'images/vg/mock/celebrities/female_03.png',
    },
  ];

  final maleMatches = [
    {
      'name': 'Michael B. Jordan',
      'percent': s.percent(23, min: 85, max: 94),
      'traits': ['Jaw contour', 'Eye spacing', 'Brow shape'],
      'why': 'Shared jaw contour, eye spacing, and brow shape.',
      'imageAsset': 'images/vg/mock/celebrities/male_01.png',
    },
    {
      'name': 'Timothée Chalamet',
      'percent': s.percent(24, min: 80, max: 90),
      'traits': ['Cheekbone height', 'Nose bridge', 'Lip line'],
      'why': 'Similar cheekbone height, nose bridge, and lip line.',
      'imageAsset': 'images/vg/mock/celebrities/male_02.png',
    },
    {
      'name': 'Dev Patel',
      'percent': s.percent(25, min: 74, max: 86),
      'traits': ['Face length', 'Smile structure', 'Eye shape'],
      'why': 'Comparable face length, smile structure, and eye shape.',
      'imageAsset': 'images/vg/mock/celebrities/male_03.png',
    },
  ];

  return {
    'detectedGender': gender,
    'landmarks': _celebrityFaceLandmarks(),
    'meshConnections': _celebrityMeshConnections(),
    'matches': isFemale ? femaleMatches : maleMatches,
    'scoresFinalized': true,
  };
}

List<Map<String, dynamic>> _mockTwoFaceContours() {
  return [
    {
      'id': 'face1',
      'label': 'Face 1',
      'color': 0xFFE07A9A,
      'contourPoints': _ovalPointsNormalized(0.32, 0.48, 0.14, 0.20),
      'center': {'x': 0.32, 'y': 0.28},
    },
    {
      'id': 'face2',
      'label': 'Face 2',
      'color': 0xFF5B8DEF,
      'contourPoints': _ovalPointsNormalized(0.68, 0.48, 0.14, 0.20),
      'center': {'x': 0.68, 'y': 0.28},
    },
  ];
}

List<List<double>> _ovalPointsNormalized(double cx, double cy, double rx, double ry, {int segments = 24}) {
  return List.generate(segments, (i) {
    final t = (i / segments) * 2 * math.pi;
    return [cx + rx * math.cos(t), cy + ry * math.sin(t)];
  });
}

Map<String, dynamic> _faceComparisonPayload(
  VGMockAnalysisSeed s, {
  List<Map<String, dynamic>>? detectedFaces,
}) {
  final similarity = s.percent(50, min: 72, max: 92);
  const hints = ['sibling', 'couple', 'friend'];
  final relationshipHint = hints[(s.unit(51) * hints.length).floor().clamp(0, hints.length - 1)];
  final scoreLabel = VGCopy.scoreLabelForRelationship(relationshipHint);

  var faces = detectedFaces;
  if (faces == null || faces.length < 2) {
    faces = _mockTwoFaceContours();
  } else {
    faces = faces.take(2).toList();
  }

  final contourComparison =
      'Contour Comparison: Both faces have a similar oval shape with defined cheekbones and rounded jawlines. '
      'The chin structures are well aligned. Minor differences appear in hairline width and cheek fullness.';

  final explanation =
      'The score reflects how closely the outer face contours, jawline angles, and chin shapes align — '
      'indicating ${relationshipHint == 'couple' ? 'a strong' : 'notable'} visual resemblance.';

  return {
    'similarity': similarity,
    'scoreLabel': scoreLabel,
    'relationshipHint': relationshipHint,
    'faces': faces,
    'contourComparison': contourComparison,
    'explanation': explanation,
    'sharedTraits': [
      'Similar oval face shape',
      'Aligned jawline contour',
      'Comparable cheekbone height',
    ],
    'note': explanation,
  };
}

Map<String, dynamic> _defaultFaceBox() {
  return {'x': 0.21, 'y': 0.18, 'width': 0.58, 'height': 0.48};
}

Map<String, dynamic> _faceBoxFromDetectedFaces(List<Map<String, dynamic>>? detectedFaces) {
  if (detectedFaces == null || detectedFaces.isEmpty) return _defaultFaceBox();

  final points = (detectedFaces.first['contourPoints'] as List?)?.cast<List>();
  if (points == null || points.isEmpty) return _defaultFaceBox();

  var minX = 1.0;
  var minY = 1.0;
  var maxX = 0.0;
  var maxY = 0.0;
  for (final p in points) {
    if (p.length < 2) continue;
    final x = (p[0] as num).toDouble();
    final y = (p[1] as num).toDouble();
    minX = math.min(minX, x);
    minY = math.min(minY, y);
    maxX = math.max(maxX, x);
    maxY = math.max(maxY, y);
  }

  const padX = 0.06;
  const padY = 0.08;
  final x = (minX - padX).clamp(0.0, 0.9);
  final y = (minY - padY).clamp(0.0, 0.9);
  final width = (maxX - minX + padX * 2).clamp(0.2, 1.0 - x);
  final height = (maxY - minY + padY * 2).clamp(0.2, 1.0 - y);

  return {'x': x, 'y': y, 'width': width, 'height': height};
}

Map<String, dynamic> _attractivenessPayload(
  VGMockAnalysisSeed s, {
  List<Map<String, dynamic>>? detectedFaces,
}) {
  final overallScore = double.parse(s.range(7.8, 9.2, 60).toStringAsFixed(2));
  final overallPercent = (overallScore * 10).round();
  final tierLabel = VGCopy.attractivenessTierFor(overallScore);
  final facialAge = (19 + s.unit(61) * 13).round();

  final appearanceScores = {
    'beauty': s.percent(62, min: 86, max: 97),
    'handsomeness': s.percent(63, min: 72, max: 88),
    'cuteness': s.percent(64, min: 74, max: 92),
    'faceShape': s.percent(65, min: 82, max: 96),
    'facialSymmetry': s.percent(66, min: 84, max: 97),
    'skinSmoothness': s.percent(67, min: 86, max: 98),
  };

  final traitScores = {
    'funFactor': s.percent(68, min: 58, max: 88),
    'intelligence': s.percent(69, min: 72, max: 94),
    'confidence': s.percent(70, min: 65, max: 92),
    'credibility': s.percent(71, min: 60, max: 90),
  };

  return {
    'overallScore': overallScore,
    'overallPercent': overallPercent,
    'tierLabel': tierLabel,
    'subtitle': VGCopy.attractivenessSubtitle,
    'facialAge': facialAge,
    'appearanceScores': appearanceScores,
    'traitScores': traitScores,
    'faceBox': _faceBoxFromDetectedFaces(detectedFaces),
    'landmarks': _celebrityFaceLandmarks(),
    'meshConnections': _celebrityMeshConnections(),
    'note': 'Your features show strong harmony with balanced proportions across every dimension we measured.',
    'scoresFinalized': true,
  };
}

const _beautyTipsMaxSpots = 16;
const _beautyTipsMinSpotDistance = 0.06;

int _beautyTipsSeverityRank(String severity) {
  switch (severity) {
    case 'high':
      return 3;
    case 'low':
      return 1;
    default:
      return 2;
  }
}

bool _beautyTipsAnchorTooClose(
  double x,
  double y,
  List<Map<String, dynamic>> spots,
  double minDist,
) {
  for (final spot in spots) {
    final anchor = spot['anchor'] as Map<String, dynamic>? ?? {};
    final ax = (anchor['x'] as num?)?.toDouble() ?? 0.5;
    final ay = (anchor['y'] as num?)?.toDouble() ?? 0.5;
    final dx = x - ax;
    final dy = y - ay;
    if (math.sqrt(dx * dx + dy * dy) < minDist) return true;
  }
  return false;
}

String _beautyTipsLabelSideForSpot({
  required double ax,
  required double cx,
  required String? zonePreferredSide,
}) {
  if (zonePreferredSide != null &&
      (zonePreferredSide == 'top' || zonePreferredSide == 'bottom')) {
    return zonePreferredSide;
  }
  return ax < cx ? 'left' : 'right';
}

List<Map<String, dynamic>> _beautyTipsSpotsFromFace(
  VGMockAnalysisSeed s,
  Map<String, dynamic> faceBox,
) {
  final cx = (faceBox['x'] as num).toDouble() + (faceBox['width'] as num).toDouble() / 2;
  final cy = (faceBox['y'] as num).toDouble() + (faceBox['height'] as num).toDouble() / 2;
  final hw = (faceBox['width'] as num).toDouble() / 2;
  final hh = (faceBox['height'] as num).toDouble() / 2;
  final severities = ['high', 'medium', 'low'];
  final zones = VGBeautyTipsCatalog.faceZones;
  final categories = VGBeautyTipsCatalog.categoryIds;

  final spotCount = (8 + (s.unit(50) * 6).round()).clamp(8, _beautyTipsMaxSpots);
  final spots = <Map<String, dynamic>>[];

  for (var i = 0; i < spotCount; i++) {
    var placed = false;
    for (var tryN = 0; tryN < 14 && !placed; tryN++) {
      final zone = zones[(s.unit(70 + i * 3 + tryN) * zones.length).floor() % zones.length];
      final jitterX = (s.unit(80 + i + tryN) - 0.5) * 0.14;
      final jitterY = (s.unit(90 + i + tryN) - 0.5) * 0.14;
      final ax = (cx + zone.dx * hw * 1.08 + jitterX * hw).clamp(0.10, 0.90);
      final ay = (cy + zone.dy * hh * 1.08 + jitterY * hh).clamp(0.12, 0.88);

      if (_beautyTipsAnchorTooClose(ax, ay, spots, _beautyTipsMinSpotDistance)) continue;

      final categoryId =
          categories[(s.unit(100 + i + tryN) * categories.length).floor() % categories.length];
      final cat = VGBeautyTipsCatalog.categoryById(categoryId)!;
      final severity = severities[(s.unit(110 + i) * 3).floor() % 3];
      final label = VGBeautyTipsCatalog.spotLabelFor(categoryId, i + tryN);
      final labelSide = _beautyTipsLabelSideForSpot(
        ax: ax,
        cx: cx,
        zonePreferredSide: zone.preferredSide,
      );

      spots.add({
        'id': 'spot_${spots.length + 1}',
        'categoryId': categoryId,
        'label': label,
        'anchor': {'x': ax, 'y': ay},
        'severity': severity,
        'confidence': 0.72 + s.unit(120 + i) * 0.26,
        'labelSide': labelSide,
        'color': cat.color,
      });
      placed = true;
    }
  }
  return spots;
}

List<Map<String, dynamic>> _beautyTipsFindingsFromSpots(List<Map<String, dynamic>> spots) {
  final grouped = <String, Map<String, dynamic>>{};

  for (final spot in spots) {
    final categoryId = spot['categoryId'] as String;
    final cat = VGBeautyTipsCatalog.categoryById(categoryId);
    if (cat == null) continue;

    final severity = spot['severity'] as String? ?? 'medium';
    final existing = grouped[categoryId];
    if (existing == null) {
      grouped[categoryId] = {
        'categoryId': categoryId,
        'categoryName': cat.name,
        'severity': severity,
        'shortLabel': cat.shortLabel,
        'spotCount': 1,
        'anchor': spot['anchor'],
        'labelSide': cat.labelSide,
        'color': cat.color,
      };
    } else {
      existing['spotCount'] = (existing['spotCount'] as int) + 1;
      if (_beautyTipsSeverityRank(severity) >
          _beautyTipsSeverityRank(existing['severity'] as String)) {
        existing['severity'] = severity;
      }
    }
  }

  return grouped.values.toList();
}

List<Map<String, dynamic>> _beautyTipsAnnotationsFromSpots(List<Map<String, dynamic>> spots) {
  return spots
      .map(
        (spot) => {
          'text': spot['label'],
          'anchor': spot['anchor'],
          'labelSide': spot['labelSide'],
          'color': spot['color'],
          'spotId': spot['id'],
        },
      )
      .toList();
}

Map<String, dynamic> _beautyTipsPayload(
  VGMockAnalysisSeed s, {
  List<Map<String, dynamic>>? detectedFaces,
}) {
  final faceBox = _faceBoxFromDetectedFaces(detectedFaces);
  final spots = _beautyTipsSpotsFromFace(s, faceBox);
  final findings = _beautyTipsFindingsFromSpots(spots);
  final annotations = _beautyTipsAnnotationsFromSpots(spots);

  final tips = <Map<String, dynamic>>[];
  for (final finding in findings) {
    final categoryId = finding['categoryId'] as String;
    final severity = finding['severity'] as String;
    final entries = VGBeautyTipsCatalog.tipsFor(categoryId, severity);
    for (final entry in entries) {
      tips.add({
        'priority': severity,
        'categoryId': categoryId,
        'title': entry.title,
        'body': entry.body,
        'disclaimer': VGCopy.beautyTipsTipDisclaimer,
      });
    }
  }

  final sampleLabels = spots.map((sp) => sp['label']?.toString() ?? '').where((l) => l.isNotEmpty).toSet().toList();

  final payload = {
    'spots': spots,
    'findings': findings,
    'annotations': annotations,
    'tips': tips,
    'summary': VGCopy.beautyTipsSummary(spots.length, sampleLabels),
    'globalDisclaimer': VGCopy.beautyTipsGlobalDisclaimer,
  };
  payload['detectedIssues'] = VGDetectedIssuesBuilder.fromPayload(payload);
  return payload;
}

Map<String, dynamic> _glowUpChallengeScanPayload(
  VGMockAnalysisSeed s, {
  List<Map<String, dynamic>>? detectedFaces,
}) {
  final base = _beautyTipsPayload(s, detectedFaces: detectedFaces);
  base.remove('tips');
  base['summary'] = VGCopy.challengeScanSummary(
    (base['detectedIssues'] as List?)?.length ?? 0,
  );
  return base;
}

Map<String, dynamic> _goldenRatioPayload(
  VGMockAnalysisSeed s, {
  List<Map<String, dynamic>>? detectedFaces,
}) {
  const idealPhi = 1.618;
  final landmarks = _goldenRatioLandmarks(detectedFaces);

  final measurements = [
    _goldenMeasurement(
      id: 'faceLengthWidth',
      name: 'Face Length : Face Width',
      ratio: s.range(1.595, 1.645, 72),
      ideal: idealPhi,
      lineType: 'verticalBracket',
      from: landmarks['hairline']!,
      to: landmarks['chin']!,
      calloutAnchor: {'x': 0.10, 'y': 0.42},
      labelSide: 'left',
    ),
    _goldenMeasurement(
      id: 'eyeDistanceFaceWidth',
      name: 'Eye Distance : Face Width',
      ratio: s.range(0.248, 0.278, 73),
      ideal: 0.262,
      lineType: 'horizontal',
      from: landmarks['eyeInnerL']!,
      to: landmarks['eyeInnerR']!,
      calloutAnchor: {'x': 0.88, 'y': 0.32},
      labelSide: 'right',
    ),
    _goldenMeasurement(
      id: 'noseWidthFaceWidth',
      name: 'Nose Width : Face Width',
      ratio: s.range(0.285, 0.335, 74),
      ideal: 0.268,
      lineType: 'horizontal',
      from: landmarks['noseWingL']!,
      to: landmarks['noseWingR']!,
      calloutAnchor: {'x': 0.12, 'y': 0.58},
      labelSide: 'left',
      highlightBracket: true,
    ),
    _goldenMeasurement(
      id: 'mouthWidthNoseWidth',
      name: 'Mouth Width : Nose Width',
      ratio: s.range(1.548, 1.598, 75),
      ideal: idealPhi,
      lineType: 'horizontal',
      from: landmarks['mouthCornerL']!,
      to: landmarks['mouthCornerR']!,
      calloutAnchor: {'x': 0.88, 'y': 0.66},
      labelSide: 'right',
    ),
    _goldenMeasurement(
      id: 'eyeWidthEyeDistance',
      name: 'Eye Width : Eye Distance',
      ratio: s.range(0.880, 0.940, 76),
      ideal: 0.962,
      lineType: 'horizontal',
      from: landmarks['eyeOuterL']!,
      to: landmarks['eyeInnerL']!,
      calloutAnchor: {'x': 0.12, 'y': 0.34},
      labelSide: 'left',
    ),
    _goldenMeasurement(
      id: 'philtrumNose',
      name: 'Philtrum : Nose Length',
      ratio: s.range(1.660, 1.720, 77),
      ideal: idealPhi,
      lineType: 'vertical',
      from: landmarks['philtrum']!,
      to: landmarks['noseBridge']!,
      calloutAnchor: {'x': 0.88, 'y': 0.48},
      labelSide: 'right',
      highlightBracket: true,
    ),
  ];

  final scoreSum = measurements.fold<int>(
    0,
    (sum, m) => sum + ((m['scoreOutOf20'] as num?)?.round() ?? 0),
  );
  final goldenRatioIndex = ((scoreSum / measurements.length) * 5).round().clamp(0, 100);
  final overallScore = double.parse((goldenRatioIndex / 10).toStringAsFixed(1));
  final ratingLabel = VGCopy.goldenRatioRatingFor(goldenRatioIndex);

  final deviations = measurements
      .where((m) => m['pass'] != true)
      .map((m) => _goldenDeviationLabel(m['id'] as String))
      .toList();

  return {
    'idealPhi': idealPhi,
    'overallScore': overallScore,
    'goldenRatioIndex': goldenRatioIndex,
    'harmonyPercent': goldenRatioIndex,
    'ratingLabel': ratingLabel,
    'landmarks': landmarks,
    'measurements': measurements,
    'deviations': deviations,
    'note':
        'Your proportions show strong alignment with classical golden-ratio ideals, with a few areas to refine.',
  };
}

Map<String, Map<String, double>> _goldenRatioLandmarks(
  List<Map<String, dynamic>>? detectedFaces,
) {
  var landmarks = {
    'hairline': {'x': 0.50, 'y': 0.18},
    'chin': {'x': 0.50, 'y': 0.88},
    'faceWidthLeft': {'x': 0.22, 'y': 0.48},
    'faceWidthRight': {'x': 0.78, 'y': 0.48},
    'eyeInnerL': {'x': 0.40, 'y': 0.38},
    'eyeOuterL': {'x': 0.32, 'y': 0.38},
    'eyeInnerR': {'x': 0.60, 'y': 0.38},
    'eyeOuterR': {'x': 0.68, 'y': 0.38},
    'noseBridge': {'x': 0.50, 'y': 0.30},
    'noseWingL': {'x': 0.44, 'y': 0.54},
    'noseWingR': {'x': 0.56, 'y': 0.54},
    'mouthCornerL': {'x': 0.38, 'y': 0.64},
    'mouthCornerR': {'x': 0.62, 'y': 0.64},
    'philtrum': {'x': 0.50, 'y': 0.58},
  };

  final box = _faceBoxFromDetectedFaces(detectedFaces);
  final cx = (box['x'] as num).toDouble() + (box['width'] as num).toDouble() / 2;
  final cy = (box['y'] as num).toDouble() + (box['height'] as num).toDouble() / 2;
  final hw = (box['width'] as num).toDouble() / 2;
  final hh = (box['height'] as num).toDouble() / 2;

  if (detectedFaces != null && detectedFaces.isNotEmpty) {
    landmarks = {
      'hairline': {'x': cx, 'y': (box['y'] as num).toDouble() + hh * 0.08},
      'chin': {'x': cx, 'y': (box['y'] as num).toDouble() + hh * 1.92},
      'faceWidthLeft': {'x': cx - hw * 0.92, 'y': cy},
      'faceWidthRight': {'x': cx + hw * 0.92, 'y': cy},
      'eyeInnerL': {'x': cx - hw * 0.18, 'y': cy - hh * 0.22},
      'eyeOuterL': {'x': cx - hw * 0.38, 'y': cy - hh * 0.22},
      'eyeInnerR': {'x': cx + hw * 0.18, 'y': cy - hh * 0.22},
      'eyeOuterR': {'x': cx + hw * 0.38, 'y': cy - hh * 0.22},
      'noseBridge': {'x': cx, 'y': cy - hh * 0.12},
      'noseWingL': {'x': cx - hw * 0.14, 'y': cy + hh * 0.08},
      'noseWingR': {'x': cx + hw * 0.14, 'y': cy + hh * 0.08},
      'mouthCornerL': {'x': cx - hw * 0.28, 'y': cy + hh * 0.32},
      'mouthCornerR': {'x': cx + hw * 0.28, 'y': cy + hh * 0.32},
      'philtrum': {'x': cx, 'y': cy + hh * 0.18},
    };
  }

  return landmarks;
}

Map<String, dynamic> _goldenMeasurement({
  required String id,
  required String name,
  required double ratio,
  required double ideal,
  required String lineType,
  required Map<String, double> from,
  required Map<String, double> to,
  required Map<String, double> calloutAnchor,
  required String labelSide,
  bool highlightBracket = false,
}) {
  final delta = double.parse((ratio - ideal).toStringAsFixed(3));
  final absDelta = delta.abs();
  final scoreOutOf20 = _goldenScoreOutOf20(absDelta);
  final pass = absDelta <= 0.055;

  return {
    'id': id,
    'name': name,
    'ratio': double.parse(ratio.toStringAsFixed(3)),
    'ideal': ideal,
    'delta': delta,
    'scoreOutOf20': scoreOutOf20,
    'pass': pass,
    'lineType': lineType,
    'from': from,
    'to': to,
    'calloutAnchor': calloutAnchor,
    'labelSide': labelSide,
    'highlightBracket': highlightBracket || !pass,
  };
}

int _goldenScoreOutOf20(double absDelta) {
  if (absDelta <= 0.015) return 20;
  if (absDelta <= 0.035) return 18;
  if (absDelta <= 0.055) return 16;
  if (absDelta <= 0.085) return 13;
  if (absDelta <= 0.12) return 10;
  if (absDelta <= 0.18) return 7;
  if (absDelta <= 0.25) return 4;
  return 2;
}

String _goldenDeviationLabel(String id) {
  switch (id) {
    case 'noseWidthFaceWidth':
      return 'Mismatched Nose Proportions';
    case 'philtrumNose':
      return 'Philtrum Deviation';
    case 'eyeDistanceFaceWidth':
      return 'Eye Spacing Offset';
    case 'mouthWidthNoseWidth':
      return 'Lip Width Deviation';
    case 'eyeWidthEyeDistance':
      return 'Eye Width Imbalance';
    default:
      return 'Proportion Deviation';
  }
}

Map<String, dynamic> _showdownPayload(VGMockAnalysisSeed s) {
  const averageScore = 7.2;
  final yourScore = double.parse(s.range(7.6, 9.0, 40).toStringAsFixed(2));
  final totalParticipants = (820 + s.unit(42) * 380).round();
  final rankPosition = (4 + s.unit(43) * 44).round().clamp(4, 48);
  final topPercent = ((rankPosition / totalParticipants) * 100).ceil().clamp(1, 99);
  final rankLabel = 'Top $topPercent%';

  final score1 = double.parse((yourScore + 0.55 + s.unit(44) * 0.35).clamp(8.5, 9.8).toStringAsFixed(2));
  final score2 = double.parse((yourScore + 0.35 + s.unit(45) * 0.25).clamp(8.2, 9.5).toStringAsFixed(2));
  final score3 = double.parse((yourScore + 0.18 + s.unit(46) * 0.2).clamp(8.0, 9.2).toStringAsFixed(2));

  final podium = [
    {
      'rank': 1,
      'displayName': 'Mia R.',
      'score': score1,
      'avatarAsset': 'images/vg/mock/showdown/podium_1.png',
    },
    {
      'rank': 2,
      'displayName': 'Jordan K.',
      'score': score2,
      'avatarAsset': 'images/vg/mock/showdown/podium_2.png',
    },
    {
      'rank': 3,
      'displayName': 'Sam L.',
      'score': score3,
      'avatarAsset': 'images/vg/mock/showdown/podium_3.png',
    },
  ];

  return {
    'yourScore': yourScore,
    'averageScore': averageScore,
    'rankPosition': rankPosition,
    'totalParticipants': totalParticipants,
    'rankLabel': rankLabel,
    'rank': rankLabel,
    'engagementNote':
        'Consistent scans and community participation boosted your showdown standing this week.',
    'landmarks': _celebrityFaceLandmarks(),
    'meshConnections': _celebrityMeshConnections(),
    'podium': podium,
  };
}
