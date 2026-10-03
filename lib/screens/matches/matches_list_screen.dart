import 'package:datingappflutter/providers/matches_provider.dart';
import 'package:datingappflutter/screens/chat/chat_screen.dart';
import 'package:datingappflutter/utils/calculate_age.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesListScreen extends ConsumerWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(userMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: matches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(userMatchesProvider),
            child: const Text('Failed to load matches. Retry'),
          ),
        ),
        data: (users) => users.isEmpty
            ? const Center(child: Text('No matches yet. Keep discovering!'))
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userMatchesProvider);
                  await ref.read(userMatchesProvider.future);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    final avatar = user.avatarUrl;
                    final hasAvatar = avatar != null && avatar.isNotEmpty;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              hasAvatar ? NetworkImage(avatar) : null,
                          child: hasAvatar ? null : const Icon(Icons.person),
                        ),
                        title: Text(
                          '${user.fullName}, ${calculateAge(user.birthdate)}',
                        ),
                        subtitle: Text(
                          '@${user.username}\n${user.bio}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(user: user),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}