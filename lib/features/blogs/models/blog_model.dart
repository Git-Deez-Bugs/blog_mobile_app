class Blog {
  final String? id;
  final String? authorId;
  final String? title;
  final String? content;
  final String? imagePath;
  final String? signedUrl;
  final DateTime? createdAt;

  // joined / computed fields
  final String? authorEmail;
  final int? commentsCount;

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
  });

  factory Blog.fromMap(
    Map<String, dynamic> map,
    {String? signedUrl}
  ) {
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
      commentsCount: (map['comments'] as List).isNotEmpty
          ? map['comments'][0]['count'] as int
          : 0,
      signedUrl: signedUrl,
    );
  }
}
