import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late final SupabaseClient supabase;

Future<void> initializeSupabase() async {

  await Supabase.initialize(
    url: dotenv.get('URL'),
    anonKey: dotenv.get('ANONKEY')
  );

  supabase = Supabase.instance.client;
}

 