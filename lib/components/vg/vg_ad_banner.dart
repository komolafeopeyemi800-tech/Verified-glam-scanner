import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../services/vg_subscription_store.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';

class VGAdBanner extends StatelessWidget {
  const VGAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: VGSubscriptionStore.isPro(),
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bmLightScaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.ads_click_outlined, color: bmPrimaryColor, size: 18),
              8.width,
              Expanded(
                child: Text(
                  VGCopy.adBannerPlaceholder,
                  style: secondaryTextStyle(size: 12, color: appTextColorSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
