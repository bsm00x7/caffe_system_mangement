import 'package:flutter/material.dart';
import 'package:herfay/data/db/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/db/auth.dart';
import '../../../model/user_model.dart';

enum UserFilter { all, admins, employers }

class ScreenUserController extends ChangeNotifier {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  UserFilter selectedFilter = UserFilter.all;

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
      final response = await Data.getAllUser();

      users = (response as List)
          .map((userData) => UserModel.toUserModel(userData))
          .toList();

      // Sort by created date (newest first)
      users.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      _applyFilters();

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
        email: email.text.trim(),
        password: password.text.trim(),
        metadata: {
          'name': name.text.trim(),
          'admin': 0,
        },
      );

      if (authResponse.user == null) {
        throw Exception("Failed to create user");
      }

      String userId = authResponse.user!.id;

      // Create user model
      UserModel newUser = UserModel(
        id: userId,
        name: name.text.trim(),
        email: email.text.trim(),
        profileImageUrl: null,
        isAdmin: false,
        createdAt: DateTime.now(),
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
      _applyFilters();

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

  // Search users by name or email
  void searchUsers(String query) {
    searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Set filter
  void setFilter(UserFilter filter) {
    selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  // Apply search and filters
  void _applyFilters() {
    filteredUsers = users.where((user) {
      // Apply search filter
      bool matchesSearch = searchQuery.isEmpty ||
          user.name.toLowerCase().contains(searchQuery) ||
          user.email.toLowerCase().contains(searchQuery);

      // Apply role filter
      bool matchesRole = selectedFilter == UserFilter.all ||
          (selectedFilter == UserFilter.admins && user.isAdmin == true) ||
          (selectedFilter == UserFilter.employers && user.isAdmin == false);

      return matchesSearch && matchesRole;
    }).toList();
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

  // Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
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