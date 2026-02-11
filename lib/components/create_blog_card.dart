import 'package:blog_app_v1/features/blogs/screens/create_update_blog_screen.dart';
import 'package:flutter/material.dart';

class CreateBlogCard extends StatelessWidget {
  const CreateBlogCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateUpdateBlogScreen()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                SizedBox(width: 10),
                Icon(Icons.edit),
                SizedBox(width: 10),
                Text("What's on your mind?"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
