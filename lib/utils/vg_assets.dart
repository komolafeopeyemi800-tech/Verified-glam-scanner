/// Bundled Verified Glam image assets.
const vgGoodBadExamplesAsset = 'images/vg/guidelines/good_bad_examples.png';
const vgFaceComparisonGoodBadAsset = 'images/vg/guidelines/face_comparison_good_bad.png';
const vgUploadSelfiePortraitAsset = 'images/vg/upload_selfie_portrait.png';

/// Optional feature card thumbnails — drop PNGs here; app falls back to CustomPaint.
const vgFeatureThumbFaceBeautyAsset = 'images/vg/features/face_beauty_analysis.png';
const vgFeatureThumbColorAsset = 'images/vg/features/seasonal_color_palette.png';
const vgFeatureThumbGlowUpAsset = 'images/vg/features/glow_up_guide.png';
const vgFeatureThumbBeautyTipsAsset = 'images/vg/features/beauty_tips.png';
const vgFeatureThumbCelebrityAsset = 'images/vg/features/celebrity_look_alike.png';
const vgFeatureThumbSymmetryAsset = 'images/vg/features/facial_symmetry.png';
const vgFeatureThumbShowdownAsset = 'images/vg/features/beauty_score_showdown.png';
const vgFeatureThumbResemblanceAsset = 'images/vg/features/face_comparison.png';
const vgFeatureThumbAttractivenessAsset = 'images/vg/features/attractiveness_test.png';
const vgFeatureThumbGoldenRatioAsset = 'images/vg/features/face_golden_ratio.png';

String? featureThumbnailAssetForType(String featureType) {
  switch (featureType) {
    case 'FACE_BEAUTY_ANALYSIS':
      return vgFeatureThumbFaceBeautyAsset;
    case 'COLOR_ANALYSIS':
      return vgFeatureThumbColorAsset;
    case 'GLOW_UP_GUIDE':
      return vgFeatureThumbGlowUpAsset;
    case 'BEAUTY_TIPS':
      return vgFeatureThumbBeautyTipsAsset;
    case 'CELEBRITY_LOOKALIKE':
      return vgFeatureThumbCelebrityAsset;
    case 'FACIAL_SYMMETRY':
      return vgFeatureThumbSymmetryAsset;
    case 'BEAUTY_SCORE_SHOWDOWN':
      return vgFeatureThumbShowdownAsset;
    case 'FACIAL_RESEMBLANCE':
      return vgFeatureThumbResemblanceAsset;
    case 'FACE_READING':
      return vgFeatureThumbAttractivenessAsset;
    case 'GOLDEN_RATIO':
      return vgFeatureThumbGoldenRatioAsset;
    default:
      return null;
  }
}
