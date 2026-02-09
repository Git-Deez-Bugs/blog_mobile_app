import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

class AuthService {
  
  //Register
  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(email: email, password: password);
  }

  //Login
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    return await supabase.auth.signInWithPassword(email: email, password: password);
  } 

  //Logout
  Future<void> signOut() async {
    return await supabase.auth.signOut();
  }

  //Get Current Session
  Session? getCurrentSession() => supabase.auth.currentSession;

  //Get Current User
  User? getCurrentUser() => supabase.auth.currentUser;
}
