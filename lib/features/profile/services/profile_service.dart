import 'package:blog_app_v1/core/supabase_client.dart';
import 'package:blog_app_v1/features/auth/services/auth_service.dart';
import 'package:blog_app_v1/features/blogs/services/blogs_service.dart';
import 'package:blog_app_v1/features/profile/model/user_model.dart';

class ProfileService {

  AuthService authService = AuthService();
  BlogsService blogsService = BlogsService();

  Future<User> getUser(String userId) async {

    final data = await supabase.from('users').select('*').eq('user_id', userId).single();

    final signedUrl = data['user_profile_path'] != null
      ? await blogsService.getImage(data['user_profile_path'])
      : null;

    return User.fromMap(data, signedUrl: signedUrl);
  }

}