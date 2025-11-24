import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class Data {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // ============ USERS ============
  
  // Get all users
  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  // Update user
  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _supabase
        .from('users')
        .update(data)
        .eq('id', userId);
  }

  // Delete user
  static Future<void> deleteUser(String userId) async {
    await _supabase
        .from('users')
        .delete()
        .eq('id', userId);
  }

  // ============ ITEMS ============

  // Get all items
  static Future<List<Map<String, dynamic>>> getAllItems() async {
    final response = await _supabase
        .from('items')
        .select()
        .order('item_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get item by ID
  static Future<Map<String, dynamic>?> getItemById(int itemId) async {
    final response = await _supabase
        .from('items')
        .select()
        .eq('id', itemId)
        .maybeSingle();
    return response;
  }

  // Add new item
  static Future<Map<String, dynamic>> addItem(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('items')
        .insert(data)
        .select()
        .single();
    return response;
  }

  // Update item
  static Future<void> updateItem(int itemId, Map<String, dynamic> data) async {
    await _supabase
        .from('items')
        .update(data)
        .eq('id', itemId);
  }

  // Delete item
  static Future<void> deleteItem(int itemId) async {
    await _supabase
        .from('items')
        .delete()
        .eq('id', itemId);
  }

  // Update stock
  static Future<void> updateStock(int itemId, int newStock) async {
    await _supabase
        .from('items')
        .update({'stock': newStock})
        .eq('id', itemId);
  }

  // Get low stock items
  static Future<List<Map<String, dynamic>>> getLowStockItems() async {
    final response = await _supabase.rpc('get_low_stock_alert');
    return List<Map<String, dynamic>>.from(response);
  }

  // ============ PURCHASES ============

  // Add purchase
  static Future<Map<String, dynamic>> addPurchase(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('purchases')
        .insert(data)
        .select()
        .single();
    return response;
  }

  // Get purchases by employer
  static Future<List<Map<String, dynamic>>> getPurchasesByEmployer(
    String employerId,
  ) async {
    final response = await _supabase
        .from('purchases')
        .select('*, items(*)')
        .eq('employer_id', employerId)
        .order('purchase_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get all purchases
  static Future<List<Map<String, dynamic>>> getAllPurchases() async {
    final response = await _supabase
        .from('purchases')
        .select('*, users(name, email), items(item_name, price)')
        .order('purchase_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get purchases by date range
  static Future<List<Map<String, dynamic>>> getPurchasesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('purchases')
        .select('*, users(name), items(item_name)')
        .gte('purchase_date', startDate.toIso8601String())
        .lte('purchase_date', endDate.toIso8601String())
        .order('purchase_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get today's purchases
  static Future<List<Map<String, dynamic>>> getTodayPurchases() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await getPurchasesByDateRange(startOfDay, endOfDay);
  }

  // Get purchase statistics
  static Future<Map<String, dynamic>> getPurchaseStats() async {
    final response = await _supabase.rpc('get_purchase_stats');
    return response;
  }

  // ============ STORAGE ============

  // Upload product image
  static Future<String> uploadProductImage(
    String fileName,
    Uint8List fileBytes,
  ) async {
    final path = 'products/$fileName';
    await _supabase.storage
        .from('product-images')
        .uploadBinary(path, fileBytes);

    return _supabase.storage
        .from('product-images')
        .getPublicUrl(path);
  }

  // Upload profile image
  static Future<String> uploadProfileImage(
    String userId,
    String fileName,
    Uint8List fileBytes,
  ) async {
    final path = '$userId/$fileName';
    await _supabase.storage
        .from('profile-images')
        .uploadBinary(path, fileBytes);

    return _supabase.storage
        .from('profile-images')
        .getPublicUrl(path);
  }

  // Delete image from storage
  static Future<void> deleteImage(String bucket, String path) async {
    await _supabase.storage
        .from(bucket)
        .remove([path]);
  }
}