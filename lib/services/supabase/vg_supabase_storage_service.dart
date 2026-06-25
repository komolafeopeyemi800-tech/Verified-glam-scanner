import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/vg_copy.dart';
import '../../utils/vg_platform_file.dart';
import 'vg_supabase_auth_service.dart';
import 'vg_supabase_init.dart';

class VGSupabaseStorageService {
  static const bucket = 'scan-photos';
  static const _maxUploadBytes = 5 * 1024 * 1024;

  /// Uploads [localPath] to `{userId}/{scanId}.jpg`. Returns storage path.
  static Future<String> uploadScanPhoto({
    required String localPath,
    required String scanId,
  }) async {
    final userId = VGSupabaseAuthService.currentUser?.id;
    if (userId == null) throw StateError('Not signed in');

    final storagePath = '$userId/$scanId.jpg';
    final bytes = await vgReadFileBytes(localPath);
    if (bytes.length > _maxUploadBytes) {
      throw StateError(VGCopy.scanImageTooLarge);
    }

    await VGSupabaseInit.client.storage.from(bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return storagePath;
  }

  static Future<String?> signedUrl(String storagePath, {int expiresIn = 3600}) async {
    final res = await VGSupabaseInit.client.storage.from(bucket).createSignedUrl(
          storagePath,
          expiresIn,
        );
    return res;
  }

  /// Removes a temporary analysis upload after the Edge Function completes.
  static Future<void> deleteScanPhoto(String storagePath) async {
    if (storagePath.isEmpty) return;
    await VGSupabaseInit.client.storage.from(bucket).remove([storagePath]);
  }
}
