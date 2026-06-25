import 'package:verified_glam/utils/BMColors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/vg_feature_card.dart';
import '../models/vg_feature_model.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_feature_data.dart';
import '../utils/vg_navigation.dart';

class PurchaseMoreScreen extends StatelessWidget {
  final bool? enableAppbar;

  PurchaseMoreScreen({this.enableAppbar = false});

  @override
  Widget build(BuildContext context) {
    final features = getVerifiedGlamFeatures();

    return SafeArea(
      child: Scaffold(
        backgroundColor: bmLightScaffoldBackgroundColor,
        body: Stack(
          children: [
            Icon(Icons.arrow_back, size: 24).paddingAll(16).onTap(() {
              finish(context);
            }).visible(enableAppbar!),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                48.height,
                Text(VGCopy.exploreTitle, style: boldTextStyle(size: 24, color: bmSpecialColorDark)).paddingSymmetric(horizontal: 20),
                8.height,
                Text(VGCopy.exploreSubtitle, style: secondaryTextStyle(color: appTextColorSecondary)).paddingSymmetric(horizontal: 20),
                16.height,
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      final feature = features[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => vgStartAnalysis(context, feature),
                            borderRadius: BorderRadius.circular(22),
                            child: VGFeatureCard(feature: feature, compact: true),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
