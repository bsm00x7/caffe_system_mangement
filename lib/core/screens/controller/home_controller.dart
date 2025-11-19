import 'package:flutter/cupertino.dart';
import 'package:herfay/core/utils/loading/loading.dart';
import 'package:herfay/data/db/auth.dart';
import 'package:herfay/model/user_model.dart';

class HomeController extends ChangeNotifier {
  late final UserModel user;
  HomeController() {
    init();
  }

  void init() async {
    final auth = Auth.currentUser()!;
     user = UserModel(
      id: auth.id,
      email: auth.email!,
      name: auth.userMetadata?["name"],
    );
  }
  
  
  Future<void> logout (context)async{
    LoadingWidget.show(context,message: 'Processing....');
    await Auth.signOut();
    LoadingWidget.hide();

  }
}
