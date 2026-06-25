import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../services/vg_push_service.dart';
import '../utils/BMColors.dart';
import '../utils/vg_copy.dart';
import 'BMWelcomeScreen.dart';

class BMEnableNotificationScreen extends StatelessWidget {
  const BMEnableNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          20.height,
          Column(
            children: [
              Image.asset('images/notification.png', height: 200),
              Text(
                VGCopy.notificationsTitle,
                style: boldTextStyle(color: appStore.isDarkModeOn ? Colors.white : bmSpecialColorDark),
                textAlign: TextAlign.center,
              ),
              16.height,
              Text(
                VGCopy.notificationsBody,
                style: secondaryTextStyle(color: appStore.isDarkModeOn ? Colors.white : bmSpecialColorDark),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Column(
            children: [
              AppButton(
                width: context.width() - 40,
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Text(VGCopy.notificationsCta, style: boldTextStyle(color: Colors.white)),
                padding: const EdgeInsets.all(16),
                color: bmPrimaryColor,
                onTap: () async {
                  await VGPushService.requestPermissionAndSync();
                  if (!context.mounted) return;
                  BMWelcomeScreen().launch(context);
                },
              ),
              20.height,
              GestureDetector(
                onTap: () => BMWelcomeScreen().launch(context),
                child: Text(
                  VGCopy.notificationsSkip,
                  style: boldTextStyle(color: appStore.isDarkModeOn ? bmPrimaryColor : Colors.grey),
                ),
              ),
            ],
          )
        ],
      ).paddingAll(20),
    );
  }
}
