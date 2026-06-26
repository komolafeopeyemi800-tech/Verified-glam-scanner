import '../models/vg_feature_model.dart';
import '../utils/vg_constants.dart';
import '../utils/vg_feature_data.dart';

/// SEO-friendly URL slugs for each scan tool (web marketing pages).
const Map<String, String> vgFeatureSlugByType = {
  VGFeatureTypes.faceBeautyAnalysis: 'face-beauty-analysis',
  VGFeatureTypes.colorAnalysis: 'seasonal-color-palette',
  VGFeatureTypes.glowUpGuide: 'beauty-routine-challenge',
  VGFeatureTypes.beautyTips: 'beauty-tips',
  VGFeatureTypes.celebrityLookalike: 'celebrity-look-alike',
  VGFeatureTypes.facialSymmetry: 'facial-symmetry',
  VGFeatureTypes.beautyScoreShowdown: 'beauty-score-showdown',
  VGFeatureTypes.facialResemblance: 'face-comparison',
  VGFeatureTypes.faceReading: 'attractiveness-test',
  VGFeatureTypes.goldenRatio: 'face-golden-ratio',
};

const Set<String> vgReservedWebPaths = {
  'login',
  'register',
  'dashboard',
  'onboarding',
  'walkthrough',
  'tools',
  'pricing',
  'forgot-password',
  'app',
  'scan',
  'settings',
  'privacy',
  'terms',
  'about',
};

List<String> get vgAllToolSlugs => vgFeatureSlugByType.values.toList();

String slugForFeatureType(String featureType) =>
    vgFeatureSlugByType[featureType] ?? 'face-beauty-analysis';

String? featureTypeForSlug(String slug) {
  for (final entry in vgFeatureSlugByType.entries) {
    if (entry.value == slug) return entry.key;
  }
  return null;
}

VGFeatureModel? featureForSlug(String slug) {
  final type = featureTypeForSlug(slug);
  if (type == null) return null;
  try {
    return getVerifiedGlamFeatures().firstWhere((f) => f.featureType == type);
  } catch (_) {
    return null;
  }
}

VGFeatureModel featureForSlugOrThrow(String slug) {
  final f = featureForSlug(slug);
  if (f == null) {
    throw ArgumentError('Unknown tool slug: $slug');
  }
  return f;
}

bool isToolSlug(String slug) => featureTypeForSlug(slug) != null;
