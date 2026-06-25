import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/vg_feature_guidelines.dart';
import '../../models/vg_feature_model.dart';
import '../../components/vg/vg_pill_button.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_assets.dart';
import '../../utils/vg_copy.dart';
import 'vg_photo_upload_screen.dart';

class VGPhotoGuidelinesScreen extends StatelessWidget {
  final VGFeatureModel feature;

  const VGPhotoGuidelinesScreen({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final guidelines = VGFeatureGuidelines.forFeature(feature);

    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: bmSpecialColor,
        foregroundColor: Colors.white,
        title: Text(VGCopy.guidelinesTitle, style: boldTextStyle(color: Colors.white, size: 18)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feature.title, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
                  20.height,
                  _box(VGCopy.guidelinesDosTitle, guidelines.dos, Icons.check_circle_outline, Colors.green.shade700),
                  16.height,
                  _box(VGCopy.guidelinesDontsTitle, guidelines.donts, Icons.cancel_outlined, bmSpecialColor),
                  24.height,
                  Center(
                    child: Image.asset(
                      guidelines.exampleAssetPath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        vgGoodBadExamplesAsset,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: VGPillButton(
              label: VGCopy.guidelinesContinue,
              onTap: () => VGPhotoUploadScreen(feature: feature).launch(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(String title, List<String> items, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: boldTextStyle(color: bmSpecialColorDark, size: 16)),
          12.height,
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    8.width,
                    Expanded(child: Text(t, style: primaryTextStyle(color: appTextColorPrimary, size: 14))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
