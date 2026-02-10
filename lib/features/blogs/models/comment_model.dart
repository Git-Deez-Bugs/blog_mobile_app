class Comment {
  final String id;
  final String blogId;
  final String authorId;
  final String? textContent;
  final String? imagePath;
  final DateTime createdAt;

  final String? authorEmail;
  final String? signedUrl;

  Comment({
    required this.id,
    required this.blogId,
    required this.authorId,
    this.textContent,
    this.imagePath,
    required this.createdAt,
    this.authorEmail,
    this.signedUrl,
  });

  factory Comment.fromMap(Map<String, dynamic> map, {String? signedUrl}) {
    print(map);
    return Comment(
      id: map['comment_id']?.toString() ?? '',
      blogId: map['comment_blog_id']?.toString() ?? '',
      authorId: map['comment_author_id']?.toString() ?? '',
      textContent: map['comment_text_content'] as String?,
      imagePath: map['comment_image_path'] as String?,
      createdAt: map['comment_created_at'] != null
          ? DateTime.parse(map['comment_created_at'])
          : DateTime.now(),
      authorEmail: map['users']?['user_email'],
      signedUrl: signedUrl,
    );
  }
}
