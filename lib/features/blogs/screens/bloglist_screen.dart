import 'package:blog_app_v1/components/blog_card.dart';
import 'package:blog_app_v1/components/create_blog_card.dart';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';

class BloglistScreen extends StatefulWidget {
  const BloglistScreen({super.key});

  @override
  State<BloglistScreen> createState() => _BloglistScreenState();
}

class _BloglistScreenState extends State<BloglistScreen> {
  List<Blog> _blogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      BlogsService blogService = BlogsService();
      _blogs = await blogService.readBlogs();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch blogs')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addBlog(Blog newBlog) {
    setState(() => _blogs.insert(0, newBlog));
  }

  void updateBlog(Blog updatedBlog) {
    setState(() {
      final index = _blogs.indexWhere((blog) => blog.id == updatedBlog.id);
      if (index != -1) {
        setState(() {
          _blogs[index] = updatedBlog;
        });
      }
    });
  }

  void deleteBlog(String blogId) {
    setState(() => _blogs.removeWhere((blog) => blog.id == blogId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? LoadingSpinner()
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  itemCount: _blogs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CreateBlogCard(onCreate: addBlog);
                    }

                    final blog = _blogs[index - 1];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: BlogCard(
                        key: ValueKey(blog.id),
                        blog: blog,
                        disablePush: false,
                        onChanged: fetchBlogs,
                        onUpdate: updateBlog,
                        onDelete: deleteBlog,
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
