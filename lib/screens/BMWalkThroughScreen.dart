import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/vg_pill_button.dart';
import '../main.dart';
import '../utils/BMColors.dart';
import '../utils/BMDataGenerator.dart';
import '../utils/vg_auth_navigation.dart';
import '../utils/vg_constants.dart';
import '../utils/vg_copy.dart';
import '../web/vg_web_breakpoints.dart';

class BMWalkThroughScreen extends StatefulWidget {
  const BMWalkThroughScreen({Key? key}) : super(key: key);

  @override
  _BMWalkThroughScreenState createState() => _BMWalkThroughScreenState();
}

class _BMWalkThroughScreenState extends State<BMWalkThroughScreen> {
  List<WalkThroughModelClass> walkThroughList = getWalkThroughList();

  Future<void> _completeWalkthrough(BuildContext context) async {
    await setValue(vgWalkthroughCompleteKey, true);
    if (!context.mounted) return;
    await vgNavigateAfterWalkthroughWithAuth(context);
  }

  PageController pageController = PageController(initialPage: 0);
  int currentIndexPage = 0;

  @override
  void initState() {
    if (!kIsWeb) {
      setStatusBarColor(Colors.transparent);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      setStatusBarColor(appStore.scaffoldBackground!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = kIsWeb && VGWebBreakpoints.isDesktop(context);

    if (desktop) {
      return Scaffold(
        backgroundColor: bmLightScaffoldBackgroundColor,
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: walkThroughList.length,
                    itemBuilder: (context, i) => Image.asset(walkThroughList[i].image!, fit: BoxFit.cover),
                    onPageChanged: (value) => setState(() => currentIndexPage = value),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(VGCopy.walkthroughSkip, style: boldTextStyle(color: bmSpecialColor, size: 14))
                            .onTap(() => _completeWalkthrough(context)),
                      ),
                      const Spacer(),
                      Text(
                        walkThroughList[currentIndexPage].title!,
                        style: boldTextStyle(size: 32, color: bmSpecialColorDark),
                      ),
                      16.height,
                      Text(
                        walkThroughList[currentIndexPage].subTitle!,
                        style: primaryTextStyle(color: appTextColorSecondary, size: 16),
                      ),
                      32.height,
                      Row(
                        children: [
                          for (int i = 0; i < walkThroughList.length; i++)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              height: 4,
                              width: i == currentIndexPage ? 30 : 14,
                              decoration: BoxDecoration(
                                color: i == currentIndexPage ? bmSpecialColor : bmPrimaryColor.withValues(alpha: 0.4),
                                borderRadius: radius(12),
                              ),
                            ),
                        ],
                      ),
                      32.height,
                      SizedBox(
                        width: 280,
                        child: VGPillButton(
                          label: VGCopy.walkthroughGetStarted,
                          onTap: () => _completeWalkthrough(context),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: context.width(),
                  height: context.height(),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: walkThroughList.length,
                    itemBuilder: (context, i) {
                      return Image.asset(walkThroughList[i].image!, fit: BoxFit.cover);
                    },
                    onPageChanged: (value) {
                      setState(() => currentIndexPage = value);
                    },
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 30,
                  child: Text(VGCopy.walkthroughSkip, style: boldTextStyle(color: white, size: 14)).onTap(() {
                    _completeWalkthrough(context);
                  }),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(walkThroughList[currentIndexPage].title!, style: boldTextStyle(size: 24, color: white)),
                    16.height,
                    Text(walkThroughList[currentIndexPage].subTitle!, style: primaryTextStyle(color: white), textAlign: TextAlign.center),
                    32.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < walkThroughList.length; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            width: i == currentIndexPage ? 30 : 14,
                            decoration: BoxDecoration(
                              color: i == currentIndexPage ? white : Colors.grey,
                              borderRadius: radius(12),
                            ),
                          ),
                      ],
                    ),
                    40.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: VGPillButton(
                        label: VGCopy.walkthroughGetStarted,
                        width: double.infinity,
                        onTap: () => _completeWalkthrough(context),
                      ),
                    ),
                    50.height,
                  ],
                ).paddingOnly(bottom: 24, right: 16, left: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
