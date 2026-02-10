import 'dart:io';

import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../../auth/services/auth_service.dart';

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
        .select('*, users(user_email), comments(count)')
        .order('blog_created_at', ascending: false);

    final imagePaths = (data as List)
        .map((blog) => blog['blog_image_path'])
        .whereType<String>()
        .toList();
    final Map<String, String> signedUrls = {};

    if (imagePaths.isNotEmpty) {
      final List<SignedUrl> urls = await getImages(imagePaths);

      urls.forEach((url) {
        signedUrls[url.path] = url.signedUrl;
      });
    }

    return (data as List).map((blog) {
      final imagePath = blog['blog_image_path'];
      final signedUrl = signedUrls[imagePath];

      return Blog.fromMap(blog, signedUrl: signedUrl);
    }).toList();
  }

  //Read Blog with Comments
  Future<Blog> readBlog(String blogId) async {
    final data = await supabase
        .from('blogs')
        .select('*, users(user_email), comments(*, users(user_email))')
        .eq('blog_id', blogId)
        .single();

    final String? signedUrl = data['blog_image_path'] != null
        ? await getImage(data['blog_image_path'])
        : null;
    
    final comments = (data['comments'] as List<dynamic>);
    final commentImagePaths = comments
        .map((comment) => comment['comment_image_path'])
        .whereType<String>()
        .toList();
    
    final Map<String, String> commentSignedUrls = {};

    if (commentImagePaths.isNotEmpty) {
      final List<SignedUrl> commentUrls = await getImages(commentImagePaths);

      for (final commentUrl in commentUrls) {
        commentSignedUrls[commentUrl.path] = commentUrl.signedUrl;
      }
    }

    final commentModels = comments.map((comment) {
      final commentImagePath = comment['comment_image_path'];

      return Comment.fromMap(comment, signedUrl: commentImagePath != null ? commentSignedUrls[commentImagePath] : null);
    }).toList();

    return Blog.fromMap(data, signedUrl: signedUrl, comments: commentModels);

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
}
