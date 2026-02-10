import 'package:blog_app_v1/features/blogs/models/comment_model.dart';

class Blog {
  final String? id;
  final String? authorId;
  final String? title;
  final String? content;
  String? imagePath;
  final DateTime? createdAt;

  // joined / computed fields
  final String? authorEmail;
  final int? commentsCount;
  final List<Comment>? comments;
  final String? signedUrl;

  Blog({
    this.id,
    this.authorId,
    this.title,
    this.createdAt,
    this.content,
    this.imagePath,
    this.signedUrl,
    this.authorEmail,
    this.commentsCount,
    this.comments,
  });

  factory Blog.fromMap(
    Map<String, dynamic> map, {
    String? signedUrl,
    List<Comment>? comments,
  }) {
    final imagePath = map['blog_image_path'];

    return Blog(
      id: map['blog_id'] as String,
      authorId: map['blog_author_id'] as String,
      title: map['blog_title'] as String,
      content: map['blog_content'],
      imagePath: imagePath,
      createdAt: DateTime.parse(map['blog_created_at']),

      //Extended Fields
      authorEmail: map['users']?['user_email'],
      commentsCount:
          (map['comments'] is List && (map['comments'] as List).isNotEmpty)
          ? ((map['comments'][0] is Map &&
                    (map['comments'][0] as Map).containsKey('count'))
                ? (map['comments'][0]['count'] as int? ?? 0)
                : (map['comments'] as List).length)
          : 0,

      comments: comments,
      signedUrl: signedUrl,
    );
  }
}
