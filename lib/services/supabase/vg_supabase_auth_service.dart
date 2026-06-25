import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../vg_push_service.dart';
import '../vg_session_scan_cache.dart';
import 'vg_supabase_config.dart';
import 'vg_supabase_init.dart';

class VGSupabaseAuthService {
  VGSupabaseAuthService._();

  static Session? get currentSession =>
      VGSupabaseInit.isReady ? VGSupabaseInit.client.auth.currentSession : null;

  static User? get currentUser =>
      VGSupabaseInit.isReady ? VGSupabaseInit.client.auth.currentUser : null;

  static bool get isSignedIn => currentSession != null;

  static Stream<AuthState> get onAuthStateChange =>
      VGSupabaseInit.client.auth.onAuthStateChange;

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return VGSupabaseInit.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return VGSupabaseInit.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signInWithGoogle() async {
    if (!VGSupabaseConfig.hasGoogleSignIn) {
      throw StateError('GOOGLE_WEB_CLIENT_ID dart-define is not set');
    }

    final google = GoogleSignIn(
      serverClientId: VGSupabaseConfig.googleWebClientId,
    );
    final account = await google.signIn();
    if (account == null) {
      throw StateError('Google sign-in cancelled');
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google idToken missing');
    }

    await VGSupabaseInit.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: auth.accessToken,
    );
  }

  static Future<void> resetPassword(String email) {
    return VGSupabaseInit.client.auth.resetPasswordForEmail(email);
  }

  static Future<void> signOut() async {
    try {
      await VGPushService.deactivateCurrentToken();
    } catch (_) {}
    VGSessionScanCache.clear();
    if (VGSupabaseConfig.hasGoogleSignIn) {
      try {
        await GoogleSignIn(serverClientId: VGSupabaseConfig.googleWebClientId).signOut();
      } catch (_) {}
    }
    await VGSupabaseInit.client.auth.signOut();
  }
}
