import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_copy.dart';
import '../vg_scan_photo_image.dart';

class VGShowdownRankCard extends StatelessWidget {
  final String? photoPath;
  final int rankPosition;
  final int totalParticipants;
  final String rankLabel;
  final double yourScore;
  final double averageScore;
  final String engagementNote;

  const VGShowdownRankCard({
    super.key,
    this.photoPath,
    required this.rankPosition,
    required this.totalParticipants,
    required this.rankLabel,
    required this.yourScore,
    required this.averageScore,
    required this.engagementNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bmPrimaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserThumb(photoPath: photoPath),
          14.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  VGCopy.showdownYourRank,
                  style: boldTextStyle(color: bmSpecialColorDark, size: 14),
                ),
                6.height,
                RichText(
                  text: TextSpan(
                    style: primaryTextStyle(size: 15, height: 1.3),
                    children: [
                      TextSpan(
                        text: '#$rankPosition',
                        style: boldTextStyle(color: bmSpecialColor, size: 28),
                      ),
                      TextSpan(
                        text: ' ${VGCopy.showdownOfParticipants(totalParticipants)}',
                        style: secondaryTextStyle(size: 13),
                      ),
                    ],
                  ),
                ),
                8.height,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bmSpecialColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(rankLabel, style: boldTextStyle(color: bmSpecialColor, size: 12)),
                ),
                10.height,
                Text(
                  engagementNote,
                  style: secondaryTextStyle(size: 12, height: 1.4),
                ),
                8.height,
                Text(
                  VGCopy.showdownVsCommunity(yourScore, averageScore),
                  style: primaryTextStyle(size: 12, color: bmSpecialColorDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserThumb extends StatelessWidget {
  final String? photoPath;

  const _UserThumb({this.photoPath});

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    final child = VGScanPhotoImage(
      photoPath: photoPath,
      fit: BoxFit.cover,
      placeholder: ColoredBox(
        color: bmLightScaffoldBackgroundColor,
        child: Icon(Icons.person, color: bmPrimaryColor.withValues(alpha: 0.4)),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}
