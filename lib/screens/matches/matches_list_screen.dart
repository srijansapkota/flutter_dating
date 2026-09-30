import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/providers/matches_provider.dart';
import 'package:datingappflutter/utils/calculate_age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesListScreen extends ConsumerWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(userMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: matches.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load matches'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(userMatchesProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (users) {
          if (users.isEmpty) {
            return const _EmptyMatches();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userMatchesProvider);

              await ref.read(userMatchesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final user = users[index];

                return _MatchTile(user: user);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final age = calculateAge(user.birthdate);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return _ChatPlaceholder(user: user);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(user: user),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.fullName}, $age',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Colors.grey,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      user.bio.isEmpty
                          ? 'No bio added yet.'
                          : user.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 32,
        child: Icon(
          Icons.person,
          size: 32,
        ),
      );
    }

    return CircleAvatar(
      radius: 32,
      backgroundImage: NetworkImage(avatarUrl),
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 16),

            Text(
              'No matches yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Keep discovering people and your matches will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatPlaceholder extends StatelessWidget {
  const _ChatPlaceholder({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.fullName),
      ),
      body: const Center(
        child: Text(
          'Chat is coming in Day 5.',
        ),
      ),
    );
  }
}