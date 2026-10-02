import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'supabase_config.dart';

class StreamService {
  StreamService(this.client);

  final StreamChatClient client;

  Future<void> connect() async {
    if (client.state.currentUser != null) return;

    final res = await supabase.functions.invoke('stream-token');
    final data = res.data as Map<String, dynamic>;

    await client.connectUser(
      User(
        id: data['userId'] as String,
        name: data['userName'] as String?,
        image: data['userImage'] as String?,
      ),
      data['token'] as String,
    );
  }

  Future<void> disconnect() => client.disconnectUser();
}
