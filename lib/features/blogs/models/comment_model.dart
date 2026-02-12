import 'package:blog_app_v1/features/profile/model/user_model.dart';

class Comment {
  final String id;
  final String blogId;
  final User author;
  final String? textContent;
  final String? imagePath;
  final DateTime createdAt;

  final String? authorEmail;
  final String? signedUrl;

  Comment({
    required this.id,
    required this.blogId,
    required this.author,
    this.textContent,
    this.imagePath,
    required this.createdAt,
    this.authorEmail,
    this.signedUrl,
  });

  factory Comment.fromMap({ required Map<String, dynamic> comment, String? signedUrl, required User author}) {
    return Comment(
      id: comment['comment_id']?.toString() ?? '',
      blogId: comment['comment_blog_id']?.toString() ?? '',
      author: author,
      textContent: comment['comment_text_content'] as String?,
      imagePath: comment['comment_image_path'] as String?,
      createdAt: comment['comment_created_at'] != null
          ? DateTime.parse(comment['comment_created_at'])
          : DateTime.now(),
      authorEmail: comment['users']?['user_email'],
      signedUrl: signedUrl,
    );
  }
}
