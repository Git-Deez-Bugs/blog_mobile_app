class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final String? name;
  String? profilePath;

  final String? signedUrl;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    this.name,
    this.profilePath,
    this.signedUrl,
  });

  factory User.fromMap({ required Map<String, dynamic> user, String? signedUrl}) {
    return User(
      id: user['user_id'],
      email: user['user_email'],
      createdAt: DateTime.parse(user['user_created_at']),
      name: user['user_name'],
      profilePath: user['user_profile_path'],

      signedUrl: signedUrl
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'user_name': name,
      'user_profile_path': profilePath
    };
  }
}
