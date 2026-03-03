/// Model đại diện cho một mục trong đơn hàng
class OrderItem {
  final String productId;
  final String productName;
  final String productBrand;
  final String imageUrl;
  final double price;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'productBrand': productBrand,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId: map['productId'] ?? '',
        productName: map['productName'] ?? '',
        productBrand: map['productBrand'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        price: (map['price'] ?? 0).toDouble(),
        quantity: (map['quantity'] ?? 1).toInt(),
        selectedSize: map['selectedSize'],
        selectedColor: map['selectedColor'],
      );
}

/// Model đại diện cho một đơn hàng
class Order {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final DateTime createdAt;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    this.status = 'Đã xác nhận',
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  Map<String, dynamic> toMap() => {
        'items': items.map((i) => i.toMap()).toList(),
        'totalPrice': totalPrice,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
      };

  factory Order.fromFirestore(Map<String, dynamic> data, String id) => Order(
        id: id,
        items: (data['items'] as List<dynamic>? ?? [])
            .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        totalPrice: (data['totalPrice'] ?? 0).toDouble(),
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
        status: data['status'] ?? 'Đã xác nhận',
      );
}
