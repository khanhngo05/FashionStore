import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

/// Service chịu trách nhiệm giao tiếp với Firebase Firestore
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'products';

  /// Lấy toàn bộ danh sách sản phẩm từ Firestore
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
    }
  }

  /// Lấy sản phẩm theo danh mục
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
    }
  }

  /// Lấy sản phẩm mới nhất (isNew = true)
  Future<List<Product>> getNewArrivals() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('isNew', isEqualTo: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
    }
  }

  /// Lấy sản phẩm đang giảm giá (isSale = true)
  Future<List<Product>> getSaleProducts() async {
    try {
      final QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('isSale', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi Firebase: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
    }
  }

  /// Thêm dữ liệu mẫu vào Firestore (dùng để seed data lần đầu)
  Future<void> seedSampleData() async {
    final sampleProducts = [
      {
        'name': 'Áo Thun Basic Cotton',
        'description':
            'Áo thun basic chất liệu cotton 100%, thoáng mát và thoải mái cho ngày hè. Thiết kế đơn giản phù hợp nhiều phong cách.',
        'price': 199000,
        'originalPrice': 299000,
        'imageUrl':
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
        'category': 'Áo',
        'brand': 'FashionStore Basic',
        'rating': 4.5,
        'reviewCount': 128,
        'stock': 50,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Trắng', 'Đen', 'Xám'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Quần Jean Slim Fit',
        'description':
            'Quần jean nam dáng slim fit, chất liệu denim co giãn 4 chiều. Phù hợp cả đi làm lẫn đi chơi.',
        'price': 450000,
        'originalPrice': 600000,
        'imageUrl':
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400',
        'category': 'Quần',
        'brand': 'UrbanStyle',
        'rating': 4.3,
        'reviewCount': 89,
        'stock': 30,
        'sizes': ['28', '30', '32', '34'],
        'colors': ['Xanh đậm', 'Xanh nhạt', 'Đen'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Váy Hoa Nhí Midi',
        'description':
            'Váy midi họa tiết hoa nhí nữ tính, dáng A thanh lịch. Chất liệu vải nhẹ, thoáng mát.',
        'price': 380000,
        'originalPrice': null,
        'imageUrl':
            'https://images.unsplash.com/photo-1572804013427-4d7ca7268217?w=400',
        'category': 'Váy',
        'brand': 'LadyChic',
        'rating': 4.7,
        'reviewCount': 214,
        'stock': 25,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Hồng', 'Xanh pastel', 'Trắng'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Áo Khoác Bomber',
        'description':
            'Áo khoác bomber unisex phong cách streetwear. Chất liệu polyester chống gió nhẹ, có túi hai bên tiện lợi.',
        'price': 650000,
        'originalPrice': 850000,
        'imageUrl':
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        'category': 'Áo khoác',
        'brand': 'StreetKing',
        'rating': 4.6,
        'reviewCount': 156,
        'stock': 15,
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'colors': ['Đen', 'Rêu', 'Kem'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Áo Sơ Mi Kẻ Sọc',
        'description':
            'Áo sơ mi nam kẻ sọc classic, vải cotton blend thoáng mát. Phù hợp đi làm văn phòng hoặc dạo phố.',
        'price': 320000,
        'originalPrice': null,
        'imageUrl':
            'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400',
        'category': 'Áo',
        'brand': 'OfficePro',
        'rating': 4.2,
        'reviewCount': 73,
        'stock': 40,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Xanh trắng', 'Đen trắng'],
        'isNew': false,
        'isSale': false,
      },
      {
        'name': 'Quần Short Kaki',
        'description':
            'Quần short kaki nam thoải mái cho ngày hè. Chất liệu kaki co giãn nhẹ, đường may chắc chắn.',
        'price': 250000,
        'originalPrice': 320000,
        'imageUrl':
            'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400',
        'category': 'Quần',
        'brand': 'FashionStore Basic',
        'rating': 4.1,
        'reviewCount': 45,
        'stock': 60,
        'sizes': ['28', '30', '32', '34', '36'],
        'colors': ['Nâu', 'Xanh lá', 'Đen'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Đầm Dự Tiệc Off-shoulder',
        'description':
            'Đầm trễ vai sang trọng, phù hợp tiệc tùng và sự kiện. Chất liệu satin bóng mịn, đường may tinh tế.',
        'price': 780000,
        'originalPrice': null,
        'imageUrl':
            'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400',
        'category': 'Váy',
        'brand': 'EleganceVN',
        'rating': 4.9,
        'reviewCount': 302,
        'stock': 10,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đỏ wine', 'Đen', 'Vàng gold'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Áo Hoodie Oversized',
        'description':
            'Hoodie oversized unisex phong cách Hàn Quốc. Chất liệu nỉ bông dày dặn, ấm áp mùa lạnh.',
        'price': 420000,
        'originalPrice': 520000,
        'imageUrl':
            'https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=400',
        'category': 'Áo',
        'brand': 'KoreanTrend',
        'rating': 4.8,
        'reviewCount': 421,
        'stock': 35,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Hồng', 'Xanh baby', 'Trắng', 'Đen'],
        'isNew': true,
        'isSale': true,
      },
    ];

    final batch = _db.batch();
    for (final product in sampleProducts) {
      final ref = _db.collection(_collection).doc();
      batch.set(ref, product);
    }

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi khi seed data: ${e.message}');
    }
  }
}
