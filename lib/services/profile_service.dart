import 'package:datingappflutter/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final data = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    return UserProfile.fromJson(data);
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String username,
    required String gender,
    required String birthdate,
    required String bio,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    await _supabase
        .from('users')
        .update({
          'full_name': fullName,
          'username': username,
          'gender': gender,
          'birthdate': birthdate,
          'bio': bio,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);
  }

  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    final fileName =
        '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    await _supabase.storage
        .from('profile-photos')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: false),
        );
    return _supabase.storage.from('profile-photos').getPublicUrl(fileName);
  }
}
