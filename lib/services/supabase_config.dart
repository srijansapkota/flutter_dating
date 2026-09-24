import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static const _url = String.fromEnvironment('NEXT_PUBLIC_SUPABASE_URL');
  static const _key =
      String.fromEnvironment('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY');

  static Future<void> initialize() async {
    if (_url.isEmpty || _key.isEmpty) {
      throw StateError(
        'Missing Supabase keys.',
      );
    }
    await Supabase.initialize(url: _url, publishableKey: _key);
  }
}

SupabaseClient get supabase => Supabase.instance.client;