import 'package:nb_utils/nb_utils.dart';

import '../utils/vg_constants.dart';

/// Bonus scan credits earned via referral rewards.
class VGReferralBonusStore {
  static Future<int> bonusScansRemaining() async {
    return getIntAsync(vgReferralBonusScansKey, defaultValue: 0);
  }

  static Future<void> addBonusScans(int amount) async {
    if (amount <= 0) return;
    final current = await bonusScansRemaining();
    await setValue(vgReferralBonusScansKey, current + amount);
  }

  static Future<bool> consumeBonusScan() async {
    final current = await bonusScansRemaining();
    if (current <= 0) return false;
    await setValue(vgReferralBonusScansKey, current - 1);
    return true;
  }
}
