class BlogImage {
  final String id;
  final String authorId;
  final String path;
  final String? blogId;
  final String? commentId;
  final DateTime? createdAt;
  final String? signedUrl;

  BlogImage({
    required this.id,
    required this.authorId,
    required this.path,
    this.blogId,
    this.commentId,
    this.createdAt,
    this.signedUrl
  });

  factory BlogImage.fromMap({required Map<String, dynamic> image, required String signedUrl}) {
    return BlogImage(
      id: image['image_id'],
      authorId: image['image_author_id'],
      path: image['image_path'],
      blogId: image['image_blog_id'],
      commentId: image['image_comment_id'],
      createdAt: DateTime.parse(image['image_created_at']),

      //extended
      signedUrl: signedUrl
    );
  }

  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = {
      'image_author_id': authorId,
      'image_path': path,
      'image_blog_id': blogId,
      'image_comment_id': commentId,
    };
    if (includeId) {
      map['image_id'] = id;
    }
    return map;
  }
}
