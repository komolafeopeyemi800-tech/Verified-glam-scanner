import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/BMColors.dart';
import '../../../utils/vg_challenge_badges.dart';

/// Badge grid for profile and reward screens.
class VGChallengeBadgeGrid extends StatelessWidget {
  final List<Map<String, dynamic>> earnedBadges;
  final bool loading;
  final bool compact;

  const VGChallengeBadgeGrid({
    super.key,
    required this.earnedBadges,
    this.loading = false,
    this.compact = false,
  });

  bool _isEarned(String code) {
    return earnedBadges.any((b) => b['badge_code'] == code);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: compact ? 12 : 16,
      runSpacing: compact ? 10 : 12,
      children: VGChallengeBadges.catalog.map((badge) {
        final earned = _isEarned(badge.code);
        return _BadgeItem(
          emoji: badge.emoji,
          name: badge.title,
          earned: earned,
          compact: compact,
        );
      }).toList(),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji;
  final String name;
  final bool earned;
  final bool compact;

  const _BadgeItem({
    required this.emoji,
    required this.name,
    required this.earned,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 48.0;
    return SizedBox(
      width: compact ? 64 : 72,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned ? const Color(0xFFFEF3C7) : bmLightScaffoldBackgroundColor,
              border: Border.all(
                color: earned ? const Color(0xFFF59E0B) : bmPrimaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Opacity(
              opacity: earned ? 1 : 0.45,
              child: Text(emoji, style: TextStyle(fontSize: compact ? 18 : 22)),
            ),
          ),
          6.height,
          Text(
            name,
            style: boldTextStyle(size: compact ? 9 : 10, color: appTextColorSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
