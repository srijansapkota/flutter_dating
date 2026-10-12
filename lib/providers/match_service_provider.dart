import 'package:datingappflutter/services/match_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchServiceProvider = Provider<MatchService>((ref) {
  return const MatchService();
});