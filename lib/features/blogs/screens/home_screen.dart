import 'package:blog_app_v1/components/navigation_bar.dart';
import 'package:blog_app_v1/core/constants.dart';
import 'package:blog_app_v1/core/notifiers.dart';
import 'package:blog_app_v1/features/auth/screens/profile_screen.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/screens/bloglist_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Widget> pages = [BloglistScreen(), ProfileScreen()];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void darkMode() async {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KConstants.themeModeKey, isDarkModeNotifier.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: darkMode,
          icon: ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
            },
          ),
        ),
        title: Text("Blog App"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Sign Out"),
                    content: Text("Are you sure you want to sign out?"),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      FilledButton(onPressed: () async {
                        isSignInNotifier.value = true;
                        selectedPageNotifier.value = 0;
                        AuthService authService = AuthService();
                        Navigator.pop(context);
                        await authService.signOut();
                      }, child: Text("Sign Out")),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
