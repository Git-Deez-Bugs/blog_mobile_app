class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final String? name;
  final String? profilePath;

  final String? signedUrl;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    this.name,
    this.profilePath,
    this.signedUrl,
  });

  factory User.fromMap(Map<String, dynamic> map, {String? signedUrl}) {
    return User(
      id: map['user_id'],
      email: map['user_email'],
      createdAt: DateTime.parse(map['user_created_at']),
      name: map['user_name'],
      profilePath: map['user_profile_path'],

      signedUrl: signedUrl
    );
  }
}
