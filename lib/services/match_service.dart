import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/services/supabase_config.dart';

class LikeResult {
  const LikeResult({
    required this.isMatch,
    this.matchedUser,
  });

  final bool isMatch;
  final UserProfile? matchedUser;
}

class MatchService {
  const MatchService();

  Future<List<UserProfile>> getPotentialMatches() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final response = await supabase.rpc('get_potential_matches');

    return response
        .map<UserProfile>(
          (user) => UserProfile.fromJson(user),
        )
        .toList();
  }

  Future<LikeResult> likeUser(String toUserId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final alreadyLiked = await supabase
        .from('likes')
        .select()
        .eq('from_user_id', user.id)
        .eq('to_user_id', toUserId)
        .maybeSingle();

    if (alreadyLiked == null) {
      await supabase.from('likes').insert({
        'from_user_id': user.id,
        'to_user_id': toUserId,
      });
    }

    final sortedIds = [user.id, toUserId]..sort();

    final match = await supabase
        .from('matches')
        .select()
        .eq('user1_id', sortedIds[0])
        .eq('user2_id', sortedIds[1])
        .maybeSingle();

    if (match == null) {
      return const LikeResult(isMatch: false);
    }

    final matchedUserData = await supabase
        .from('users')
        .select()
        .eq('id', toUserId)
        .single();

    return LikeResult(
      isMatch: true,
      matchedUser: UserProfile.fromJson(matchedUserData),
    );
  }
}