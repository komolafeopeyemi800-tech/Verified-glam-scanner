class VGChallengeDay {
  final int dayNumber;
  final String title;
  final String mainTask;
  final String supportTask;
  final String whyLine;
  final int estMinutes;

  const VGChallengeDay({
    required this.dayNumber,
    required this.title,
    required this.mainTask,
    required this.supportTask,
    required this.whyLine,
    required this.estMinutes,
  });

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'title': title,
        'mainTask': mainTask,
        'supportTask': supportTask,
        'whyLine': whyLine,
        'estMinutes': estMinutes,
      };

  factory VGChallengeDay.fromJson(Map<String, dynamic> json) {
    return VGChallengeDay(
      dayNumber: (json['dayNumber'] as num).toInt(),
      title: (json['title'] as String?) ?? '',
      mainTask: (json['mainTask'] as String?) ?? '',
      supportTask: (json['supportTask'] as String?) ?? '',
      whyLine: (json['whyLine'] as String?) ?? '',
      estMinutes: (json['estMinutes'] as num?)?.toInt() ?? 10,
    );
  }
}
