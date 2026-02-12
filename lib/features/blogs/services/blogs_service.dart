import 'dart:io';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/model/user_model.dart' as author;

class BlogsService {
  final AuthService authService = AuthService();

  // Create Blog
  Future<void> createBlog(Blog blog, file, fileName) async {
    final userId = authService.getCurrentUser()?.id;
    String? imagePath;

    if (file != null && fileName != null) {
      imagePath = await uploadImage(file, fileName);
    }

    await supabase.from('blogs').insert({
      'blog_title': blog.title,
      'blog_content': blog.content,
      'blog_author_id': userId,
      'blog_image_path': imagePath,
    });
  }

  //Read Blogs
  Future<List<Blog>> readBlogs() async {
    final data = await supabase
        .from('blogs')
        .select('*, users(*), comments(count)')
        .order('blog_created_at', ascending: false);

    final blogs = data as List;

    final blogImagePaths = blogs
        .map((b) => b['blog_image_path'])
        .whereType<String>()
        .toList();

    final userImagePaths = blogs
        .map((b) => b['users']?['user_profile_path'])
        .whereType<String>()
        .toList();

    final allPaths = [...blogImagePaths, ...userImagePaths];

    final Map<String, String> signedUrls = {};

    if (allPaths.isNotEmpty) {
      final urls = await getImages(allPaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    return blogs.map((blog) {
      final blogImagePath = blog['blog_image_path'];
      final userMap = blog['users'];

      final userImagePath = userMap?['user_profile_path'];

      final userModel = userMap != null
          ? author.User.fromMap(
              userMap,
              signedUrl: userImagePath != null
                  ? signedUrls[userImagePath]
                  : null,
            )
          : null;

      return Blog.fromMap(
        blog: blog,
        signedUrl: blogImagePath != null ? signedUrls[blogImagePath] : null,
        author: userModel!,
      );
    }).toList();
  }

  //Read Blog with Comments
  Future<Blog> readBlog(String blogId) async {
    final data = await supabase
        .from('blogs')
        .select('*, users(*), comments(*, users(*))')
        .eq('blog_id', blogId)
        .single();

    final List<String> allImagePaths = [];

    if (data['blog_image_path'] != null) {
      allImagePaths.add(data['blog_image_path']);
    }

    if (data['users']?['user_profile_path'] != null) {
      allImagePaths.add(data['users']['user_profile_path']);
    }

    final comments = (data['comments'] as List<dynamic>);

    for (final comment in comments) {
      if (comment['comment_image_path'] != null) {
        allImagePaths.add(comment['comment_image_path']);
      }

      if (comment['users']?['user_profile_path'] != null) {
        allImagePaths.add(comment['users']['user_profile_path']);
      }
    }

    final Map<String, String> signedUrls = {};

    if (allImagePaths.isNotEmpty) {
      final urls = await getImages(allImagePaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    final blogAuthorMap = data['users'];
    final blogAuthorImagePath = blogAuthorMap?['user_profile_path'];

    final blogAuthor = blogAuthorMap != null
        ? author.User.fromMap(
            blogAuthorMap,
            signedUrl: blogAuthorImagePath != null
                ? signedUrls[blogAuthorImagePath]
                : null,
          )
        : null;

    final commentModels = comments.map((comment) {
      final commentImagePath = comment['comment_image_path'];

      final commentAuthorMap = comment['users'];
      final commentAuthorImagePath = commentAuthorMap?['user_profile_path'];

      final commentAuthor = commentAuthorMap != null
          ? author.User.fromMap(
              commentAuthorMap,
              signedUrl: commentAuthorImagePath != null
                  ? signedUrls[commentAuthorImagePath]
                  : null,
            )
          : null;

      return Comment.fromMap(
        comment: comment,
        signedUrl: commentImagePath != null
            ? signedUrls[commentImagePath]
            : null,
        author: commentAuthor!,
      );
    }).toList();

    return Blog.fromMap(
      blog: data,
      signedUrl: data['blog_image_path'] != null
          ? signedUrls[data['blog_image_path']]
          : null,
      comments: commentModels,
      author: blogAuthor!,
    );
  }

  //Update Blog
  Future<void> updateBlog(
    Blog blog,
    File? file,
    String? fileName,
    String? oldImagePath,
  ) async {
    String? imagePath;

    if (file != null && fileName != null) {
      imagePath = await uploadImage(file, fileName);
    }

    await supabase
        .from('blogs')
        .update({
          'blog_title': blog.title,
          'blog_content': blog.content,
          'blog_image_path': imagePath ?? blog.imagePath,
        })
        .eq('blog_id', blog.id!);

    if ((oldImagePath != null && blog.imagePath == null) ||
        (oldImagePath != null && imagePath != null)) {
      await deleteImage(oldImagePath);
    }
  }

  //Delete Blog
  Future<void> deleteBlog(Blog blog) async {
    if (blog.imagePath != null) await deleteImage(blog.imagePath);

    await supabase.from('blogs').delete().eq('blog_id', blog.id!);
  }

  //Get Images
  Future<List<SignedUrl>> getImages(List<String> paths) {
    return supabase.storage.from('blog-images').createSignedUrls(paths, 3600);
  }

  //Get Image
  Future<String> getImage(String path) {
    return supabase.storage.from('blog-images').createSignedUrl(path, 3600);
  }

  //Upload Image
  Future<String> uploadImage(File file, String fileName) async {
    final userId = authService.getCurrentUser()?.id;

    final String path = '$userId/${fileName}_${DateTime.now()}';

    await supabase.storage.from('blog-images').upload(path, file);

    return path;
  }

  //Delete Image/s
  Future<void> deleteImage(path) async {
    final paths = path is List<String> ? path : [path.toString()];

    await supabase.storage.from('blog-images').remove(paths);
  }

  Future<void> createComment({
    required Comment comment,
    File? file,
    String? fileName,
    required String blogId,
  }) async {
    final userId = authService.getCurrentUser()?.id;
    String? imagePath;

    if (file != null && fileName != null) {
      imagePath = await uploadImage(file, fileName);
    }

    await supabase.from('comments').insert({
      'comment_blog_id': blogId,
      'comment_author_id': userId,
      'comment_text_content': comment.textContent,
      'comment_image_path': imagePath,
    });
  }
}
