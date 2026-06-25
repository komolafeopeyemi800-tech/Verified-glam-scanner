class VGChallengeProgress {
  final int completedDays;
  final int currentDay;
  final bool isCompleted;
  final DateTime? lastCompletedAt;
  final DateTime? nextUnlockAt;
  final int streakCount;
  final int bestStreak;
  final String? notificationPrefTime;

  const VGChallengeProgress({
    required this.completedDays,
    required this.currentDay,
    required this.isCompleted,
    this.lastCompletedAt,
    this.nextUnlockAt,
    this.streakCount = 0,
    this.bestStreak = 0,
    this.notificationPrefTime,
  });

  Map<String, dynamic> toJson() => {
        'completedDays': completedDays,
        'currentDay': currentDay,
        'isCompleted': isCompleted,
        'lastCompletedAt': lastCompletedAt?.toIso8601String(),
        'nextUnlockAt': nextUnlockAt?.toIso8601String(),
        'streakCount': streakCount,
        'bestStreak': bestStreak,
        'notificationPrefTime': notificationPrefTime,
      };

  factory VGChallengeProgress.fromJson(Map<String, dynamic> json) {
    return VGChallengeProgress(
      completedDays: (json['completedDays'] as num?)?.toInt() ?? 0,
      currentDay: (json['currentDay'] as num?)?.toInt() ?? 1,
      isCompleted: json['isCompleted'] == true,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.tryParse(json['lastCompletedAt'] as String)
          : null,
      nextUnlockAt: json['nextUnlockAt'] != null
          ? DateTime.tryParse(json['nextUnlockAt'] as String)
          : null,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      notificationPrefTime: json['notificationPrefTime'] as String?,
    );
  }
}
