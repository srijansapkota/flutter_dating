import 'package:datingappflutter/models/user_profile.dart';
import 'package:datingappflutter/providers/stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(chatChannelProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(user.fullName)),
      body: channel.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load chat'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(chatChannelProvider(user.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (channel) => StreamChat(
          client: ref.watch(streamClientProvider),
          child: StreamChannel(
            channel: channel,
            child: Column(
              children: [
                const Expanded(child: StreamMessageListView()),
                StreamMessageComposer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}