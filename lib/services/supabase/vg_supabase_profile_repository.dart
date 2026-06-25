import '../../models/vg_onboarding_profile.dart';
import 'vg_supabase_auth_service.dart';
import 'vg_supabase_init.dart';

class VGSupabaseProfileRepository {
  static String? _sanitize(String? value, {int maxLen = 120}) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxLen ? trimmed.substring(0, maxLen) : trimmed;
  }

  static List<String> _sanitizeList(List<String> values, {int maxLen = 80}) {
    return values
        .map((v) => _sanitize(v, maxLen: maxLen))
        .whereType<String>()
        .toList();
  }

  static Future<void> upsertFromOnboarding(VGOnboardingProfile profile) async {
    final user = VGSupabaseAuthService.currentUser;
    if (user == null) return;

    await VGSupabaseInit.client.from('profiles').upsert({
      'id': user.id,
      'email': _sanitize(user.email, maxLen: 254),
      'age': profile.age,
      'gender': _sanitize(profile.gender),
      'beauty_goals': _sanitizeList(profile.beautyGoals),
      'skin_concerns': _sanitizeList(profile.skinConcerns),
      'product_preferences': _sanitizeList(profile.productPreferences),
      'skin_type': _sanitize(profile.skinType),
      'ethnicity': _sanitize(profile.ethnicity),
      'aesthetic': _sanitize(profile.aesthetic),
      'onboarding_complete': true,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<VGOnboardingProfile?> fetchProfile() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return null;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;

    return VGOnboardingProfile(
      age: row['age'] as int?,
      gender: row['gender'] as String?,
      beautyGoals: List<String>.from(row['beauty_goals'] as List? ?? []),
      skinConcerns: List<String>.from(row['skin_concerns'] as List? ?? []),
      productPreferences: List<String>.from(row['product_preferences'] as List? ?? []),
      skinType: row['skin_type'] as String?,
      ethnicity: row['ethnicity'] as String?,
      aesthetic: row['aesthetic'] as String?,
    );
  }

  static Future<bool> isOnboardingCompleteRemote() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return false;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select('onboarding_complete')
        .eq('id', userId)
        .maybeSingle();
    return row?['onboarding_complete'] == true;
  }

  static Future<String?> referralCode() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return null;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select('referral_code')
        .eq('id', userId)
        .maybeSingle();
    var code = row?['referral_code'] as String?;
    if (code != null && code.isNotEmpty) return code;

    code = _generateCode();
    await VGSupabaseInit.client.from('profiles').update({
      'referral_code': code,
    }).eq('id', userId);
    return code;
  }

  static Future<int> referralDownloadCount() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return 0;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select('referral_download_count')
        .eq('id', userId)
        .maybeSingle();
    return (row?['referral_download_count'] as num?)?.toInt() ?? 0;
  }

  static Future<int> incrementReferralDownloadCount() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return 0;

    final current = await referralDownloadCount();
    final next = current + 1;
    await VGSupabaseInit.client.from('profiles').update({
      'referral_download_count': next,
    }).eq('id', userId);
    return next;
  }

  static Future<bool> isReferralBonusRedeemedRemote() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return false;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select('referral_bonus_redeemed')
        .eq('id', userId)
        .maybeSingle();
    return row?['referral_bonus_redeemed'] == true;
  }

  static Future<void> setReferralBonusRedeemed({required int bonusScans}) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return;

    final row = await VGSupabaseInit.client
        .from('profiles')
        .select('bonus_scans')
        .eq('id', userId)
        .maybeSingle();
    final currentBonus = (row?['bonus_scans'] as num?)?.toInt() ?? 0;

    await VGSupabaseInit.client.from('profiles').update({
      'referral_bonus_redeemed': true,
      'bonus_scans': currentBonus + bonusScans,
    }).eq('id', userId);
  }

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = DateTime.now().millisecondsSinceEpoch;
    final buf = StringBuffer();
    for (var i = 0; i < 8; i++) {
      buf.write(chars[(r + i * 17) % chars.length]);
    }
    return buf.toString();
  }
}
