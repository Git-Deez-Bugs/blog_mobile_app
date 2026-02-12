import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/core/notifiers.dart';
import 'package:blog_app_v1/features/auth/screens/signin_screen.dart';
import 'package:blog_app_v1/features/auth/screens/signup_screen.dart';
import 'package:blog_app_v1/features/blogs/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingSpinner());
        }

        final session = snapshot.data?.session;

        if (session != null) {
          return HomeScreen();
        }

        return ValueListenableBuilder(
          valueListenable: isSignInNotifier,
          builder: (context, isSignIn, child) {
            return isSignIn ? SigninScreen() : SignupScreen();
          },
        );
      },
    );
  }
}
