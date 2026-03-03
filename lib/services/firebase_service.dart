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

  /// Cờ giả lập lỗi mạng (dùng để demo Error UI & Retry)
  static bool simulateNetworkError = false;

  /// Lấy toàn bộ danh sách sản phẩm từ Firestore
  Future<List<Product>> getProducts() async {
    if (simulateNetworkError) {
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Mất kết nối mạng (giả lập).\nVui lòng kiểm tra kết nối Internet và thử lại.');
    }
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
    if (simulateNetworkError) {
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Mất kết nối mạng (giả lập).\nVui lòng kiểm tra kết nối Internet và thử lại.');
    }
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
    if (simulateNetworkError) {
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Mất kết nối mạng (giả lập).\nVui lòng kiểm tra kết nối Internet và thử lại.');
    }
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
    if (simulateNetworkError) {
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Mất kết nối mạng (giả lập).\nVui lòng kiểm tra kết nối Internet và thử lại.');
    }
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
            'https://cdn.kkfashion.vn/38774-large_default/chan-vay-midi-xoe-hoa-nhi-mau-xanh-cv10-23.jpg',
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
            'https://product.hstatic.net/200000897463/product/ao_so_mi_nu_ke_soc_cong_so__05_2edb90847ed54df7b949f7ec7c307ca3_master.png',
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
            'https://heis.vn/storage/uploads/2020/06/20/5eee2a1da5e88.jpeg',
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
        'name': 'Váy Dự Tiệc Off-shoulder',
        'description':
            'Váy trễ vai sang trọng, phù hợp tiệc tùng và sự kiện. Chất liệu satin bóng mịn, đường may tinh tế.',
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
        'imageUrl': 'https://bizweb.dktcdn.net/100/393/859/products/15d5f4c5-99fd-4432-9995-1104211943f5.jpg?v=1646213264423',
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
      {
        'name': 'Áo Polo Nam Classic',
        'description':
            'Áo polo nam cổ bẻ cổ điển, chất liệu cotton piqué cao cấp thoáng mát. Phù hợp đi làm hoặc dạo phố.',
        'price': 280000,
        'originalPrice': 350000,
        'imageUrl':
            'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=400',
        'category': 'Áo',
        'brand': 'PoloStyle',
        'rating': 4.4,
        'reviewCount': 98,
        'stock': 45,
        'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
        'colors': ['Trắng', 'Xanh navy', 'Đen', 'Đỏ đô'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Quần Jogger Thể Thao',
        'description':
            'Quần jogger nam nữ thoải mái, chất liệu cotton co giãn 4 chiều. Phù hợp tập gym hoặc mặc nhà.',
        'price': 320000,
        'originalPrice': null,
        'imageUrl':
            'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?w=400',
        'category': 'Quần',
        'brand': 'SportZone',
        'rating': 4.6,
        'reviewCount': 183,
        'stock': 55,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Đen', 'Xám', 'Xanh rêu'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Váy Maxi Boho',
        'description':
            'Váy maxi dài họa tiết boho phong cách tự do, chất vải nhẹ bay bổng. Lý tưởng cho mùa hè và đi biển.',
        'price': 420000,
        'originalPrice': 550000,
        'imageUrl':
            'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=400',
        'category': 'Váy',
        'brand': 'BohoChic',
        'rating': 4.7,
        'reviewCount': 267,
        'stock': 20,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Vàng đất', 'Xanh lá', 'Cam đất'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Áo ba lỗ Nà Ná Na Na',
        'description':
            'Cảm ơn anh anh Độ Mixi.',
        'price': 99000,
        'originalPrice': 149000,
        'imageUrl':
            'https://product.hstatic.net/200000881795/product/ao-ba-lo-hi-anh-em-scaled_2a1e1143f0c94ee18ebbd2bca25551fc_1024x1024.jpg',
        'category': 'Áo',
        'brand': 'Nà Ná Na Na',
        'rating': 3.6,
        'reviewCount': 36,
        'stock': 36,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Đen'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Áo Khoác Denim Jacket',
        'description':
            'Áo khoác jeans unisex phong cách retro, denim wash nhẹ. Dễ phối đồ, phù hợp nhiều phong cách.',
        'price': 580000,
        'originalPrice': 720000,
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRC67Ri_D6VAFy09VTnMr5akUEyvVmW9YQKOA&s',
        'category': 'Áo khoác',
        'brand': 'DenimCo',
        'rating': 4.5,
        'reviewCount': 134,
        'stock': 18,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Xanh nhạt', 'Xanh đậm', 'Đen wash'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Áo Croptop Thể Thao',
        'description':
            'Áo croptop nữ chất liệu thun co giãn 4 chiều, thoát mồ hôi tốt. Phù hợp yoga, gym hoặc mặc hàng ngày.',
        'price': 185000,
        'originalPrice': null,
        'imageUrl':
            'https://deltasport.vn/wp-content/uploads/2025/09/TS228W0-ao-croptop-nu-269K-2.png',
        'category': 'Áo',
        'brand': 'FitGirl',
        'rating': 4.3,
        'reviewCount': 312,
        'stock': 60,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đen', 'Trắng', 'Hồng', 'Tím'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Quần Culottes Lưng Cao',
        'description':
            'Quần culottes ống rộng lưng cao thanh lịch, chất vải tuyết mưa nhẹ. Tôn dáng, phù hợp đi làm và dạo phố.',
        'price': 360000,
        'originalPrice': 450000,
        'imageUrl':
            'https://bizweb.dktcdn.net/thumb/1024x1024/100/403/511/products/o1cn015jijff25yywurjsi32788097.jpg',
        'category': 'Quần',
        'brand': 'LadyChic',
        'rating': 4.6,
        'reviewCount': 89,
        'stock': 25,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đen', 'Be', 'Xanh cobalt'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Váy Wrap Floral',
        'description':
            'Váy wrap cổ chéo họa tiết hoa rực rỡ, chất vải voan mềm nhẹ. Tôn dáng và nữ tính cho mọi dịp.',
        'price': 490000,
        'originalPrice': null,
        'imageUrl':
            'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400',
        'category': 'Váy',
        'brand': 'FloralMuse',
        'rating': 4.8,
        'reviewCount': 201,
        'stock': 15,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Hoa hồng đỏ', 'Hoa xanh', 'Hoa vàng'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Áo Khoác Blazer Nữ',
        'description':
            'Blazer nữ dáng ôm thanh lịch, chất liệu polyester cao cấp không nhăn. Hoàn hảo cho công sở hay sự kiện.',
        'price': 720000,
        'originalPrice': 900000,
        'imageUrl':
            'https://cdn.kkfashion.vn/31030-large_default/ao-khoac-blazer-nu-cong-so-mau-kem-ak12-16.jpg',
        'category': 'Áo khoác',
        'brand': 'OfficePro',
        'rating': 4.9,
        'reviewCount': 156,
        'stock': 12,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'colors': ['Đen', 'Trắng kem', 'Camel'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Áo Len Cổ Lọ Mỏng',
        'description':
            'Áo len cổ lọ mỏng unisex phong cách tối giản Hàn Quốc. Mềm mịn, giữ ấm nhẹ, dễ phối với mọi trang phục.',
        'price': 245000,
        'originalPrice': 310000,
        'imageUrl':
            'https://namfashion.com/home/wp-content/uploads/2024/11/ao-len-nam-co-lo-zara-cao-cap-xuat-khau-ha-noi-16.jpg',
        'category': 'Áo',
        'brand': 'KoreanTrend',
        'rating': 4.5,
        'reviewCount': 178,
        'stock': 40,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Kem', 'Đen', 'Nâu caramel', 'Xám nhạt'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Quần Cargo Túi Hộp',
        'description':
            'Quần cargo nhiều túi phong cách streetwear, chất kaki dày dặn. Cá tính, thoải mái cho mọi hoạt động.',
        'price': 410000,
        'originalPrice': null,
        'imageUrl':
            'https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSMCQiDrvGon8V1pp8zF2DgsQCfTDWqt1Ul_wOF4iY_O1bihmYHypd9CNX7EkoRb6wLcEiQywETUSZvZXYnnrX1F4kI8EplzifBK-NCOjPGP_bgsXy9m1rIHcBKq7-lnJzuYJ2HjDI&usqp=CAc',
        'category': 'Quần',
        'brand': 'StreetKing',
        'rating': 4.4,
        'reviewCount': 95,
        'stock': 30,
        'sizes': ['28', '30', '32', '34', '36'],
        'colors': ['Đen', 'Rêu quân đội', 'Be'],
        'isNew': false,
        'isSale': false,
      },
      {
        'name': 'Chân Váy Chữ A Kẻ Caro',
        'description':
            'Váy chữ A họa tiết kẻ caro vintage, dài qua gối. Chất vải tweed dày dặn, ấm áp phù hợp thời tiết se lạnh.',
        'price': 345000,
        'originalPrice': 420000,
        'imageUrl':
            'https://247store.vn/uploads/products/20201208/z22158178822994491bc7d3f2d2ae6fb06883a43bb65e1.jpg',
        'category': 'Váy',
        'brand': 'VintageChic',
        'rating': 4.7,
        'reviewCount': 143,
        'stock': 22,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đen trắng', 'Đỏ trắng', 'Xanh trắng'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Váy Midi Linen Tối Giản',
        'description':
            'Váy midi chất linen tự nhiên thoáng mát, kiểu dáng tối giản Scandinavian. Phù hợp đi làm, cà phê hay dạo phố.',
        'price': 520000,
        'originalPrice': null,
        'imageUrl':
            'https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcQcGEOI311e1R7ffYLWG9rlf9n1zNcNoRxPEiqMfCTs0eNcjEXu8e_x8SxVMaMeb-tvQ0Go56b-eK2xO-WF3OyhiiWwXD9yUDgu_rJvTe4oDZsK5D1Ef7zIe33fMLDPr2RGEqepvbJ0WWGBFdc&usqp=CAc',
        'category': 'Váy',
        'brand': 'NaturalMuse',
        'rating': 4.8,
        'reviewCount': 218,
        'stock': 18,
        'sizes': ['XS', 'S', 'M', 'L', 'XL'],
        'colors': ['Be tự nhiên', 'Trắng sữa', 'Xanh bạc hà'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Váy Pleated Xếp Ly',
        'description':
            'Váy xếp ly midi dáng xòe nhẹ, chất vải satin bóng nhẹ. Tôn dáng, phù hợp đi tiệc hoặc date.',
        'price': 395000,
        'originalPrice': 490000,
        'imageUrl':
            'https://bizweb.dktcdn.net/100/518/724/products/img-4175-2-min.jpg?v=1728273901043',
        'category': 'Váy',
        'brand': 'EleganceVN',
        'rating': 4.6,
        'reviewCount': 176,
        'stock': 20,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Hồng phấn', 'Bạc', 'Xanh ánh kim'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Váy Ren Hai Dây',
        'description':
            'Váy ren hai dây gợi cảm, phối lớp lót trong mềm mịn. Thiết kế tinh tế phù hợp buổi tối và dịp đặc biệt.',
        'price': 460000,
        'originalPrice': null,
        'imageUrl':
            'https://cdn.kkfashion.vn/26212-large_default/dam-ren-hai-day-du-tiec-mau-trang-kem-kk163-31.jpg',
        'category': 'Váy',
        'brand': 'NightGlow',
        'rating': 4.9,
        'reviewCount': 334,
        'stock': 12,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đen', 'Trắng kem', 'Đỏ merlot'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Chân Váy Denim Mini',
        'description':
            'Chân Váy denim mini phong cách Y2K, cạp cao tôn vóc dáng. Chất jeans co giãn nhẹ, dễ phối với áo thun hay áo sơ mi.',
        'price': 275000,
        'originalPrice': 340000,
        'imageUrl':
            'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcRfsJqEy8SaYGerwrRyZkInhnTdLHX_1M-fnmDhFiPo3ckcve0O2YyrlrJQQZubZkSv_ljb7dUtkMN7UPCdsttBskRHk-NE7D3Mq2w8lQC6Hf6HBWKA4BsGGz8d1WTlzN4F09VdopoAJRM&usqp=CAc',
        'category': 'Váy',
        'brand': 'Y2KVibes',
        'rating': 4.5,
        'reviewCount': 289,
        'stock': 35,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Xanh nhạt', 'Xanh đậm', 'Trắng wash'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Váy Babydoll Ngắn',
        'description':
            'Váy babydoll tay bồng ngắn, chất vải voan mềm nhẹ có lớp lót. Dáng A tôn dáng, nữ tính và dễ thương.',
        'price': 310000,
        'originalPrice': null,
        'imageUrl':
            'https://product.hstatic.net/200000588835/product/d2011-2_29476443aa454fe098e28ab7a5363f7d_master.jpg',
        'category': 'Váy',
        'brand': 'CutieWear',
        'rating': 4.6,
        'reviewCount': 157,
        'stock': 28,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Trắng', 'Hồng nhạt', 'Vàng pastel', 'Xanh baby'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Váy Slip Dress Lụa',
        'description':
            'Váy slip dress chất lụa mềm mượt, dáng suôn thanh lịch. Có thể mặc ngoài hoặc layering cùng áo khoác.',
        'price': 580000,
        'originalPrice': 720000,
        'imageUrl':
            'https://alashanghai-silk.myshopify.com/cdn/shop/products/nude-pink-pure-mulberry-silk-slip-dress-496013.jpg?v=1635754400',
        'category': 'Váy',
        'brand': 'SilkMuse',
        'rating': 4.8,
        'reviewCount': 203,
        'stock': 15,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Champagne', 'Đen', 'Nude pink'],
        'isNew': false,
        'isSale': true,
      },
      {
        'name': 'Chân Váy Maxi Tầng',
        'description':
            'Chân Váy maxi nhiều tầng bồng bềnh, chất vải voan nhẹ. Bay bổng và nữ tính, phù hợp mọi dáng người.',
        'price': 430000,
        'originalPrice': null,
        'imageUrl':
            'https://yvle.co/wp-content/uploads/2024/04/mango41303-copy-scaled.jpg',
        'category': 'Váy',
        'brand': 'FloralMuse',
        'rating': 4.7,
        'reviewCount': 121,
        'stock': 17,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['Trắng', 'Hồng peach', 'Xanh coban'],
        'isNew': true,
        'isSale': false,
      },
      {
        'name': 'Váy Cổ Vuông Tay Phồng',
        'description':
            'Váy cổ vuông tay phồng phong cách cottagecore, vải cotton mềm mịn. Duyên dáng và lãng mạn cho mọi hoàn cảnh.',
        'price': 385000,
        'originalPrice': 470000,
        'imageUrl':
            'https://cdn.kkfashion.vn/18515-large_default/dam-trang-dang-xoe-co-vuong-tay-phong-kk119-08.jpg',
        'category': 'Váy',
        'brand': 'CottageCore',
        'rating': 4.9,
        'reviewCount': 412,
        'stock': 24,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Trắng hoa nhỏ', 'Vàng hoa nhí', 'Xanh sage'],
        'isNew': true,
        'isSale': true,
      },
      {
        'name': 'Váy Bodycon Ôm Dáng',
        'description':
            'Váy bodycon ôm sát chất liệu thun co giãn 4 chiều, tôn đường cong. Phù hợp đi tiệc, bar hoặc buổi tối.',
        'price': 295000,
        'originalPrice': null,
        'imageUrl':
            'https://cdn.kkfashion.vn/25595-large_default/dam-di-tiec-dang-om-body-sat-nach-kk162-06.jpg',
        'category': 'Váy',
        'brand': 'NightGlow',
        'rating': 4.5,
        'reviewCount': 278,
        'stock': 30,
        'sizes': ['XS', 'S', 'M', 'L'],
        'colors': ['Đen', 'Đỏ', 'Xanh cobalt', 'Hồng fuchsia'],
        'isNew': false,
        'isSale': false,
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

  /// Xóa một sản phẩm theo ID
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection(_collection).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi xóa sản phẩm: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể xóa sản phẩm.');
    }
  }

  /// Xóa toàn bộ sản phẩm trong collection
  Future<void> deleteAllProducts() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi xóa toàn bộ: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể xóa toàn bộ sản phẩm.');
    }
  }
}
