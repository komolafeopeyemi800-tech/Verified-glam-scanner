import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/BMHomeFragmentHeadComponent.dart';
import '../components/vg/vg_feature_card.dart';
import '../components/vg/vg_feature_carousel.dart';
import '../main.dart';
import '../models/vg_feature_model.dart';
import '../utils/BMColors.dart';
import '../utils/BMWidgets.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_feature_data.dart';
import '../utils/vg_navigation.dart';
import '../web/vg_web_breakpoints.dart';
import '../components/vg/vg_settings_sheet.dart';

class BMHomeFragment extends StatefulWidget {
  const BMHomeFragment({Key? key}) : super(key: key);

  @override
  State<BMHomeFragment> createState() => _BMHomeFragmentState();
}

class _BMHomeFragmentState extends State<BMHomeFragment> {
  final List<VGFeatureModel> _featured = getFeaturedGlamFeatures();
  final List<VGFeatureModel> _allFeatures = getVerifiedGlamFeatures();

  @override
  void initState() {
    if (!kIsWeb) {
      setStatusBarColor(bmSpecialColor);
    }
    super.initState();
  }

  void _openFeature(VGFeatureModel feature) {
    vgStartAnalysis(context, feature);
  }

  @override
  Widget build(BuildContext context) {
    final useWebDashboardHome = kIsWeb && VGWebBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (useWebDashboardHome)
              const _WebDashboardHomeHeader()
            else
              const HomeFragmentHeadComponent(),
            if (useWebDashboardHome)
              _buildWebFeatureBody(context)
            else
              lowerContainer(
                screenContext: context,
                child: _buildMobileFeatureBody(context),
              ).cornerRadiusWithClipRRectOnly(topRight: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFeatureBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: VGWebBreakpoints.contentPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            VGCopy.homeFeaturedTitle,
            style: boldTextStyle(color: bmSpecialColorDark, size: 22),
          ),
          16.height,
          VGFeatureCarousel(features: _featured, onFeatureTap: _openFeature),
          32.height,
          Text(
            VGCopy.homeAllFeaturesTitle,
            style: boldTextStyle(color: bmSpecialColorDark, size: 22),
          ),
          16.height,
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.88,
                ),
                itemCount: _allFeatures.length,
                itemBuilder: (context, index) {
                  final feature = _allFeatures[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openFeature(feature),
                      borderRadius: BorderRadius.circular(22),
                      child: VGFeatureCard(feature: feature, gridLayout: true),
                    ),
                  );
                },
              );
            },
          ),
          40.height,
        ],
      ),
    );
  }

  Widget _buildMobileFeatureBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.height,
        titleText(title: VGCopy.homeFeaturedTitle).paddingSymmetric(horizontal: 16),
        16.height,
        VGFeatureCarousel(
          features: _featured,
          onFeatureTap: _openFeature,
        ),
        24.height,
        titleText(title: VGCopy.homeAllFeaturesTitle).paddingSymmetric(horizontal: 16),
        16.height,
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.84,
          ),
          itemCount: _allFeatures.length,
          itemBuilder: (context, index) {
            final feature = _allFeatures[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openFeature(feature),
                borderRadius: BorderRadius.circular(22),
                child: VGFeatureCard(feature: feature, gridLayout: true),
              ),
            );
          },
        ),
        40.height,
      ],
    );
  }
}

class _WebDashboardHomeHeader extends StatelessWidget {
  const _WebDashboardHomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        VGWebBreakpoints.contentPadding(context),
        24,
        VGWebBreakpoints.contentPadding(context),
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(VGCopy.homeFeaturedTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 26)),
                8.height,
                Text(VGCopy.homeSubheading, style: secondaryTextStyle(color: appTextColorSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showVGSettingsSheet(context),
            icon: const Icon(Icons.settings_outlined, color: bmSpecialColor),
          ),
        ],
      ),
    );
  }
}
