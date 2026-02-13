import 'package:blog_app_v1/components/blog_card.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key, required this.blogId, required this.onChanged});

  final String blogId;
  final VoidCallback onChanged;

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  late Future<Blog> blogFuture;

  @override
  void initState() {
    super.initState();
    blogFuture = fetchBlog();
  }

  Future<Blog> fetchBlog() {
    final blogsService = BlogsService();
    return blogsService.readBlog(widget.blogId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Blog>(
      future: blogFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final blog = snapshot.data!;

        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(child: BlogCard(blog: blog, disablePush: true, onChanged: () {
                setState(() {
                  blogFuture = fetchBlog();
                });
                widget.onChanged.call();
              },)),
            ),
          ),
        );
      },
    );
  }
}
