import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/db/auth.dart';
import '../../../model/user_model.dart';


class ScreenUserController extends ChangeNotifier {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  List<UserModel> users = [];
  bool isLoading = false;
  String? errorMessage;

  ScreenUserController() {
    loadUsers();
  }

  // Load all users from Supabase
  Future<void> loadUsers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Get users from Supabase 'users' table
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      users = (response as List)
          .map((userData) => UserModel.toUserModel(userData))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to load users: ${e.toString()}";
      isLoading = false;
      notifyListeners();
    }
  }

  // Add new user to Supabase Auth and Database
  Future<bool> addUser() async {
    if (name.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      errorMessage = "All fields are required";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Create user in Supabase Auth
      final AuthResponse authResponse = await Auth.signUp(
          email: email.text, password: password.text, metadata: {
        'name': name.text,
        'admin': 0});


    if (authResponse.user == null) {
    throw Exception("Failed to create user");
    }

    String userId = authResponse.user!.id;
    debugPrint(userId);
    // Create user model
    UserModel newUser = UserModel(
    id: userId,
    name: name.text.trim(),
    email: email.text.trim(),
      profile_image_url: null,
    );

    // Save user data to Supabase 'users' table
    await _supabase.from('users').insert(newUser.toJson());

    // Reload users to get updated list
    await loadUsers();

    clearFields();
    isLoading = false;
    notifyListeners();
    return true;
    } catch (e) {
    errorMessage = "Failed to add user: ${e.toString()}";
    isLoading = false;
    notifyListeners();
    return false;
    }
  }

  // Update existing user in Supabase
  Future<bool> updateUser(int index) async {
    if (index < 0 || index >= users.length) return false;

    if (name.text.isEmpty || email.text.isEmpty) {
      errorMessage = "Name and email are required";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String userId = users[index].id!;

      // Update user data in Supabase
      await _supabase.from('users').update({
        'name': name.text.trim(),
        'email': email.text.trim(),
      }).eq('id', userId);

      // Update Auth email if changed
      if (email.text.trim() != users[index].email) {
        await _supabase.auth.updateUser(
          UserAttributes(email: email.text.trim()),
        );
      }

      // Reload users to get updated list
      await loadUsers();

      clearFields();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Failed to update user: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete user from Supabase
  Future<bool> deleteUser(int index) async {
    if (index < 0 || index >= users.length) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String userId = users[index].id!;

      // Delete from users table
      await _supabase.from('users').delete().eq('id', userId);



      // Remove from local list
      users.removeAt(index);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Failed to delete user: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user data for editing
  void loadUserForEdit(int index) {
    if (index >= 0 && index < users.length) {
      final user = users[index];
      name.text = user.name;
      email.text = user.email;
      password.clear(); // Don't load password for security
    }
  }

  // Clear all text fields
  void clearFields() {
    name.clear();
    email.clear();
    password.clear();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }
}