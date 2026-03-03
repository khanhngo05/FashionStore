// Model định nghĩa sản phẩm thời trang
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final int stock;
  final List<String> sizes;
  final List<String> colors;
  final bool isNew;
  final bool isSale;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.sizes = const [],
    this.colors = const [],
    this.isNew = false,
    this.isSale = false,
  });

  /// Tạo Product từ dữ liệu Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? 'Không có tên',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['originalPrice'] != null
          ? (data['originalPrice']).toDouble()
          : null,
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Khác',
      brand: data['brand'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      stock: (data['stock'] ?? 0).toInt(),
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      isNew: data['isNew'] ?? false,
      isSale: data['isSale'] ?? false,
    );
  }

  /// Chuyển Product thành Map để lưu lên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'sizes': sizes,
      'colors': colors,
      'isNew': isNew,
      'isSale': isSale,
    };
  }

  /// Tính phần trăm giảm giá
  int? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return (((originalPrice! - price) / originalPrice!) * 100).round();
    }
    return null;
  }
}
