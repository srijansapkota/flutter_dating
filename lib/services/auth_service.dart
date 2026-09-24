import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

enum AuthDestination { profile, editProfile }

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  const AuthService();

  User? get currentUser => supabase.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  Future<bool> signUp({required String email, required String password}) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      return res.session != null;
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<void> signOut() => supabase.auth.signOut();

  Future<AuthDestination> destinationAfterAuth(String userId) async {
    final profile = await supabase
        .from('users')
        .select('gender, bio')
        .eq('id', userId)
        .maybeSingle();

    final gender = profile?['gender'] as String?;
    final bio = profile?['bio'] as String?;

    final incomplete = profile == null || gender == null || gender == 'other' || bio == null || bio.isEmpty;
    return incomplete ? AuthDestination.editProfile : AuthDestination.profile;
  }
}
