import 'package:blog_app_v1/components/blog_card.dart';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/screens/create_blog_screen.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BloglistScreen extends StatelessWidget {
  const BloglistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Blog>>(
        future: BlogsService().readBlogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSpinner();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final blogs = snapshot.data;

          if (blogs == null || blogs.isEmpty) {
            return const Center(child: Text('No blogs found'));
          }

          return ListView.builder(
            itemCount: blogs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBlogScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
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

              final blog = blogs[index - 1];

              final formattedDate = DateFormat(
                'MMM d, yyyy',
              ).format(blog.createdAt!);
              print('blog: $index - ${blog.signedUrl}');

              return BlogCard(
                id: blog.id!,
                author: blog.authorEmail,
                createdAt: formattedDate,
                title: blog.title!,
                textContent: blog.content,
                imageContent: blog.signedUrl,
                imagePath: blog.imagePath,
                commentsCount: blog.commentsCount,
              );
            },
          );
        },
      ),
    );
  }
}
