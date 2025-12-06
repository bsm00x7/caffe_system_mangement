import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/db/auth.dart';
import '../screens/ButtomNav/buttom_nav.dart';
import '../screens/controller/login_controller.dart';
import '../screens/controller/sign_up_controller.dart';
import '../screens/employer/employer_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/login/login_screen.dart';

// Create a simple notifier for auth state changes
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
  }
}

// Create a global instance of the auth notifier
final authNotifier = AuthNotifier();

// GoRouter configuration
final router = GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final user = Auth.currentUser();
    final loggingIn = state.matchedLocation == '/login';
    final signingUp = state.matchedLocation == '/signUp';
    
    // If user is logged in and trying to access login/signup pages
    if (user != null && (loggingIn || signingUp)) {
      // Check if user is admin
      if (user.userMetadata?['admin'] == 0) {
        return '/screenEmplyer';  // Non-admin users go to employer screen
      }
      return '/';  // Admin users go to home (BottomNavigationBarWidget)
    }

    // If user is NOT logged in and trying to access protected routes
    if (user == null && !loggingIn && !signingUp) {
      return '/login';  // Redirect to login
    }

    // If non-admin user is logged in and trying to access admin routes
    if (user != null && user.userMetadata?['admin'] == 0 && state.matchedLocation == '/') {
      return '/screenEmplyer';
    }

    return null;  // No redirect needed
  },

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BottomNavigationBarWidget(),
    ),
    GoRoute(
      path: '/signUp',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => SignUpController(),
        child: SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/screenEmplyer',
      builder: (context, state) => const EmployerScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => LoginController(),
        child: LoginScreen(),
      ),
    ),
  ],
);