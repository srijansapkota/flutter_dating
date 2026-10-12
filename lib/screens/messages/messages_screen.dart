import 'package:datingappflutter/providers/matches_provider.dart';
import 'package:datingappflutter/screens/chat/chat_screen.dart';
import 'package:datingappflutter/utils/format_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(userMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: matches.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(userMatchesProvider),
            child: const Text('Failed to load chats. Retry'),
          ),
        ),
        data: (users) => users.isEmpty
            ? const Center(child: Text('No chats yet. Match with someone!'))
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userMatchesProvider);
                  await ref.read(userMatchesProvider.future);
                },
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final user = users[i];
                    final avatar = user.avatarUrl;
                    final hasAvatar = avatar != null && avatar.isNotEmpty;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                        child: hasAvatar ? null : const Icon(Icons.person),
                      ),
                      title: Text(user.fullName),
                      subtitle: const Text('Start your conversation!'),
                      trailing: Text(formatTime(user.createdAt)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(user: user),
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