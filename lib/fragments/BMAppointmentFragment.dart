import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/vg/vg_empty_state.dart';
import '../components/vg/vg_feature_card.dart';
import '../main.dart';
import '../models/vg_feature_model.dart';
import '../utils/BMColors.dart';
import '../utils/BMWidgets.dart';
import '../utils/vg_copy.dart';
import '../utils/vg_feature_data.dart';
import '../utils/vg_navigation.dart';

class BMAppointmentFragment extends StatefulWidget {
  const BMAppointmentFragment({Key? key}) : super(key: key);

  @override
  State<BMAppointmentFragment> createState() => _BMAppointmentFragmentState();
}

class _BMAppointmentFragmentState extends State<BMAppointmentFragment> {
  final List<VGFeatureModel> _history = [];

  @override
  void initState() {
    setStatusBarColor(appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor);
    super.initState();
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: appStore.isDarkModeOn ? appStore.scaffoldBackground! : bmLightScaffoldBackgroundColor,
        elevation: 0,
        leading: const SizedBox(),
        leadingWidth: 16,
        title: titleText(title: VGCopy.exploreTitle),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? bmSecondBackgroundColorDark : bmSecondBackgroundColorLight,
          borderRadius: radiusOnly(topLeft: 32, topRight: 32),
        ),
        child: _history.isEmpty ? _emptyState() : _historyList(),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: VGEmptyState(
        icon: Icons.document_scanner_outlined,
        title: VGCopy.exploreTitle,
        subtitle: VGCopy.exploreSubtitle,
        actionLabel: VGCopy.beginAnalysis,
        onAction: () {
          final feature = getVerifiedGlamFeatures().first;
          vgStartAnalysis(context, feature);
        },
      ),
    );
  }

  Widget _historyList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VGFeatureCard(feature: _history[index], compact: true),
        );
      },
    );
  }
}
