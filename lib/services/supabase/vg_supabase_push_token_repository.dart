import 'vg_supabase_auth_service.dart';
import 'vg_supabase_init.dart';

class VGSupabasePushTokenRepository {
  Future<void> upsertToken({
    required String token,
    required String platform,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null || token.isEmpty) return;
    await VGSupabaseInit.client.from('device_push_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': platform,
      'is_active': true,
      'last_seen_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'fcm_token');
  }

  Future<void> deactivateToken(String token) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null || token.isEmpty) return;
    await VGSupabaseInit.client.from('device_push_tokens').update({
      'is_active': false,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId).eq('fcm_token', token);
  }
}
