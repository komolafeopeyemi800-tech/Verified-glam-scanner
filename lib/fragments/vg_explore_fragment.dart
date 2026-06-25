import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/vg_feature_card.dart';
import '../components/vg/vg_main_app_bar.dart';
import '../main.dart';
import '../models/vg_feature_model.dart';
import '../utils/BMColors.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_feature_data.dart';
import '../utils/vg_navigation.dart';

class VGExploreFragment extends StatelessWidget {
  const VGExploreFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final features = getVerifiedGlamFeatures();
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      appBar: VGMainAppBar(title: VGCopy.tabExplore),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(VGCopy.exploreSubtitle, style: secondaryTextStyle(color: appTextColorSecondary)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.84),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _FeatureTile(feature: feature);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final VGFeatureModel feature;

  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => vgStartAnalysis(context, feature),
        borderRadius: BorderRadius.circular(22),
        child: VGFeatureCard(feature: feature, gridLayout: true),
      ),
    );
  }
}
