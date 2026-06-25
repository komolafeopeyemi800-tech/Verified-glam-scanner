import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/BMColors.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_navigation.dart';

class BMWelcomeScreen extends StatelessWidget {
  const BMWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/welcome.png', height: 200),
          Text(VGCopy.welcomeTitle, style: boldTextStyle(color: appStore.isDarkModeOn ? Colors.white : bmSpecialColorDark, size: 24)),
          16.height,
          Text(
            VGCopy.welcomeSubtitle,
            style: secondaryTextStyle(color: appStore.isDarkModeOn ? Colors.white : bmSpecialColorDark),
            textAlign: TextAlign.center,
          ),
          16.height,
          AppButton(
            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Text(VGCopy.welcomeCta, style: boldTextStyle(color: Colors.white)),
            padding: EdgeInsets.all(16),
            width: 150,
            color: bmPrimaryColor,
            onTap: () => vgShowPostOnboardingPaywallIfNeeded(context),
          ),
        ],
      ).paddingAll(20),
    );
  }
}
