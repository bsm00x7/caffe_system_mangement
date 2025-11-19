
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/db/auth.dart';
import '../screens/ButtomNav/buttom_nav.dart';
import '../screens/controller/login_controller.dart';
import '../screens/controller/sign_up_controller.dart';
import '../screens/employer/employer_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/login/login_screen.dart';

// GoRouter configuration
final router = GoRouter(
  refreshListenable: AuthNotifier(),
  redirect: (context, state) {

    final user = Auth.currentUser();
    final loggingIn = state.matchedLocation == '/login';
    final signingUp = state.matchedLocation == '/signUp';

    // If user is NOT logged in and trying to access protected routes
    if (user == null && !loggingIn && !signingUp) {
      return '/login';  // Redirect to login
    }

    // if user  not admin go to Screen Employer
    if (user != null && user.userMetadata['admin']=0){

    }

    // If user IS logged in and trying to access auth pages
    if (user != null && (loggingIn || signingUp)) {

      return '/';  // Redirect to home (BottomNavigationBarWidget)
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
      builder: (context, state) => EmployerScreen(),
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