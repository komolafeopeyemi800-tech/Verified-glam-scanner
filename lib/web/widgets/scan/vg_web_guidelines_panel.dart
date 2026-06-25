import 'package:flutter/material.dart';

import '../../../models/vg_feature_guidelines.dart';
import '../../../models/vg_feature_model.dart';
import '../../../utils/BMColors.dart';
import '../../../utils/vg_assets.dart';
import '../../../utils/vg_constants.dart';
import '../../../utils/vg_copy.dart';

/// Right column of the web tool workspace — merged photo tips (no full-screen guidelines step).
class VGWebGuidelinesPanel extends StatelessWidget {
  final VGFeatureModel feature;

  const VGWebGuidelinesPanel({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final guidelines = VGFeatureGuidelines.forFeature(feature);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          VGCopy.guidelinesTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: bmSpecialColorDark),
        ),
        const SizedBox(height: 12),
        _checklist(VGCopy.guidelinesDosTitle, guidelines.dos, Icons.check_circle_outline, Colors.green.shade700),
        const SizedBox(height: 12),
        _checklist(VGCopy.guidelinesDontsTitle, guidelines.donts, Icons.cancel_outlined, bmSpecialColor),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            guidelines.exampleAssetPath,
            fit: BoxFit.cover,
            height: 140,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Image.asset(
              vgGoodBadExamplesAsset,
              fit: BoxFit.cover,
              height: 140,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          VGCopy.uploadPrivacy,
          style: TextStyle(fontSize: 12, height: 1.5, color: appTextColorSecondary.withValues(alpha: 0.95)),
        ),
        if (feature.featureType == VGFeatureTypes.facialResemblance) ...[
          const SizedBox(height: 12),
          Text(
            VGCopy.webFaceComparisonHint,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: bmPrimaryColor.withValues(alpha: 0.95),
            ),
          ),
        ],
      ],
    );
  }

  Widget _checklist(String title, List<String> items, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bmSecondBackgroundColorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: bmSpecialColorDark)),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.45, color: appTextColorPrimary))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
