import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/providers/match_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userMatchesProvider = FutureProvider<List<UserProfile>>((ref) async {
  final matchService = ref.read(matchServiceProvider);

  return matchService.getUserMatches();
});