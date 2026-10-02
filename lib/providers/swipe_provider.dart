import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/services/match_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final matchServiceProvider = Provider<MatchService>((ref) {
  return const MatchService();
});

class SwipeState {
  const SwipeState({
    required this.potentialMatches,
    this.currentIndex = 0,
    this.matchedUser,
  });

  final List<UserProfile> potentialMatches;
  final int currentIndex;
  final UserProfile? matchedUser;

  bool get hasMore => currentIndex < potentialMatches.length;

  UserProfile? get currentUser {
    if (!hasMore) {
      return null;
    }

    return potentialMatches[currentIndex];
  }

  SwipeState copyWith({
    List<UserProfile>? potentialMatches,
    int? currentIndex,
    UserProfile? matchedUser,
    bool clearMatchedUser = false,
  }) {
    return SwipeState(
      potentialMatches: potentialMatches ?? this.potentialMatches,
      currentIndex: currentIndex ?? this.currentIndex,
      matchedUser:
          clearMatchedUser ? null : matchedUser ?? this.matchedUser,
    );
  }
}

final swipeProvider =
    AsyncNotifierProvider<SwipeNotifier, SwipeState>(
  SwipeNotifier.new,
);

class SwipeNotifier extends AsyncNotifier<SwipeState> {
  late final MatchService _matchService;

  @override
  Future<SwipeState> build() async {
    _matchService = ref.read(matchServiceProvider);

    final potentialMatches =
        await _matchService.getPotentialMatches();

    return SwipeState(
      potentialMatches: potentialMatches,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final potentialMatches =
          await _matchService.getPotentialMatches();

      state = AsyncData(
        SwipeState(
          potentialMatches: potentialMatches,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void pass() {
    final currentState = state.value;

    if (currentState == null || !currentState.hasMore) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        currentIndex: currentState.currentIndex + 1,
      ),
    );
  }

  Future<void> like() async {
    final currentState = state.value;

    if (currentState == null || !currentState.hasMore) {
      return;
    }

    final person = currentState.currentUser!;

    try {
      final result = await _matchService.likeUser(person.id);

      state = AsyncData(
        currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          matchedUser: result.matchedUser,
        ),
      );
    } catch (_) {
      state = AsyncData(
        currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
        ),
      );
    }
  }

  void closeMatch() {
    final currentState = state.value;

    if (currentState == null) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        clearMatchedUser: true,
      ),
    );
  }
}