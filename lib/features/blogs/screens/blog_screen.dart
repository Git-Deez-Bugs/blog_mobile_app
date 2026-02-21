import 'package:blog_app_v1/components/blog_card.dart';
import 'package:blog_app_v1/components/loading_spinner.dart';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:flutter/material.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({
    super.key,
    required this.blogId,
    required this.onChanged,
    required this.onUpdate,
    required this.onDelete,
  });

  final String blogId;
  final VoidCallback onChanged;
  final Function(Blog updatedBlog) onUpdate;
  final Function(String blogId) onDelete;

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  Blog? _blog;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBlog();
  }

  Future<void> fetchBlog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final blogsService = BlogsService();
      final blog = await blogsService.readBlog(widget.blogId);
      setState(() {
        _blog = blog;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch blog')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: LoadingSpinner());
    }

    return Scaffold(
      appBar: AppBar(),
      body: _blog == null
          ? Center(child: Text('No blog found'))
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Material(
                  child: SingleChildScrollView(
                    child: BlogCard(
                      blog: _blog!,
                      disablePush: true,
                      onChanged: () {
                        widget.onChanged();
                      },
                      onUpdate: (updatedblog) {
                        setState(() {
                          _blog = updatedblog;
                        });
                        widget.onUpdate(updatedblog);
                      },
                      onDelete: (blogId) {
                        widget.onDelete(blogId);
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
