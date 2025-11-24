import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/db/data.dart';
import '../../../model/item_model.dart';

class StockController extends ChangeNotifier {
  final TextEditingController itemName = TextEditingController();
  final TextEditingController stock = TextEditingController();
  final TextEditingController imageUrl = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  List<ItemModel> items = [];
  bool isLoading = false;
  String? errorMessage;

  StockController() {
    loadItems();
  }

  // Load all items from Supabase
  Future<void> loadItems() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await Data.getAllItems();
      items = (response as List)
          .map((itemData) => ItemModel.toItemModel(itemData))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to load items: ${e.toString()}";
      isLoading = false;
      notifyListeners();
    }
  }

  // Add new item to Supabase
  Future<bool> addItem() async {
    if (itemName.text.isEmpty || stock.text.isEmpty) {
      errorMessage = "Item name and stock are required";
      notifyListeners();
      return false;
    }

    int? stockValue = int.tryParse(stock.text);
    if (stockValue == null || stockValue < 0) {
      errorMessage = "Please enter a valid stock number";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Insert new item into items table
      await _supabase.from('items').insert({
        'item_name': itemName.text.trim(),
        'stock': stockValue,
        'image': imageUrl.text.trim().isEmpty ? null : imageUrl.text.trim(),
      });

      // Reload items to get updated list
      await loadItems();

      clearFields();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Failed to add item: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update existing item in Supabase
  Future<bool> updateItem(int index) async {
    if (index < 0 || index >= items.length) return false;

    if (itemName.text.isEmpty || stock.text.isEmpty) {
      errorMessage = "Item name and stock are required";
      notifyListeners();
      return false;
    }

    int? stockValue = int.tryParse(stock.text);
    if (stockValue == null || stockValue < 0) {
      errorMessage = "Please enter a valid stock number";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      int itemId = items[index].id;

      // Update item data in Supabase
      await _supabase.from('items').update({
        'item_name': itemName.text.trim(),
        'stock': stockValue,
        'image': imageUrl.text.trim().isEmpty ? null : imageUrl.text.trim(),
      }).eq('id', itemId);

      // Reload items to get updated list
      await loadItems();

      clearFields();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Failed to update item: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete item from Supabase
  Future<bool> deleteItem(int index) async {
    if (index < 0 || index >= items.length) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      int itemId = items[index].id;

      // Delete from items table
      await _supabase.from('items').delete().eq('id', itemId);

      // Remove from local list
      items.removeAt(index);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = "Failed to delete item: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load item data for editing
  void loadItemForEdit(int index) {
    if (index >= 0 && index < items.length) {
      final item = items[index];
      itemName.text = item.item_name;
      stock.text = item.stock.toString();
      imageUrl.text = item.image ?? '';
    }
  }

  // Clear all text fields
  void clearFields() {
    itemName.clear();
    stock.clear();
    imageUrl.clear();
  }

  @override
  void dispose() {
    itemName.dispose();
    stock.dispose();
    imageUrl.dispose();
    super.dispose();
  }
}
