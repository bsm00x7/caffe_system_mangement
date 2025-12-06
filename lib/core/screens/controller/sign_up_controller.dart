import 'package:flutter/cupertino.dart';

import '../../../data/db/auth.dart';

class SignUpController extends ChangeNotifier {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
 Future<void> signUp()async{
    await Auth.signUp(email: email.text, password: password.text, metadata: {'name':name.text,'admin':1});
  }

}