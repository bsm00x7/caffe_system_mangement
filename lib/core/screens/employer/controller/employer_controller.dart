import 'package:flutter/cupertino.dart';
import 'package:herfay/data/db/data.dart';
import 'package:herfay/model/item_model.dart';

class EmployerController extends ChangeNotifier{

  int number_item =0;

  List<ItemModel> items = [];

  EmployerController(){
    loadItem();
  }

  void loadItem() async{
    debugPrint("hello");
    final response =await Data.getAllItem();
    debugPrint(response.length.toString());
    items = (response as List)
        .map((itemData) => ItemModel.toItemModel(itemData))
        .toList();
    notifyListeners();
  }
}