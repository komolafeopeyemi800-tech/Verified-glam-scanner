/// Push notification copy for Beauty Routine Challenge (spec Part 4).
class VGChallengePushCopy {
  VGChallengePushCopy._();

  static Map<String, dynamic> payload({
    required String kind,
    required int dayNumber,
    required String challengeName,
    required String challengeId,
  }) {
    switch (kind) {
      case 'unlock':
        return {
          'title': 'Day $dayNumber is ready for you! 🌿',
          'body':
              'Your $challengeName continues today — tap to see today\'s task.',
          'deepLink': '/challenge/day$dayNumber',
          'kind': kind,
          'challengeId': challengeId,
        };
      case 'streak':
        return {
          'title': "Don't forget your Day $dayNumber task today! 💧",
          'body': 'Takes just 10 minutes. Your skin is counting on you!',
          'deepLink': '/challenge/day$dayNumber',
          'kind': kind,
          'challengeId': challengeId,
        };
      case 'evening':
        return {
          'title': "Still time for Day $dayNumber tonight! 💧",
          'body': 'Your skin challenge is waiting — tap to finish today\'s task.',
          'deepLink': '/challenge/day$dayNumber',
          'kind': kind,
          'challengeId': challengeId,
        };
      case 'reminder':
        return {
          'title': "Hey! You haven't completed Day $dayNumber yet 💪",
          'body': "Don't break your streak — you're so close!",
          'deepLink': '/challenge/day$dayNumber',
          'kind': kind,
          'challengeId': challengeId,
        };
      case 'completion':
        return {
          'title': 'YOU DID IT! 🎉',
          'body':
              'You completed your full challenge! Open the app to claim your reward.',
          'deepLink': '/challenge/reward',
          'kind': kind,
          'challengeId': challengeId,
        };
      default:
        return {
          'title': 'Your challenge update',
          'body': 'Open Verified Glam to continue your routine.',
          'deepLink': '/challenge/day$dayNumber',
          'kind': kind,
          'challengeId': challengeId,
        };
    }
  }
}
