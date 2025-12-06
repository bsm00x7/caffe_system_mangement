class PurchasesModel {
  final String id;
  final String employerId;
  final int itemId;
  final String itemName; // Denormalized for easier display
  final int quantity;
  final double priceAtPurchase;
  final double totalAmount;
  final DateTime? purchaseDate;
  final DateTime? createdAt;

  PurchasesModel({
    required this.id,
    required this.employerId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.priceAtPurchase,
    required this.totalAmount,
    this.purchaseDate,
    this.createdAt,
  });

  // Factory constructor for creating from database JSON
  factory PurchasesModel.fromJson(Map<dynamic, dynamic> json) {
    return PurchasesModel(
      id: json['id'] as String,
      employerId: json['employer_id'] as String,
      itemId: json['item_id'] as int,
      itemName: json['items']?['item_name'] as String? ?? 'Unknown Item',
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['price_at_purchase'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // Convert to JSON for database insertion
  Map<String, dynamic> toJson() {
    return {
      'employer_id': employerId,
      'item_id': itemId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'total_amount': totalAmount,
      // purchase_date and created_at have default values in SQL
    };
  }

  // Formatted date for display
  String get formattedDate {
    if (purchaseDate == null) return 'N/A';
    return '${purchaseDate!.day}/${purchaseDate!.month}/${purchaseDate!.year} ${purchaseDate!.hour}:${purchaseDate!.minute.toString().padLeft(2, '0')}';
  }

  // Formatted price at purchase
  String get formattedPrice {
    return priceAtPurchase.toStringAsFixed(2);
  }

  // Formatted total amount
  String get formattedTotal {
    return totalAmount.toStringAsFixed(2);
  }
}
