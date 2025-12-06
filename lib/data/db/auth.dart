import 'package:supabase_flutter/supabase_flutter.dart';
class Auth {
  static final SupabaseClient _supabase = Supabase.instance.client;
  // Get current user
  static User? currentUser() {
    return _supabase.auth.currentUser;
  }
  // Sign up new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }
  // Sign in
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  // Sign out
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  // Check if user is admin
  static Future<bool> isAdmin() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final response = await _supabase
        .from('users')
        .select('is_admin')
        .eq('id', user.id)
        .single();
    return response['is_admin'] ?? false;
  }
  // Update user metadata
  static Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.updateUser(
      UserAttributes(
        email: email,
        password: password,
        data: data,
      ),
    );
  }
  // Reset password
  static Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}