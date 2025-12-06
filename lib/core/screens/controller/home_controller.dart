import 'package:flutter/cupertino.dart';
import 'package:herfay/core/utils/loading/loading.dart';
import 'package:herfay/data/db/auth.dart';
import 'package:herfay/model/user_model.dart';

import '../../../data/db/data.dart';
import '../../services/report_export_service.dart';

class HomeController extends ChangeNotifier {
  late final UserModel user;

  // Loading states
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Statistics
  double _totalRevenue = 0;
  double _totalRevenueToday = 0;
  int _totalNumberPurchase = 0;
  int _totalNumberPurchaseToday = 0;
  int _numberOfItemLowStock = 0;

  // Weekly sales data
  List<double> _weeklySalesData = [0, 0, 0, 0, 0, 0, 0];

  // Recent purchases
  List<Map<String, dynamic>> _recentPurchases = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  double get totalRevenue => _totalRevenue;
  double get totalRevenueToday => _totalRevenueToday;
  int get totalNumberPurchase => _totalNumberPurchase;
  int get totalNumberPurchaseToday => _totalNumberPurchaseToday;
  int get numberOfItemLowStock => _numberOfItemLowStock;
  List<double> get weeklySalesData => _weeklySalesData;
  List<Map<String, dynamic>> get recentPurchases => _recentPurchases;

  HomeController() {
    init();
  }

  /// Initialize the controller by loading all data
  Future<void> init() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load user data
      final auth = Auth.currentUser();
      if (auth == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      user = UserModel(
        id: auth.id,
        email: auth.email!,
        name: auth.userMetadata?["name"] ?? "User",
      );

      // Load all data in parallel for better performance
      await Future.wait([
        _loadPurchaseStats(),
        _loadLowStockItems(),
        _loadWeeklySales(),
        _loadRecentPurchases(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      debugPrint('HomeController init error: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    try {
      _isRefreshing = true;
      _errorMessage = null;
      notifyListeners();

      // Reload all data in parallel
      await Future.wait([
        _loadPurchaseStats(),
        _loadLowStockItems(),
        _loadWeeklySales(),
        _loadRecentPurchases(),
      ]);

      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh data: ${e.toString()}';
      _isRefreshing = false;
      notifyListeners();
      debugPrint('HomeController refresh error: $e');
    }
  }

  /// Load purchase statistics
  Future<void> _loadPurchaseStats() async {
    try {
      final data = await Data.getPurchaseStats();
      _totalRevenue = (data['total_revenue'] as num?)?.toDouble() ?? 0.0;
      _totalNumberPurchase = (data['total_purchases'] as num?)?.toInt() ?? 0;
      _totalNumberPurchaseToday = (data['today_purchases'] as num?)?.toInt() ?? 0;
      _totalRevenueToday = (data['today_revenue'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('Error loading purchase stats: $e');
      rethrow;
    }
  }

  /// Load low stock items count
  Future<void> _loadLowStockItems() async {
    try {
      final response = await Data.getLowStockItems();
      _numberOfItemLowStock = response.length;
    } catch (e) {
      debugPrint('Error loading low stock items: $e');
      rethrow;
    }
  }

  /// Load weekly sales data for chart
  Future<void> _loadWeeklySales() async {
    try {
      final salesData = await Data.getWeeklySales();
      
      // Initialize array with zeros for the last 7 days
      final Map<int, double> dailySales = {};
      final now = DateTime.now();
      
      // Initialize all days with 0
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayIndex = day.weekday - 1; // Monday = 0, Sunday = 6
        dailySales[dayIndex] = 0.0;
      }
      
      // Populate with actual sales data
      for (var sale in salesData) {
        if (sale['purchase_date'] != null && sale['total_amount'] != null) {
          final purchaseDate = DateTime.parse(sale['purchase_date']);
          final dayIndex = purchaseDate.weekday - 1;
          dailySales[dayIndex] = (dailySales[dayIndex] ?? 0.0) + 
                                 (sale['total_amount'] as num).toDouble();
        }
      }
      
      // Convert to list ordered by day of week
      _weeklySalesData = List.generate(7, (index) => dailySales[index] ?? 0.0);
    } catch (e) {
      debugPrint('Error loading weekly sales: $e');
      _weeklySalesData = [0, 0, 0, 0, 0, 0, 0];
      rethrow;
    }
  }

  /// Load recent purchases for activity feed
  Future<void> _loadRecentPurchases() async {
    try {
      _recentPurchases = await Data.getRecentPurchases(limit: 5);
    } catch (e) {
      debugPrint('Error loading recent purchases: $e');
      _recentPurchases = [];
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout(BuildContext context) async {
    try {
      LoadingWidget.show(context, message: 'Logging out....');
      await Auth.signOut();
      LoadingWidget.hide();
    } catch (e) {
      LoadingWidget.hide();
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  /// Export report as PDF
  Future<String?> exportReportPDF(BuildContext context) async {
    try {
      LoadingWidget.show(context, message: 'Generating PDF...');
      
      final filePath = await ReportExportService.exportSalesPDF(
        totalRevenue: _totalRevenue,
        todayRevenue: _totalRevenueToday,
        totalPurchases: _totalNumberPurchase,
        todayPurchases: _totalNumberPurchaseToday,
        weeklySales: _weeklySalesData,
        recentPurchases: _recentPurchases,
      );
      
      LoadingWidget.hide();
      return filePath;
    } catch (e) {
      LoadingWidget.hide();
      debugPrint('Export PDF error: $e');
      return null;
    }
  }

  /// Export report as CSV
  Future<String?> exportReportCSV(context) async {
    try {
      LoadingWidget.show(context, message: 'Generating CSV...');
      
      final filePath = await ReportExportService.exportSalesCSV(
        totalRevenue: _totalRevenue,
        todayRevenue: _totalRevenueToday,
        totalPurchases: _totalNumberPurchase,
        todayPurchases: _totalNumberPurchaseToday,
        weeklySales: _weeklySalesData,
        recentPurchases: _recentPurchases,
      );
      
      LoadingWidget.hide();
      return filePath;
    } catch (e) {
      LoadingWidget.hide();
      debugPrint('Export CSV error: $e');
      return null;
    }
  }

}
