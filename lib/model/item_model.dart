class ItemModel {
  final int id;
  final String item_name;
  final String? image;
  final int stock ;
  final double price;

  ItemModel({
    required this.id,
    this.image,
    required this.item_name,
     this.stock =0,
    this.price = 0.0, // Default price
  });

  factory ItemModel.toItemModel(Map<dynamic, dynamic> map) {
    return ItemModel(
      id: map['id'] as int,
      image: map['image'] as String?,
      item_name: map['item_name'] as String,
      stock: map['stock'] as int,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id,
      'item_name': item_name,
      'image': image,
      'stock': stock,
      'price': price,
    };
  }
}
