import 'package:datingappflutter/services/stream_serivice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';


final streamClientProvider = Provider<StreamChatClient>((ref) {
  return StreamChatClient(const String.fromEnvironment('STREAM_API_KEY'));
});

final streamServiceProvider = Provider<StreamService>((ref) {
  return StreamService(ref.watch(streamClientProvider));
});