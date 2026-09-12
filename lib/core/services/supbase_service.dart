import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  late final SupabaseClient client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'BURAYA_SUPABASE_URL_ADRESINIZI_YAZACAKSINIZ',
      publishableKey: 'BURAYA_SUPABASE_PUBLISHABLE_KEY_DEGERINIZI_YAZACAKSINIZ',
    );
    client = Supabase.instance.client;
  }
}