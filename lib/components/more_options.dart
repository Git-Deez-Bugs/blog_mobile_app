import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';

class MoreOptions extends StatelessWidget {
  const MoreOptions({super.key, this.imagePath, required this.id});

  final String? imagePath;
  final String id;

  Future<void> deleteBlog() async {
    BlogsService blogsService = BlogsService();
    await blogsService.deleteBlog(imagePath, id);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: deleteBlog, icon: Icon(Icons.delete));
  }
}