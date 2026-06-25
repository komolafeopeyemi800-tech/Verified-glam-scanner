import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../../../utils/vg_payload_values.dart';
import '../../../web/vg_web_breakpoints.dart';
import 'vg_subscore_row.dart';

class VGBeautyReportCard extends StatelessWidget {
  final int beautyScore;
  final Map<String, dynamic> subscores;
  final String disclaimer;
  final bool desktopLayout;

  const VGBeautyReportCard({
    super.key,
    required this.beautyScore,
    required this.subscores,
    required this.disclaimer,
    this.desktopLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final useDesktop = desktopLayout || (kIsWeb && VGWebBreakpoints.isDesktop(context));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(useDesktop ? 28 : 20, useDesktop ? 28 : 20, useDesktop ? 28 : 20, useDesktop ? 22 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.22)),
        boxShadow: useDesktop
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: useDesktop ? _desktopBody() : _mobileBody(),
    );
  }

  Widget _mobileBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(VGCopy.resultBeautyReportTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 22)),
        4.height,
        Text(VGCopy.resultBeautyScoreLabel, style: secondaryTextStyle(color: appTextColorSecondary, size: 12)),
        12.height,
        _scoreRow(52),
        20.height,
        ..._subscoreRows(),
        8.height,
        Text(disclaimer, style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.4)),
      ],
    );
  }

  Widget _desktopBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(VGCopy.resultBeautyBreakdownTitle, style: boldTextStyle(color: bmSpecialColorDark, size: 20)),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bmSecondBackgroundColorLight,
                border: Border.all(color: bmSpecialColor.withValues(alpha: 0.35), width: 3),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$beautyScore', style: boldTextStyle(color: bmSpecialColorDark, size: 36)),
                  Text('/ 100', style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(VGCopy.resultBeautyScoreLabel, style: boldTextStyle(color: bmSpecialColor, size: 13)),
                  const SizedBox(height: 6),
                  Text(
                    'AI-assessed from your photo — subscores below show where you shine.',
                    style: secondaryTextStyle(size: 13, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoCol = constraints.maxWidth >= 420;
            final rows = _subscoreRows();
            if (!twoCol) {
              return Column(children: rows);
            }
            return Column(
              children: [
                for (var i = 0; i < rows.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: i + 2 < rows.length ? 4 : 0),
                    child: Row(
                      children: [
                        Expanded(child: rows[i]),
                        if (i + 1 < rows.length) ...[
                          const SizedBox(width: 16),
                          Expanded(child: rows[i + 1]),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(disclaimer, style: secondaryTextStyle(color: appTextColorSecondary, size: 11, height: 1.4)),
      ],
    );
  }

  Widget _scoreRow(double size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('$beautyScore', style: boldTextStyle(color: bmSpecialColorDark, size: size.round())),
        6.width,
        Text('/ 100', style: secondaryTextStyle(color: appTextColorSecondary, size: 18)),
      ],
    );
  }

  List<Widget> _subscoreRows() => [
        VGSubscoreRow(label: VGCopy.subscoreSymmetry, percent: _sub('symmetry')),
        VGSubscoreRow(label: VGCopy.subscoreFeatureBalance, percent: _sub('featureBalance')),
        VGSubscoreRow(label: VGCopy.subscoreSkinQuality, percent: _sub('skinQuality')),
        VGSubscoreRow(label: VGCopy.subscoreYouthfulCues, percent: _sub('youthfulCues')),
        VGSubscoreRow(label: VGCopy.subscoreOverallBeauty, percent: _sub('overallBeauty')),
      ];

  int _sub(String key) => VGPayloadValues.asIntOr(subscores[key], 0);
}
