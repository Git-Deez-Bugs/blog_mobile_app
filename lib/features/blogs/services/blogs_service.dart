import 'dart:io';

import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
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
        .map((path) => path['blog_image_path'])
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

  //Delete Blog
  Future<void> deleteBlog(String? imagePath, String id) async {
    if (imagePath != null) await deleteImage(imagePath);

    await supabase.from('blogs').delete().eq('blog_id', id);
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
