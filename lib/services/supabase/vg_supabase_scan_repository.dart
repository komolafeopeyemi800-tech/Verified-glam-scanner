import '../../models/vg_scan_result.dart';
import 'vg_supabase_auth_service.dart';
import 'vg_supabase_init.dart';

class VGSupabaseScanRepository {
  Future<List<VGScanResult>> loadAll() async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return [];

    final rows = await VGSupabaseInit.client
        .from('scans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (rows as List).map((row) => _fromRow(row as Map<String, dynamic>)).toList();
  }

  Future<VGScanResult?> getById(String id) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) return null;

    final row = await VGSupabaseInit.client
        .from('scans')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    return _fromRow(Map<String, dynamic>.from(row));
  }

  Future<void> save({
    required VGScanResult result,
    required String storagePath,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');

    try {
      await VGSupabaseInit.client.from('scans').upsert({
        'id': result.id,
        'user_id': userId,
        'feature_type': result.featureType,
        'feature_title': result.featureTitle,
        'photo_storage_path': storagePath,
        'photo_public_url': null,
        'payload': result.payload,
        'created_at': result.createdAt.toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      throw Exception('Could not save scan history to cloud: $e');
    }
  }

  VGScanResult _fromRow(Map<String, dynamic> row) {
    final rawPayload = row['payload'];
    final payload = rawPayload is Map
        ? Map<String, dynamic>.from(rawPayload)
        : <String, dynamic>{};
    final storagePath = row['photo_storage_path'] as String?;

    return VGScanResult(
      id: row['id'] as String,
      featureType: row['feature_type'] as String,
      featureTitle: row['feature_title'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      payload: payload,
      photoPath: null,
      storagePath: storagePath,
      usedMockAnalysis: payload['usedMockAnalysis'] as bool? ?? false,
    );
  }
}
