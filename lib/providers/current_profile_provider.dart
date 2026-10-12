import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'auth_provider.dart';
import '../services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final profileService = ref.read(profileServiceProvider);

  return profileService.getCurrentUserProfile();
});