import 'package:blog_app_v1/core/notifiers.dart';
import 'package:blog_app_v1/core/supabase_client.dart';
import 'package:blog_app_v1/features/auth/services/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  await initializeSupabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: AuthGate(),
        );
      }
    );
  }
}
