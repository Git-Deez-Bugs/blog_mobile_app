import 'package:blog_app_v1/features/profile/model/user_model.dart';
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
                CircleAvatar(
                  backgroundImage: currentUser.signedUrl != null ? NetworkImage(currentUser.signedUrl!) : AssetImage('assets/images/user.png'),
                  radius: 50,
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: () {
                      
                    }, icon: Icon(Icons.edit)),
                    Text(currentUser.name ?? 'anon user', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    SizedBox(width: 50,),
                  ],
                ),
                Text(currentUser.email, style: TextStyle(color: Colors.blueAccent),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
