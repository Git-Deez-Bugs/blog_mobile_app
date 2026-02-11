import 'package:blog_app_v1/components/view_profile_dialog.dart';
import 'package:blog_app_v1/features/profile/model/user_model.dart';
import 'package:blog_app_v1/features/profile/screens/edit_name_screen.dart';
import 'package:blog_app_v1/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                InkResponse(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onInverseSurface,
                        content: Column(
                          children: [
                            ViewProfileDialog(currentUser: currentUser),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        currentUser: currentUser,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  radius: 25,
                  child: CircleAvatar(
                    backgroundImage: currentUser.signedUrl != null
                        ? NetworkImage(currentUser.signedUrl!)
                        : AssetImage('assets/images/user.png'),
                    radius: 50,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditNameScreen(currentUser: currentUser),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                    Text(
                      currentUser.name ?? 'anon user',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 50),
                  ],
                ),
                Text(
                  currentUser.email,
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
