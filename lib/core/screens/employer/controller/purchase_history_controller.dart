import 'package:flutter/cupertino.dart';
import 'package:herfay/data/db/auth.dart';
import 'package:herfay/data/db/data.dart';
import 'package:herfay/model/purchases_model.dart';

class PurchaseHistoryController extends ChangeNotifier {
  List<PurchasesModel> allPurchases = [];
  List<PurchasesModel> filteredPurchases = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  // Statistics
  double get totalSpent {
    return filteredPurchases.fold(0.0, (sum, purchase) => sum + purchase.totalAmount);
  }

  int get totalItems {
    return filteredPurchases.fold(0, (sum, purchase) => sum + purchase.quantity);
  }

  PurchaseHistoryController() {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final String employerId = Auth.currentUser()?.id ?? '';
      
      if (employerId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final response = await Data.getPurchasesByEmployer(employerId);
      allPurchases = response
          .map((purchaseData) => PurchasesModel.fromJson(purchaseData))
          .toList();

      // Initially, show all purchases
      filteredPurchases = List.from(allPurchases);

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Failed to load purchases: ${e.toString()}';
      notifyListeners();
    }
  }

  void searchPurchases(String query) {
    searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    _applyFilters();
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    _applyFilters();
  }

  void _applyFilters() {
    filteredPurchases = allPurchases.where((purchase) {
      // Search filter
      final matchesSearch = searchQuery.isEmpty ||
          purchase.itemName.toLowerCase().contains(searchQuery);

      // Date range filter
      bool matchesDate = true;
      if (startDate != null && purchase.purchaseDate != null) {
        matchesDate = purchase.purchaseDate!.isAfter(startDate!) ||
            purchase.purchaseDate!.isAtSameMomentAs(startDate!);
      }
      if (endDate != null && purchase.purchaseDate != null) {
        final endOfDay = DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
          23,
          59,
          59,
        );
        matchesDate = matchesDate &&
            (purchase.purchaseDate!.isBefore(endOfDay) ||
                purchase.purchaseDate!.isAtSameMomentAs(endOfDay));
      }

      return matchesSearch && matchesDate;
    }).toList();

    notifyListeners();
  }

  void clearAllFilters() {
    searchQuery = '';
    startDate = null;
    endDate = null;
    filteredPurchases = List.from(allPurchases);
    notifyListeners();
  }
}
