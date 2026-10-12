import 'package:datingappflutter/services/stream_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

final streamClientProvider = Provider<StreamChatClient>((ref) {
  return StreamChatClient(const String.fromEnvironment('STREAM_API_KEY'));
});

final streamServiceProvider = Provider<StreamService>((ref) {
  return StreamService(ref.watch(streamClientProvider));
});

final chatChannelProvider =
    FutureProvider.autoDispose.family<Channel, String>((ref, otherUserId) {
  return ref.watch(streamServiceProvider).openChannel(otherUserId);
});