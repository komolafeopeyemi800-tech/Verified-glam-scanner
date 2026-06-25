import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verified_glam/components/vg/vg_passport_photo_frame.dart';
import 'package:verified_glam/models/vg_feature_model.dart';
import 'package:verified_glam/models/vg_scan_result.dart';
import 'package:verified_glam/screens/scan/results/vg_attractiveness_result.dart';
import 'package:verified_glam/utils/vg_copy.dart';
import 'package:verified_glam/utils/vg_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initialize();
  });

  testWidgets('renders string-heavy API payload without type cast errors', (tester) async {
    final result = VGScanResult(
      id: 'test-attractiveness',
      featureType: VGFeatureTypes.faceReading,
      featureTitle: 'Attractiveness Test',
      createdAt: DateTime.now(),
      payload: {
        'overallScore': '8.5',
        'facialAge': '25',
        'subtitle': VGCopy.attractivenessSubtitle,
        'appearanceScores': {
          'beauty': '86',
          'handsomeness': '82',
          'cuteness': '78',
          'faceShape': '84',
          'facialSymmetry': '88',
          'skinSmoothness': '90',
        },
        'traitScores': {
          'funFactor': '72',
          'intelligence': '85',
          'confidence': '80',
          'credibility': '76',
        },
        'faceBox': {
          'x': '0.2',
          'y': '0.15',
          'width': '0.6',
          'height': '0.5',
        },
        'landmarks': [
          {'x': '0.35', 'y': '0.38'},
          {'x': '0.65', 'y': '0.38'},
          {'x': '0.50', 'y': '0.52'},
          {'x': '0.50', 'y': '0.68'},
        ],
        'meshConnections': [
          ['0', '1'],
          ['1', '2'],
          ['2', '3'],
        ],
      },
    );

    const feature = VGFeatureModel(
      featureType: VGFeatureTypes.faceReading,
      title: 'Attractiveness Test',
      description: 'Test',
      icon: Icons.face,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VGAttractivenessResult(result: result, feature: feature),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(VGCopy.attractivenessAppearanceSection), findsOneWidget);
    expect(find.text(VGCopy.subscoreBeauty), findsOneWidget);
    expect(find.text(VGCopy.attractivenessTraitsSection), findsOneWidget);
    expect(find.textContaining('/10'), findsWidgets);
    expect(find.byType(VGPassportPhotoFrame), findsOneWidget);
  });

  testWidgets('shows distinct finalized sub-scores without re-boosting', (tester) async {
    final result = VGScanResult(
      id: 'test-attractiveness-finalized',
      featureType: VGFeatureTypes.faceReading,
      featureTitle: 'Attractiveness Test',
      createdAt: DateTime.now(),
      payload: {
        'scoresFinalized': true,
        'overallScore': 8.2,
        'tierLabel': 'Attractive',
        'facialAge': 26,
        'appearanceScores': {
          'beauty': 88,
          'handsomeness': 76,
          'cuteness': 70,
          'faceShape': 82,
          'facialSymmetry': 90,
          'skinSmoothness': 85,
        },
        'traitScores': {
          'funFactor': 68,
          'intelligence': 84,
          'confidence': 79,
          'credibility': 72,
        },
      },
    );

    const feature = VGFeatureModel(
      featureType: VGFeatureTypes.faceReading,
      title: 'Attractiveness Test',
      description: 'Test',
      icon: Icons.face,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VGAttractivenessResult(result: result, feature: feature),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('88'), findsOneWidget);
    expect(find.text('76'), findsOneWidget);
    expect(find.text('Attractive'), findsOneWidget);
  });

  testWidgets('renders named-object landmarks without crashing', (tester) async {
    final result = VGScanResult(
      id: 'test-attractiveness-named',
      featureType: VGFeatureTypes.faceReading,
      featureTitle: 'Attractiveness Test',
      createdAt: DateTime.now(),
      payload: {
        'overallScore': '7.8',
        'facialAge': '28',
        'appearanceScores': {},
        'traitScores': {},
        'faceBox': {'x': 0.21, 'y': 0.18, 'width': 0.58, 'height': 0.48},
        'landmarks': {
          'leftEye': {'x': '0.35', 'y': '0.38'},
          'rightEye': {'x': '0.65', 'y': '0.38'},
          'nose': {'x': '0.50', 'y': '0.52'},
          'mouth': {'x': '0.50', 'y': '0.68'},
        },
      },
    );

    const feature = VGFeatureModel(
      featureType: VGFeatureTypes.faceReading,
      title: 'Attractiveness Test',
      description: 'Test',
      icon: Icons.face,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VGAttractivenessResult(result: result, feature: feature),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(VGCopy.attractivenessAppearanceSection), findsOneWidget);
  });
}
