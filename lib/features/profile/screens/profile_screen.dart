import 'package:blog_app_v1/features/profile/model/user_model.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.currentUser});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: currentUser.signedUrl != null ? NetworkImage(currentUser.signedUrl!) : AssetImage('assets/images/user.png'),
              ),
              if (currentUser.name != null) Text(currentUser.name!),
              Text(currentUser.email),
            ],
          ),
        ),
      ),
    );
  }
}
