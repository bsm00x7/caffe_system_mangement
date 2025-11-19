import 'package:flutter/cupertino.dart';

import '../../../../data/db/data.dart';
import '../../../../model/item_model.dart';

class EmployerController extends ChangeNotifier {
  List<ItemModel> items = [];
  List<int> itemCount = []; // counter for each item

  EmployerController() {
    loadItem();
  }

  void loadItem() async {
    final response = await Data.getAllItem();
    items = (response as List)
        .map((itemData) => ItemModel.toItemModel(itemData))
        .toList();

    // initialize counters with 0
    itemCount = List.filled(items.length, 0);

    notifyListeners();
  }

  void incrementItem(int index) {
    itemCount[index]++;
    notifyListeners();
  }

  void decrementItem(int index) {
    if (itemCount[index] > 0) {
      itemCount[index]--;
      notifyListeners();
    }
  }
}
