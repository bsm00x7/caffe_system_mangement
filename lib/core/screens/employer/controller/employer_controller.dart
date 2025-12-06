import 'package:flutter/cupertino.dart';
import 'package:herfay/data/db/auth.dart';

import '../../../../data/db/data.dart';
import '../../../../model/item_model.dart';

class EmployerController extends ChangeNotifier {
  List<ItemModel> items = [];
  List<int> itemCount = [];
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
      await affectationEmployer(items, itemCount);
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

  Future<void> affectationEmployer(List<ItemModel> items,
      List<int> itemCount) async {
    final String employerId = Auth.currentUser()?.id ?? '';
    
    if (employerId.isEmpty) {
      throw Exception('User not authenticated');
    }
    for (int i = 0; i < items.length; i++) {
      if (itemCount[i] > 0) {
        final item = items[i];
        final quantity = itemCount[i];
        final priceAtPurchase = item.price;
        final totalAmount = priceAtPurchase * quantity;
        final purchaseData = {
          'employer_id': employerId,
          'item_id': item.id,
          'quantity': quantity,
          'price_at_purchase': priceAtPurchase,
          'total_amount': totalAmount,
        };

        // Insert purchase into database
        await Data.addPurchase(purchaseData);

        // Update item stock
        final newStock = item.stock - quantity;
        await Data.updateStock(item.id, newStock);
      }
    }
  }
}
