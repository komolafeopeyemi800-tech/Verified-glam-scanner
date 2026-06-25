import '../../models/vg_feature_model.dart';

/// Short-lived navigation payload for profile sub-routes on desktop web.
class VGWebProfileNavCache {
  VGWebProfileNavCache._();

  static Map<String, dynamic>? reward;
  static VGFeatureModel? rewardFeature;

  static void setReward(Map<String, dynamic> data, VGFeatureModel feature) {
    reward = data;
    rewardFeature = feature;
  }

  static void clearReward() {
    reward = null;
    rewardFeature = null;
  }
}
