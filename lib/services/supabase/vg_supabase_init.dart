import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/vg_constants.dart';
import 'vg_supabase_config.dart';
import 'vg_supabase_connection.dart';

class VGSupabaseInit {
  VGSupabaseInit._();

  static bool _initialized = false;

  static bool get isReady => _initialized && VGSupabaseConfig.isConfigured;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    vgWarnIfSupabaseMisconfigured();
    if (!kVGUseSupabase || !VGSupabaseConfig.isConfigured) return;
    if (_initialized) return;

    await Supabase.initialize(
      url: VGSupabaseConfig.url,
      anonKey: VGSupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }
}
