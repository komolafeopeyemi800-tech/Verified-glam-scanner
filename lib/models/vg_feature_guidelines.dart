import '../utils/vg_assets.dart';
import '../utils/vg_constants.dart';
import '../utils/vg_copy.dart';
import 'vg_feature_model.dart';

class VGFeatureGuidelines {
  final List<String> dos;
  final List<String> donts;
  final String exampleAssetPath;

  const VGFeatureGuidelines({
    required this.dos,
    required this.donts,
    required this.exampleAssetPath,
  });

  static VGFeatureGuidelines forFeature(VGFeatureModel feature) {
    if (feature.featureType == VGFeatureTypes.facialResemblance) {
      return const VGFeatureGuidelines(
        dos: VGCopy.guidelinesDosTwoFaces,
        donts: VGCopy.guidelinesDontsTwoFaces,
        exampleAssetPath: vgFaceComparisonGoodBadAsset,
      );
    }
    return const VGFeatureGuidelines(
      dos: VGCopy.guidelinesDos,
      donts: VGCopy.guidelinesDonts,
      exampleAssetPath: vgGoodBadExamplesAsset,
    );
  }
}
