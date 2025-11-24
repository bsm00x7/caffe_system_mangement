import 'package:flutter/cupertino.dart';

import '../../../../data/db/data.dart';
import '../../../../model/item_model.dart';

class EmployerController extends ChangeNotifier {
  List<ItemModel> items = [];
  List<int> itemCount = []; // counter for each item
  bool isLoading = true;
  String? errorMessage;

  // Cart management
  double get totalAmount {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      total += items[i].price * itemCount[i];
    }
    return total;
  }

  int get totalItems {
    return itemCount.fold(0, (sum, count) => sum + count);
  }

  bool get hasItemsInCart {
    return totalItems > 0;
  }

  EmployerController() {
    loadItem();
  }

  Future<void> loadItem() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await Data.getAllItems();
      items = (response as List)
          .map((itemData) => ItemModel.toItemModel(itemData))
          .toList();

      // initialize counters with 0
      itemCount = List.filled(items.length, 0);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load items: ${e.toString()}';
      notifyListeners();
    }
  }

  void incrementItem(int index) {
    if (itemCount[index] < items[index].stock) {
      itemCount[index]++;
      notifyListeners();
    }
  }

  void decrementItem(int index) {
    if (itemCount[index] > 0) {
      itemCount[index]--;
      notifyListeners();
    }
  }

  void clearCart() {
    itemCount = List.filled(items.length, 0);
    notifyListeners();
  }

  Future<bool> submitCart() async {
    try {
      // TODO: Implement actual submission to database
      // await Data.affectationEmployer(items, itemCount);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      clearCart();
      return true;
    } catch (e) {
      errorMessage = 'Failed to submit order: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void affectation(ItemModel item) async {
    //Data.affectationEmployer();
  }
}
