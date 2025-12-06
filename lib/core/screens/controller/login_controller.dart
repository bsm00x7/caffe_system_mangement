import 'package:flutter/cupertino.dart';

import 'package:herfay/data/db/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/widgets/error_widgets.dart';

class LoginController extends ChangeNotifier{
  
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> login({required BuildContext context}) async {
    try {
      final response = await Auth.signIn(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      debugPrint(response.toString());

      final User? user = response.user;
      if (user == null){
        if (context.mounted) {
          CustomErrorWidgetNew.showError(
            context,
            "Login failed. Please try again.",
          );
        }
        return;
      }

      // Login successful - router will handle navigation via auth state change
      // The router's redirect logic will automatically navigate to:
      // - '/screenEmplyer' for non-admin users (admin == 0)
      // - '/' (home) for admin users

    } on AuthException catch (e) {
      String errorMessage = _getErrorMessage(e.message);
      if (context.mounted) {
        CustomErrorWidgetNew.showError(context, errorMessage);
      }

    } catch (e) {
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          "An unexpected error occurred. Please try again.",
        );
      }
    }
  }








  String _getErrorMessage(String message) {
    switch (message.toLowerCase()) {
      case "invalid login credentials":
        return "The email or password you entered is incorrect. Please try again.";
      case "email already registered":
        return "This email is already registered. Try signing in instead.";
      case "invalid password":
        return "Invalid password. Please check and try again.";
      case "invalid email":
        return "Please enter a valid email address.";
      case "too many requests":
        return "Too many login attempts. Please wait a moment and try again.";
      default:
        return "Something went wrong. Please try again.";
    }
  }


}