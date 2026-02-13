import 'dart:typed_data';
import 'package:blog_app_v1/core/supabase_client.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:blog_app_v1/features/profile/model/user_model.dart';

class ProfileService {
  AuthService authService = AuthService();
  BlogsService blogsService = BlogsService();

  //Get Current User
  Future<User> getUser(String userId) async {
    final data = await supabase
        .from('users')
        .select('*')
        .eq('user_id', userId)
        .single();

    final signedUrl = data['user_profile_path'] != null
        ? await blogsService.getImage(data['user_profile_path'])
        : null;

    return User.fromMap(user: data, signedUrl: signedUrl);
  }

  //Get Current User Using Stream
  Stream<User?> streamUser(String userId) {
    return supabase
        .from('users')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .asyncMap((data) async {
          if ((data as List).isEmpty) return null;

          final user = data.first;
          final signedUrl = user['user_profile_path'] != null
              ? await blogsService.getImage(user['user_profile_path'])
              : null;

          return User.fromMap(user: user, signedUrl: signedUrl);
        });
  }

  //Update User Name
  Future<void> updateName({required Map<String, dynamic> user}) async {
    await supabase
        .from('users')
        .update(user)
        .eq('user_id', user['user_id']);
  }

  //Update User Profile
  Future<void> updateProfile({
    required Map<String, dynamic> user,
    Uint8List? file,
    String? fileName,
    oldImagePath,
  }) async {
    String? imagePath;

    if (file != null && fileName != null) {
      imagePath = await blogsService.uploadImage(file, fileName);
      user['user_profile_path'] = imagePath;
    }

    await supabase
        .from('users')
        .update(user)
        .eq('user_id', user['user_id']);

    if ((oldImagePath != null && user['user_profile_path'] == null) ||
        (oldImagePath != null && imagePath != null)) {
      await blogsService.deleteImage(oldImagePath);
    }
  }
}
