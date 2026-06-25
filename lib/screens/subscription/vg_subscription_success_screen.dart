import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/vg/vg_pill_button.dart';
import '../../utils/BMColors.dart';
import '../../utils/vg_copy.dart';
import '../BMDashboardScreen.dart';

class VGSubscriptionSuccessScreen extends StatelessWidget {
  const VGSubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bmLightScaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(color: bmLightScaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: bmSpecialColor, width: 2)),
                child: Icon(Icons.workspace_premium, color: bmSpecialColor, size: 48),
              ),
              24.height,
              Text(VGCopy.subscriptionSuccessTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 26), textAlign: TextAlign.center),
              12.height,
              Text(VGCopy.subscriptionSuccessSubtitle, style: primaryTextStyle(color: appTextColorSecondary), textAlign: TextAlign.center),
              24.height,
              _benefit(VGCopy.subscriptionSuccessBenefit1),
              _benefit(VGCopy.subscriptionSuccessBenefit2),
              _benefit(VGCopy.subscriptionSuccessBenefit3),
              const Spacer(),
              VGPillButton(
                label: VGCopy.subscriptionSuccessCta,
                onTap: () => BMDashboardScreen(flag: true).launch(context, isNewTask: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: bmSpecialColor, size: 20),
          10.width,
          Expanded(child: Text(text, style: primaryTextStyle(size: 14))),
        ],
      ),
    );
  }
}
