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
  bool _isLoadingMore = false;
  int _page = 0;
  final int _limit = 5;
  bool _hasMore = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBlogs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_isLoadingMore &&
          _hasMore) {
        fetchBlogs(isLoadMore: true);
      }
    });
  }

  Future<void> fetchBlogs({bool isLoadMore = false}) async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      BlogsService blogService = BlogsService();
      final newBlogs = await blogService.readBlogs(
        limit: _limit,
        offset: _page * _limit,
      );

      setState(() {
        if (isLoadMore) {
          _blogs.addAll(newBlogs);
        } else {
          _blogs = newBlogs;
        }
        _hasMore = newBlogs.length == _limit;
        if (_hasMore) _page++;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch blogs')));
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
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
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
                  controller: _scrollController,
                  itemCount: 1 + _blogs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CreateBlogCard(onCreate: addBlog);
                    }else if (index <= _blogs.length) {
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
                    } else {
                      return _isLoadingMore ? Center(child: LoadingSpinner()) : SizedBox(height: 100, child: Center(child: Text('You\'ve reached the end of the list')),);
                    }
                  },
                ),
              ),
            ),
    );
  }
}
