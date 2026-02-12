import 'package:blog_app_v1/features/blogs/models/comment_model.dart';
import 'package:blog_app_v1/features/profile/model/user_model.dart';

class Blog {
  final String id;
  final String authorId;
  final String? title;
  final String? content;
  String? imagePath;
  final DateTime? createdAt;

  // joined / computed fields
  final User? author;
  final int? commentsCount;
  final List<Comment>? comments;
  final String? signedUrl;

  Blog({
    required this.id,
    required this.authorId,
    this.title,
    this.createdAt,
    this.content,
    this.imagePath,
    this.signedUrl,
    this.author,
    this.commentsCount,
    this.comments,
  });

  factory Blog.fromMap({
    required Map<String, dynamic> blog,
    String? signedUrl,
    List<Comment>? comments,
    required User author,
  }) {
    final imagePath = blog['blog_image_path'];

    return Blog(
      id: blog['blog_id'] as String,
      authorId: blog['blog_author_id'] as String,
      title: blog['blog_title'] as String,
      content: blog['blog_content'],
      imagePath: imagePath,
      createdAt: DateTime.parse(blog['blog_created_at']),

      //Extended Fields
      author: author,
      commentsCount:
          (blog['comments'] is List && (blog['comments'] as List).isNotEmpty)
          ? ((blog['comments'][0] is Map &&
                    (blog['comments'][0] as Map).containsKey('count'))
                ? (blog['comments'][0]['count'] as int? ?? 0)
                : (blog['comments'] as List).length)
          : 0,

      comments: comments,
      signedUrl: signedUrl,
    );
  }

  //Blog object to Map
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'blog_author_id': authorId,
      'blog_title': title,
      'blog_content': content,
      'blog_image_path': imagePath,
    };
    if (includeId) {
      map['blog_id'] = id;
    }
    return map;
  }
}
