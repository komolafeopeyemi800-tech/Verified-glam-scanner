/// Challenge badge catalog (spec §6.3).
class VGChallengeBadgeDef {
  final String code;
  final String title;
  final String emoji;

  const VGChallengeBadgeDef({
    required this.code,
    required this.title,
    required this.emoji,
  });
}

class VGChallengeBadges {
  VGChallengeBadges._();

  static const catalog = <VGChallengeBadgeDef>[
    VGChallengeBadgeDef(code: 'skin_starter', title: 'Skin Starter', emoji: '🌱'),
    VGChallengeBadgeDef(code: 'three_day_warrior', title: '3-Day Warrior', emoji: '🏅'),
    VGChallengeBadgeDef(code: 'five_day_finisher', title: '5-Day Finisher', emoji: '⭐'),
    VGChallengeBadgeDef(code: 'seven_day_champion', title: '7-Day Champion', emoji: '💪'),
    VGChallengeBadgeDef(code: 'hydration_hero', title: 'Hydration Hero', emoji: '💧'),
    VGChallengeBadgeDef(code: 'glow_getter', title: 'Glow Getter', emoji: '✨'),
    VGChallengeBadgeDef(code: 'zen_skin', title: 'Zen Skin', emoji: '🧘'),
    VGChallengeBadgeDef(code: 'streak_master', title: 'Streak Master', emoji: '🔥'),
    VGChallengeBadgeDef(code: 'skin_royalty', title: 'Skin Royalty', emoji: '👑'),
  ];

  static VGChallengeBadgeDef? byCode(String code) {
    for (final b in catalog) {
      if (b.code == code) return b;
    }
    return null;
  }
}
