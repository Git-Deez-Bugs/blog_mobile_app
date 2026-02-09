import 'dart:developer';

import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

class BlogsService {

  Future<List<Blog>> readBlogs() async {

    final data = await supabase
      .from('blogs')
      .select('*, users(user_email), comments(count)')
      .order('blog_created_at', ascending: false);

    final imagePaths = (data as List).map((path) => path['blog_image_path']).whereType<String>().toList();
    final Map<String, String> signedUrls = {};

    if (imagePaths.isNotEmpty) {
      final List<SignedUrl> urls = await supabase.storage.from('blog-images').createSignedUrls(imagePaths, 3600);
      
      urls.forEach((url) {
        signedUrls[url.path] = url.signedUrl;
        log(signedUrls[url.path].toString());
      });
    }

    return (data as List)
      .map((blog) => Blog.fromMap(blog, signedUrls))
      .toList();

  }

}