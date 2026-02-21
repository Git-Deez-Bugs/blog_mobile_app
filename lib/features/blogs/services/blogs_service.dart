import 'dart:typed_data';
import 'package:blog_app_v1/features/blogs/models/blog_model.dart';
import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/blogs/models/image_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/model/user_model.dart' as author;

class BlogsService {
  final AuthService authService = AuthService();

  // Create Blog
  Future<Blog> createBlog({
    required Map<String, dynamic> blog,
    required List<Uint8List> files,
    required List<String> fileNames,
  }) async {
    final blogResponse = await supabase
        .from('blogs')
        .insert(blog)
        .select()
        .single();

    final blogId = blogResponse['blog_id'];
    final authorId = blogResponse['blog_author_id'];

    List<Map<String, dynamic>> images = [];

    for (int i = 0; i < files.length; i++) {
      final path = await uploadImage(files[i], fileNames[i]);

      final image = BlogImage(
        id: '',
        authorId: authorId,
        path: path,
        blogId: blogId,
      );
      images.add(image.toMap());
    }

    if (images.isNotEmpty) {
      await supabase.from('images').insert(images);
    }

    final newBlog = await supabase
        .from('blogs')
        .select('*, users(*), comments(count), images(*)')
        .eq('blog_id', blogId)
        .single();

    final List<String> allImagePaths = [];

    if (newBlog['users']?['user_profile_path'] != null) {
      allImagePaths.add(newBlog['users']?['user_profile_path']);
    }

    final newImages = newBlog['images'] as List;

    for (final image in newImages) {
      allImagePaths.add(image['image_path']);
    }

    final Map<String, String> signedUrls = {};

    if (allImagePaths.isNotEmpty) {
      final urls = await getImages(allImagePaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    final authorMap = newBlog['users'];
    final authorProfilePath = authorMap['user_profile_path'];
    final authorModel = author.User.fromMap(
      user: authorMap,
      signedUrl: signedUrls[authorProfilePath],
    );

    final imageModels = newImages
        .map((image) {
          final path = image['image_path'];
          final signedUrl = signedUrls[path];
          if (signedUrl == null) return null;
          return BlogImage.fromMap(image: image, signedUrl: signedUrl);
        })
        .whereType<BlogImage>()
        .toList();

    return Blog.fromMap(
      blog: newBlog,
      author: authorModel,
      images: imageModels,
    );
  }

  //Read Blogs
  Future<List<Blog>> readBlogs() async {
    final data = await supabase
        .from('blogs')
        .select('*, users(*), comments(count), images(*)')
        .order('blog_created_at', ascending: false);

    final blogs = data as List;

    final List<String> allPaths = [];

    for (final blog in blogs) {
      final images = blog['images'] as List;

      for (final image in images) {
        if (image['image_path'] != null) {
          allPaths.add(image['image_path']);
        }
      }

      final userImagePath = blog['users']?['user_profile_path'];

      if (userImagePath != null) {
        allPaths.add(userImagePath);
      }
    }

    final Map<String, String> signedUrls = {};

    if (allPaths.isNotEmpty) {
      final urls = await getImages(allPaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    return blogs.map((blog) {
      final userMap = blog['users'];
      final userImagePath = userMap?['user_profile_path'];

      final userModel = userMap != null
          ? author.User.fromMap(
              user: userMap,
              signedUrl: userImagePath != null
                  ? signedUrls[userImagePath]
                  : null,
            )
          : null;

      final images = blog['images'] as List;

      final imageModels = images
          .where(
            (image) =>
                image['image_path'] != null &&
                signedUrls.containsKey(image['image_path']),
          )
          .map((image) {
            final path = image['image_path'];
            final signedUrl = signedUrls[path];
            if (signedUrl == null) return null;
            return BlogImage.fromMap(image: image, signedUrl: signedUrl);
          })
          .whereType<BlogImage>()
          .toList();

      return Blog.fromMap(blog: blog, images: imageModels, author: userModel!);
    }).toList();
  }

  //Read Blog with Comments
  Future<Blog> readBlog(String blogId) async {
    final data = await supabase
        .from('blogs')
        .select('*, users(*), comments(*, users(*), images(*)), images(*)')
        .eq('blog_id', blogId)
        .single();

    final List<String> allImagePaths = [];

    final images = data['images'] as List;

    for (final image in images) {
      if (image['image_path'] != null) {
        allImagePaths.add(image['image_path']);
      }
    }

    if (data['users']?['user_profile_path'] != null) {
      allImagePaths.add(data['users']['user_profile_path']);
    }

    final comments = (data['comments'] as List)
        ..sort((c1, c2) => DateTime.parse(c1['comment_created_at']).compareTo(DateTime.parse(c2['comment_created_at'])));


    for (final comment in comments) {
      for (final image in comment['images']) {
        if (image['image_path'] != null) {
          allImagePaths.add(image['image_path']);
        }
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
            user: blogAuthorMap,
            signedUrl: blogAuthorImagePath != null
                ? signedUrls[blogAuthorImagePath]
                : null,
          )
        : null;

    final commentModels = comments.map((comment) {
      final images = comment['images'] as List;
      final imageModels = images
          .where(
            (image) =>
                image['image_path'] != null &&
                signedUrls.containsKey(image['image_path']),
          )
          .map((image) {
            final path = image['image_path'];
            final signedUrl = signedUrls[path];
            if (signedUrl == null) return null;
            return BlogImage.fromMap(image: image, signedUrl: signedUrl);
          })
          .whereType<BlogImage>()
          .toList();

      final commentAuthorMap = comment['users'];
      final commentAuthorImagePath = commentAuthorMap?['user_profile_path'];

      final commentAuthor = commentAuthorMap != null
          ? author.User.fromMap(
              user: commentAuthorMap,
              signedUrl: commentAuthorImagePath != null
                  ? signedUrls[commentAuthorImagePath]
                  : null,
            )
          : null;

      return Comment.fromMap(
        comment: comment,
        images: imageModels,
        author: commentAuthor!,
      );
    }).toList();

    final imageModels = images
        .where(
          (image) =>
              image['image_path'] != null &&
              signedUrls.containsKey(image['image_path']),
        )
        .map((image) {
          final path = image['image_path'];
          final signedUrl = signedUrls[path];
          if (signedUrl == null) return null;
          return BlogImage.fromMap(image: image, signedUrl: signedUrl);
        })
        .cast<BlogImage>()
        .toList();

    return Blog.fromMap(
      blog: data,
      images: imageModels,
      comments: commentModels,
      author: blogAuthor!,
    );
  }

  //Update Blog
  Future<Blog> updateBlog({
    required Map<String, dynamic> blog,
    required List<Uint8List> files,
    required List<String> fileNames,
    required List<BlogImage> removedImages,
  }) async {
    await supabase.from('blogs').update(blog).eq('blog_id', blog['blog_id']);

    final blogId = blog['blog_id'];
    final authorId = blog['blog_author_id'];

    if (files.isNotEmpty) {
      List<Map<String, dynamic>> newImages = [];

      for (int i = 0; i < files.length; i++) {
        final path = await uploadImage(files[i], fileNames[i]);

        final newImage = BlogImage(
          id: '',
          authorId: authorId,
          path: path,
          blogId: blogId,
        );
        newImages.add(newImage.toMap());
      }

      await supabase.from('images').insert(newImages);
    }

    if (removedImages.isNotEmpty) {
      final paths = removedImages.map((e) => e.path).toList();
      await deleteImage(paths);
      await supabase.from('images').delete().inFilter('image_path', paths);
    }

    final newBlog = await supabase
        .from('blogs')
        .select('*, users(*), comments(count), images(*)')
        .eq('blog_id', blogId)
        .single();

    final List<String> allImagePaths = [];

    if (newBlog['users']?['user_profile_path'] != null) {
      allImagePaths.add(newBlog['users']?['user_profile_path']);
    }

    final newImages = newBlog['images'] as List;

    for (final image in newImages) {
      allImagePaths.add(image['image_path']);
    }

    final Map<String, String> signedUrls = {};

    if (allImagePaths.isNotEmpty) {
      final urls = await getImages(allImagePaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    final authorMap = newBlog['users'];
    final authorProfilePath = authorMap['user_profile_path'];
    final authorModel = author.User.fromMap(
      user: authorMap,
      signedUrl: signedUrls[authorProfilePath],
    );

    final imageModels = newImages
        .map((image) {
          final path = image['image_path'];
          final signedUrl = signedUrls[path];
          if (signedUrl == null) return null;
          return BlogImage.fromMap(image: image, signedUrl: signedUrl);
        })
        .whereType<BlogImage>()
        .toList();

    return Blog.fromMap(
      blog: newBlog,
      author: authorModel,
      images: imageModels,
    );
  }

  //Delete Blog
  Future<void> deleteBlog({
    required Blog blog,
    required bool haveComments,
  }) async {
    final List<String> allImagePaths = [];

    final images = blog.images;
    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        allImagePaths.add(image.path);
      }
    }

    List<dynamic> comments = [];

    if (haveComments) {
      comments = blog.comments ?? [];
    } else {
      final data = await supabase
          .from('comments')
          .select('*, images(*)')
          .eq('comment_blog_id', blog.id);
      comments = data as List<dynamic>? ?? [];
    }

    for (final comment in comments) {
      if (comment is Map) {
        for (final image in comment['images']) {
          allImagePaths.add(image['image_path']);
        }
      } else if (comment is Comment) {
        if (comment.images != null) {
          for (final image in comment.images!) {
            allImagePaths.add(image.path);
          }
        }
      }
    }

    if (allImagePaths.isNotEmpty) {
      await deleteImage(allImagePaths);
    }

    await supabase.from('blogs').delete().eq('blog_id', blog.id);
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
  Future<String> uploadImage(Uint8List file, String fileName) async {
    final userId = authService.getCurrentUser()?.id;

    final String path = '$userId/${fileName}_${DateTime.now()}';

    await supabase.storage
        .from('blog-images')
        .uploadBinary(
          path,
          file,
          fileOptions: FileOptions(contentType: 'image/*'),
        );

    return path;
  }

  //Delete Image/s
  Future<void> deleteImage(path) async {
    final paths = path is List<String> ? path : [path.toString()];

    await supabase.storage.from('blog-images').remove(paths);
  }

  //Create Comment
  Future<Comment> createComment({
    required Map<String, dynamic> comment,
    required List<Uint8List> files,
    required List<String> fileNames,
    required String blogId,
  }) async {
    final data = await supabase.from('comments').insert(comment).select();

    final commentId = data.first['comment_id'];
    final authorId = data.first['comment_author_id'];

    List<Map<String, dynamic>> images = [];

    for (int i = 0; i < files.length; i++) {
      final path = await uploadImage(files[i], fileNames[i]);

      final image = BlogImage(
        id: '',
        authorId: authorId,
        path: path,
        commentId: commentId,
      );
      images.add(image.toMap());
    }

    if (images.isNotEmpty) {
      await supabase.from('images').insert(images);
    }

    //Refetching
    final newComment = await supabase
        .from('comments')
        .select('*, users(*), images(*)')
        .eq('comment_id', commentId)
        .single();

    final List<String> allImagePaths = [];

    if (newComment['users']?['user_profile_path'] != null) {
      allImagePaths.add(newComment['users']?['user_profile_path']);
    }

    final newImages = newComment['images'] as List;

    for (final image in newImages) {
      allImagePaths.add(image['image_path']);
    }

    final Map<String, String> signedUrls = {};

    if (allImagePaths.isNotEmpty) {
      final urls = await getImages(allImagePaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    final authorMap = newComment['users'];
    final authorProfilePath = authorMap['user_profile_path'];
    final authorModel = author.User.fromMap(
      user: authorMap,
      signedUrl: signedUrls[authorProfilePath],
    );

    final imageModels = newImages
        .map((image) {
          final path = image['image_path'];
          final signedUrl = signedUrls[path];
          if (signedUrl == null) return null;
          return BlogImage.fromMap(image: image, signedUrl: signedUrl);
        })
        .whereType<BlogImage>()
        .toList();

    return Comment.fromMap(
      comment: newComment,
      author: authorModel,
      images: imageModels,
    );
  }

  //Update Comment
  Future<Comment> updateComment({
    required Map<String, dynamic> comment,
    required List<Uint8List> files,
    required List<String> fileNames,
    required List<BlogImage> removedImages,
  }) async {
    await supabase
        .from('comments')
        .update(comment)
        .eq('comment_id', comment['comment_id']);

    final commentId = comment['comment_id'];
    final authorId = comment['comment_author_id'];

    if (files.isNotEmpty) {
      List<Map<String, dynamic>> newImages = [];

      for (int i = 0; i < files.length; i++) {
        final path = await uploadImage(files[i], fileNames[i]);

        final newImage = BlogImage(
          id: '',
          authorId: authorId,
          path: path,
          commentId: commentId,
        );
        newImages.add(newImage.toMap());
      }

      await supabase.from('images').insert(newImages);
    }

    if (removedImages.isNotEmpty) {
      final paths = removedImages.map((e) => e.path).toList();
      await deleteImage(paths);
      await supabase.from('images').delete().inFilter('image_path', paths);
    }

    final updatedComment = await supabase
        .from('comments')
        .select('*, users(*), images(*)')
        .eq('comment_id', commentId)
        .single();

    final List<String> allImagePaths = [];

    if (updatedComment['users']?['user_profile_path'] != null) {
      allImagePaths.add(updatedComment['users']?['user_profile_path']);
    }

    final newImages = updatedComment['images'] as List;

    for (final image in newImages) {
      allImagePaths.add(image['image_path']);
    }

    final Map<String, String> signedUrls = {};

    if (allImagePaths.isNotEmpty) {
      final urls = await getImages(allImagePaths);
      for (final url in urls) {
        signedUrls[url.path] = url.signedUrl;
      }
    }

    final authorMap = updatedComment['users'];
    final authorProfilePath = authorMap['user_profile_path'];
    final authorModel = author.User.fromMap(
      user: authorMap,
      signedUrl: signedUrls[authorProfilePath],
    );

    final imageModels = newImages
        .map((image) {
          final path = image['image_path'];
          final signedUrl = signedUrls[path];
          if (signedUrl == null) return null;
          return BlogImage.fromMap(image: image, signedUrl: signedUrl);
        })
        .whereType<BlogImage>()
        .toList();

    return Comment.fromMap(
      comment: updatedComment,
      author: authorModel,
      images: imageModels,
    );
  }

  //Delete Comment
  Future<void> deleteComment({required Comment comment}) async {
    final List<String> allImagePaths = [];

    final images = comment.images;
    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        allImagePaths.add(image.path);
      }
    }

    if (allImagePaths.isNotEmpty) {
      await deleteImage(allImagePaths);
    }

    await supabase.from('comments').delete().eq('comment_id', comment.id);
  }
}
