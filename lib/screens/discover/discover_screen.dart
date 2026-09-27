import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/providers/swipe_provider.dart';
import 'package:datingappflutter/utils/calculate_age.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swipeState = ref.watch(swipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        centerTitle: true,
      ),
      body: swipeState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text('Something went wrong'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.read(swipeProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data.currentIndex >= data.potentialMatches.length) {
            return _EmptyDiscover(
              hasSeenProfiles: data.potentialMatches.isNotEmpty,
            );
          }

          final user = data.potentialMatches[data.currentIndex];

          return _DiscoverContent(user: user);
        },
      ),
    );
  }
}

class _DiscoverContent extends ConsumerWidget {
  const _DiscoverContent({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: _MatchCard(user: user),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Pass',
                onPressed: () {
                  ref.read(swipeProvider.notifier).pass();
                },
                icon: const Icon(
                  Icons.close,
                  size: 32,
                  color: Colors.red,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  fixedSize: const Size(64, 64),
                ),
              ),
              const SizedBox(width: 32),
              IconButton(
                tooltip: 'Like',
                onPressed: () async {
                  await ref.read(swipeProvider.notifier).like();

                  if (!context.mounted) {
                    return;
                  }

                  final matchedUser =
                      ref.read(swipeProvider).value?.matchedUser;

                  if (matchedUser != null) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text("It's a Match!"),
                          content: Text(
                            'You and ${matchedUser.fullName} liked each other.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ref
                                    .read(swipeProvider.notifier)
                                    .closeMatch();
                              },
                              child: const Text('Continue'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.favorite,
                  size: 32,
                  color: Color(0xFFEC4899),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  fixedSize: const Size(64, 64),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      child: Stack(
        fit: StackFit.expand,
        children: [
          avatarUrl != null && avatarUrl.isNotEmpty
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const _DefaultAvatar();
                  },
                )
              : const _DefaultAvatar(),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black87,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.fullName}, ${calculateAge(user.birthdate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${user.username}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.bio!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _EmptyDiscover extends ConsumerWidget {
  const _EmptyDiscover({
    required this.hasSeenProfiles,
  });

  final bool hasSeenProfiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              size: 72,
              color: Color(0xFFEC4899),
            ),
            const SizedBox(height: 24),
            Text(
              hasSeenProfiles
                  ? "You've Seen Everyone!"
                  : 'No Profiles Available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSeenProfiles
                  ? 'Check back later for new profiles.'
                  : 'Check back later for new people to meet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(swipeProvider.notifier).refresh();
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}