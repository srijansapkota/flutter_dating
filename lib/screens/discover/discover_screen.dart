import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/providers/swipe_provider.dart';
import 'package:datingappflutter/utils/calculate_age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pink = Color(0xFFEC4899);

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swipeState = ref.watch(swipeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover'), centerTitle: true),
      body: swipeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text('Something went wrong'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: ref.read(swipeProvider.notifier).refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => data.currentIndex >= data.potentialMatches.length
            ? _EmptyDiscover(hasSeenProfiles: data.potentialMatches.isNotEmpty)
            : _DiscoverContent(user: data.potentialMatches[data.currentIndex]),
      ),
    );
  }
}

class _DiscoverContent extends ConsumerWidget {
  const _DiscoverContent({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(swipeProvider.notifier);

    Future<void> onLike() async {
      await notifier.like();
      if (!context.mounted) return;

      final matchedUser = ref.read(swipeProvider).value?.matchedUser;
      if (matchedUser == null) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("It's a Match!"),
          content: Text('You and ${matchedUser.fullName} liked each other.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                notifier.closeMatch();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(child: _MatchCard(user: user)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleButton('Pass', Icons.close, Colors.red, notifier.pass),
              const SizedBox(width: 32),
              _CircleButton('Like', Icons.favorite, _pink, onLike),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton(this.tooltip, this.icon, this.color, this.onPressed);

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 32, color: color),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 4,
        fixedSize: const Size(64, 64),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Color(0xFFEEEEEE),
      child: Center(child: Icon(Icons.person, size: 100, color: Colors.grey)),
    );
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
                  errorBuilder: (context, error, stack) => placeholder,
                )
              : placeholder,
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
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
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
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

class _EmptyDiscover extends ConsumerWidget {
  const _EmptyDiscover({required this.hasSeenProfiles});

  final bool hasSeenProfiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 72, color: _pink),
            const SizedBox(height: 24),
            Text(
              hasSeenProfiles
                  ? "You've Seen Everyone!"
                  : 'No Profiles Available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              hasSeenProfiles
                  ? 'Check back later for new profiles.'
                  : 'Check back later for new people to meet.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: ref.read(swipeProvider.notifier).refresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}