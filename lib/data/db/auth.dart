import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth {
  static final _instance = Supabase.instance.client;

  static Session? get session => _instance.auth.currentSession;

  static bool checkSession() {
    return session != null;
  }

  static User? currentUser() {
    return _instance.auth.currentUser;
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    return await _instance.auth.signUp(
      password: password,
      email: email,
      data: metadata,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _instance.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  static Future<void> signOut() async {
    await _instance.auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _instance.auth.resetPasswordForEmail(email);
  }
}


// This class for listener if user login user logout
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    // Initialize listener in constructor
    _initAuthListener();
  }

  void _initAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}