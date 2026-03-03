# FashionStore — Ứng dụng Thương Mại Điện Tử Thời Trang

> **Môn học:** Phát triển Ứng dụng Đa Nền Tảng (PTUDDD)
> **Bài thực hành:** TH3
> **Sinh viên:** Ngô Xuân Khánh — MSSV: 2351060453

---

## Mục lục

1. [Giới thiệu](#1-giới-thiệu)
2. [Tổng quan tính năng](#2-tổng-quan-tính-năng)
3. [Công nghệ sử dụng](#3-công-nghệ-sử-dụng)
4. [Cấu trúc dự án](#4-cấu-trúc-dự-án)
5. [Mô hình dữ liệu (Models)](#5-mô-hình-dữ-liệu-models)
6. [Tầng Service — Mô tả chi tiết các hàm](#6-tầng-service--mô-tả-chi-tiết-các-hàm)
7. [Tầng Screen — Mô tả chi tiết các màn hình](#7-tầng-screen--mô-tả-chi-tiết-các-màn-hình)
8. [Cấu trúc dữ liệu Firestore](#8-cấu-trúc-dữ-liệu-firestore)
9. [Kiến trúc & Luồng xử lý](#9-kiến-trúc--luồng-xử-lý)
10. [Firestore Rules](#10-firestore-rules)
11. [Cài đặt & Chạy dự án](#11-cài-đặt--chạy-dự-án)
12. [Hướng dẫn sử dụng](#12-hướng-dẫn-sử-dụng)
13. [Ghi chú kỹ thuật](#13-ghi-chú-kỹ-thuật)

---

## 1. Giới thiệu

**FashionStore** là ứng dụng thương mại điện tử thời trang được xây dựng bằng **Flutter** và **Dart**, sử dụng **Firebase Cloud Firestore** làm cơ sở dữ liệu NoSQL thời gian thực. Ứng dụng được thiết kế theo mô hình **Singleton Service + ChangeNotifier**, giúp tách biệt rõ ràng giữa tầng giao diện (UI), tầng xử lý nghiệp vụ (Service) và tầng dữ liệu (Firestore).

**Mục tiêu bài thực hành:** Xây dựng một ứng dụng đa nền tảng (Android, iOS, Web, Windows) hoàn chỉnh với đầy đủ luồng mua sắm: duyệt sản phẩm → thêm giỏ / mua ngay → đặt hàng → xem lịch sử, kèm trang quản trị ẩn cho admin.

---

## 2. Tổng quan tính năng

### 2.1 Phía người dùng

| # | Tính năng | Mô tả ngắn |
|---|-----------|------------|
| 1 | Danh sách sản phẩm | GridView 2 cột, pull-to-refresh, lọc danh mục |
| 2 | Tìm kiếm nâng cao | Real-time, lọc danh mục, sắp xếp theo giá/đánh giá |
| 3 | Chi tiết sản phẩm | Ảnh, mô tả, size, màu, số lượng, tồn kho |
| 4 | Thêm vào giỏ hàng | Kèm size/màu, badge giỏ cập nhật ngay |
| 5 | **Mua ngay** | Dialog xác nhận → đặt hàng trực tiếp không qua giỏ |
| 6 | Giỏ hàng | Tăng/giảm số lượng, xóa mục, xóa toàn bộ |
| 7 | **Đặt hàng (Batch Write)** | Lưu đơn + trừ tồn kho nguyên tử trên Firestore |
| 8 | **Lịch sử đơn hàng** | Danh sách đơn, chi tiết từng đơn (ExpansionTile) |
| 9 | **Tự động reload** | Màn hình chính reload tồn kho sau khi thanh toán |
| 10 | **Error UI & Retry** | Màn hình lỗi + nút "Thử lại" khi mất kết nối |
| 11 | **Giả lập mất mạng** | Nút WiFi trên AppBar bật/tắt lỗi để demo |
| 12 | Seed dữ liệu | Thêm 28 sản phẩm mẫu vào Firestore khi DB trống |

### 2.2 Phía Admin (truy cập ẩn)

| # | Tính năng | Mô tả ngắn |
|---|-----------|------------|
| 1 | Truy cập ẩn | Nhấn 5 lần liên tiếp vào tiêu đề "FashionStore" |
| 2 | Xem toàn bộ sản phẩm | Danh sách kèm thống kê: tổng / mới / sale |
| 3 | Thêm sản phẩm | Form đầy đủ với validation |
| 4 | Sửa sản phẩm | Form pre-filled với dữ liệu hiện tại |
| 5 | Xóa từng sản phẩm | Có dialog xác nhận trước khi xóa |
| 6 | **Xóa toàn bộ (Cascade)** | Xóa sản phẩm + lịch sử đơn hàng + giỏ hàng |

---

## 3. Công nghệ sử dụng

| Công nghệ | Phiên bản | Vai trò |
|-----------|-----------|---------|
| **Flutter** | SDK ^3.10.7 | Framework UI đa nền tảng |
| **Dart** | ^3.x | Ngôn ngữ lập trình |
| **Firebase Core** | ^3.13.0 | Khởi tạo kết nối Firebase |
| **Cloud Firestore** | ^5.6.6 | Database NoSQL real-time |
| **cached_network_image** | ^3.4.1 | Cache ảnh sản phẩm từ URL |
| **shimmer** | ^3.0.0 | Hiệu ứng skeleton khi đang tải |
| **Material Design 3** | — | Hệ thống thiết kế UI hiện đại |

---

## 4. Cấu trúc dự án

```
FashionStore/
├── lib/
│   ├── main.dart                          # Điểm vào: khởi tạo Firebase, chạy app
│   ├── firebase_options.dart              # Cấu hình Firebase theo platform
│   │
│   ├── models/                            # Các lớp dữ liệu (data classes)
│   │   ├── product.dart                   # Model sản phẩm
│   │   ├── cart_item.dart                 # Model mục trong giỏ hàng
│   │   └── order.dart                     # Model đơn hàng & mục đơn hàng
│   │
│   ├── services/                          # Tầng xử lý nghiệp vụ & Firestore
│   │   ├── firebase_service.dart          # CRUD sản phẩm, seed data, giả lập lỗi
│   │   ├── cart_service.dart              # Quản lý giỏ hàng (in-memory)
│   │   └── order_service.dart             # Đặt hàng, lịch sử, xóa lịch sử
│   │
│   ├── screens/                           # Các màn hình chính
│   │   ├── home_screen.dart               # Màn hình chính
│   │   ├── product_detail_screen.dart     # Chi tiết sản phẩm
│   │   ├── search_screen.dart             # Tìm kiếm
│   │   ├── cart_screen.dart               # Giỏ hàng & thanh toán
│   │   ├── order_history_screen.dart      # Lịch sử đơn hàng
│   │   ├── admin_screen.dart              # Trang quản trị (ẩn)
│   │   └── add_edit_product_screen.dart   # Form thêm/sửa sản phẩm
│   │
│   └── widgets/                           # Widget tái sử dụng
│       ├── product_card.dart              # Card sản phẩm trong GridView
│       └── app_error_widget.dart          # Widget lỗi + nút Thử lại
│
├── firestore.rules                        # Quy tắc bảo mật Firestore
├── firebase.json                          # Cấu hình Firebase CLI
└── pubspec.yaml                           # Dependencies & assets
```

---

## 5. Mô hình dữ liệu (Models)

### 5.1 `Product` — `lib/models/product.dart`

Đại diện cho một sản phẩm thời trang trên Firestore.

```dart
class Product {
  final String id;            // ID document Firestore (tự sinh)
  final String name;          // Tên sản phẩm
  final String description;   // Mô tả chi tiết
  final double price;         // Giá bán hiện tại (VNĐ)
  final double? originalPrice;// Giá gốc trước khi giảm (nullable)
  final String imageUrl;      // URL ảnh sản phẩm (thường từ Unsplash)
  final String category;      // Danh mục: "Áo" | "Quần" | "Váy" | "Áo khoác" | "Khác"
  final String brand;         // Thương hiệu
  final double rating;        // Điểm đánh giá trung bình (0.0 – 5.0)
  final int reviewCount;      // Số lượt đánh giá
  final int stock;            // Tồn kho (giảm tự động khi đặt hàng)
  final List<String> sizes;   // Danh sách size: ["S", "M", "L", "XL"]
  final List<String> colors;  // Danh sách màu: ["Đen", "Trắng", "Xanh"]
  final bool isNew;           // true → hiển thị nhãn "MỚI"
  final bool isSale;          // true → hiển thị nhãn "-X%"
  final int? discountPercent; // Phần trăm giảm (nullable, dùng khi isSale = true)
}
```

**Factory constructor quan trọng:**

```dart
// Chuyển dữ liệu từ Firestore Map sang đối tượng Product
factory Product.fromFirestore(Map<String, dynamic> data, String id)

// Chuyển đối tượng Product sang Map để lưu lên Firestore
Map<String, dynamic> toFirestore()
```

---

### 5.2 `CartItem` — `lib/models/cart_item.dart`

Đại diện cho một mục trong giỏ hàng (lưu trong bộ nhớ, không lên Firestore).

```dart
class CartItem {
  final Product product;      // Sản phẩm được thêm vào
  final String? selectedSize; // Size đã chọn (nullable nếu SP không có size)
  final String? selectedColor;// Màu đã chọn (nullable nếu SP không có màu)
  int quantity;               // Số lượng (giới hạn bởi product.stock)

  // Tính tổng tiền của mục này
  double get totalPrice => product.price * quantity;

  // Key duy nhất để phân biệt cùng sản phẩm nhưng khác size/màu
  // Ví dụ: "abc123_M_Đen" — nếu thêm lại cùng key thì tăng số lượng
  String get uniqueKey => '${product.id}_${selectedSize ?? ""}_${selectedColor ?? ""}';
}
```

---

### 5.3 `Order` & `OrderItem` — `lib/models/order.dart`

`OrderItem` lưu thông tin sản phẩm **tại thời điểm đặt hàng** (để phòng trường hợp giá/tên sản phẩm thay đổi sau này).

```dart
class OrderItem {
  final String productId;     // Tham chiếu đến products/{id}
  final String productName;   // Chụp lại tên tại thời điểm đặt
  final String productBrand;  // Chụp lại thương hiệu
  final String imageUrl;      // Chụp lại URL ảnh
  final double price;         // Chụp lại đơn giá
  final int quantity;         // Số lượng đặt
  final String? selectedSize; // Size đã chọn
  final String? selectedColor;// Màu đã chọn

  double get totalPrice => price * quantity; // Tính thành tiền
}

class Order {
  final String id;            // ID document Firestore (tự sinh bởi orderRef.id)
  final List<OrderItem> items;// Danh sách sản phẩm trong đơn
  final double totalPrice;    // Tổng tiền (tính bằng fold trên items)
  final DateTime createdAt;   // Thời điểm đặt hàng
  final String status;        // Trạng thái: "Đã xác nhận"
}
```

---

## 6. Tầng Service — Mô tả chi tiết các hàm

### 6.1 `FirebaseService` — `lib/services/firebase_service.dart`

Singleton — chỉ tạo một instance duy nhất trong suốt vòng đời app.

```dart
class FirebaseService {
  // Singleton pattern: đảm bảo chỉ 1 instance tồn tại
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance; // Mọi nơi gọi FirebaseService() đều trả về cùng object
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collection = 'products'; // tên collection Firestore

  // Cờ giả lập lỗi mạng — dùng để demo tính năng Error UI & Retry
  static bool simulateNetworkError = false;
}
```

**Các hàm chính:**

#### `getProducts()` — Lấy toàn bộ sản phẩm

```dart
Future<List<Product>> getProducts() async {
  // Nếu đang giả lập lỗi: chờ 800ms rồi ném exception
  if (simulateNetworkError) {
    await Future.delayed(const Duration(milliseconds: 800));
    throw Exception('Mất kết nối mạng (giả lập)...');
  }
  // Truy vấn Firestore, sắp xếp theo tên A-Z
  final snapshot = await _db.collection(_collection).orderBy('name').get();
  // Ánh xạ từng document sang đối tượng Product
  return snapshot.docs.map((doc) =>
    Product.fromFirestore(doc.data(), doc.id)
  ).toList();
}
```

#### `getProductsByCategory(category)` — Lọc theo danh mục

```dart
Future<List<Product>> getProductsByCategory(String category) async {
  // Dùng where để lọc field 'category' bằng với tham số
  final snapshot = await _db
    .collection(_collection)
    .where('category', isEqualTo: category)
    .get();
  return snapshot.docs.map(...).toList();
}
```

#### `searchProducts(keyword)` — Tìm kiếm sản phẩm

```dart
Future<List<Product>> searchProducts(String keyword) async {
  // Firestore không hỗ trợ full-text search → lấy toàn bộ rồi lọc client-side
  final all = await getProducts();
  final lower = keyword.toLowerCase();
  return all.where((p) =>
    p.name.toLowerCase().contains(lower) ||
    p.brand.toLowerCase().contains(lower) ||
    p.category.toLowerCase().contains(lower) ||
    p.description.toLowerCase().contains(lower)
  ).toList();
}
```

#### `addProduct(product)` / `updateProduct(id, product)` — Thêm/sửa sản phẩm

```dart
Future<void> addProduct(Product product) async {
  // Dùng add() → Firestore tự sinh ID
  await _db.collection(_collection).add(product.toFirestore());
}

Future<void> updateProduct(String id, Product product) async {
  // Dùng doc(id).update() → chỉ cập nhật các field có trong map
  await _db.collection(_collection).doc(id).update(product.toFirestore());
}
```

#### `deleteProduct(productId)` — Xóa một sản phẩm

```dart
Future<void> deleteProduct(String productId) async {
  await _db.collection(_collection).doc(productId).delete();
}
```

#### `deleteAllProducts()` — Xóa toàn bộ sản phẩm (Batch)

```dart
Future<void> deleteAllProducts() async {
  final snapshot = await _db.collection(_collection).get();
  final batch = _db.batch();
  // Đánh dấu từng document để xóa trong một batch
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  // Thực thi tất cả lệnh xóa trong một lần gọi duy nhất (nguyên tử)
  await batch.commit();
}
```

#### `seedSampleData()` — Thêm dữ liệu mẫu

```dart
Future<void> seedSampleData() async {
  // Kiểm tra: chỉ seed nếu collection đang trống
  final existing = await _db.collection(_collection).limit(1).get();
  if (existing.docs.isNotEmpty) return;

  // Danh sách 28 sản phẩm mẫu (áo, quần, váy, áo khoác)
  final products = [ /* ... 28 sản phẩm ... */ ];

  // Dùng batch để thêm tất cả cùng lúc (hiệu quả hơn thêm từng cái)
  final batch = _db.batch();
  for (final p in products) {
    final ref = _db.collection(_collection).doc();
    batch.set(ref, p);
  }
  await batch.commit();
}
```

---

### 6.2 `CartService` — `lib/services/cart_service.dart`

Singleton + **ChangeNotifier** — quản lý giỏ hàng trong bộ nhớ. Khi thay đổi, tự động thông báo cho các widget đang lắng nghe (cập nhật badge giỏ hàng).

```dart
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = []; // Danh sách nội bộ (private)
}
```

**Các hàm chính:**

#### `addItem(product, {size, color, quantity})` — Thêm vào giỏ

```dart
void addItem(Product product, {String? size, String? color, int quantity = 1}) {
  // Tạo key duy nhất để nhận diện "cùng sản phẩm + cùng size + cùng màu"
  final key = '${product.id}_${size ?? ""}_${color ?? ""}';
  final existingIndex = _items.indexWhere((i) => i.uniqueKey == key);

  if (existingIndex >= 0) {
    // Sản phẩm đã có trong giỏ với cùng size/màu → chỉ tăng số lượng
    // clamp(1, stock): không được vượt quá tồn kho
    final newQty = (existing.quantity + quantity).clamp(1, product.stock);
    _items[existingIndex] = existing.copyWith(quantity: newQty);
  } else {
    // Chưa có → thêm mới vào danh sách
    _items.add(CartItem(product, selectedSize: size, ...));
  }
  notifyListeners(); // Thông báo cho ListenableBuilder rebuild (badge AppBar)
}
```

#### `removeItem(uniqueKey)` — Xóa một mục

```dart
void removeItem(String uniqueKey) {
  _items.removeWhere((i) => i.uniqueKey == uniqueKey);
  notifyListeners(); // Badge giỏ tự cập nhật
}
```

#### `updateQuantity(uniqueKey, quantity)` — Đổi số lượng

```dart
void updateQuantity(String uniqueKey, int quantity) {
  if (quantity <= 0) {
    _items.removeAt(index); // Nếu số lượng = 0, xóa luôn mục đó
  } else {
    final maxQty = item.product.stock;
    _items[index] = item.copyWith(quantity: quantity.clamp(1, maxQty));
  }
  notifyListeners();
}
```

#### `clear()` — Xóa toàn bộ giỏ

```dart
void clear() {
  _items.clear();
  notifyListeners(); // Badge về 0
}
```

**Các getter tiện ích:**

```dart
List<CartItem> get items       => List.unmodifiable(_items); // Không sửa được từ ngoài
int    get totalItemCount      => _items.fold(0, (s, i) => s + i.quantity); // Tổng số lượng
double get totalPrice          => _items.fold(0, (s, i) => s + i.totalPrice); // Tổng tiền
bool   get isEmpty             => _items.isEmpty;
```

---

### 6.3 `OrderService` — `lib/services/order_service.dart`

Singleton — xử lý toàn bộ luồng đặt hàng và lịch sử đơn hàng trên Firestore.

> **Lưu ý import:** `import 'package:cloud_firestore/cloud_firestore.dart' hide Order;`  
> Cần `hide Order` vì Firestore cũng export một class tên `Order` gây xung đột tên với model của mình.

**Các hàm chính:**

#### `placeOrder(cartItems)` — Đặt hàng (Batch Write nguyên tử)

```dart
Future<Order> placeOrder(List<CartItem> cartItems) async {
  if (cartItems.isEmpty) throw Exception('Giỏ hàng trống');

  // 1. Tạo tham chiếu document mới (chưa lưu, chỉ lấy ID trước)
  final orderRef = _db.collection('orders').doc();

  // 2. Tính tổng tiền bằng fold
  final double total = cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // 3. Chuyển CartItem → OrderItem (chụp lại thông tin tại thời điểm đặt)
  final orderItems = cartItems.map((ci) => OrderItem(
    productId: ci.product.id,
    productName: ci.product.name, // Lưu tên SP vào đơn để không bị ảnh hưởng nếu SP đổi tên sau
    price: ci.product.price,      // Lưu giá SP vào đơn để không bị ảnh hưởng nếu SP đổi giá sau
    quantity: ci.quantity,
    selectedSize: ci.selectedSize,
    selectedColor: ci.selectedColor,
    ...
  )).toList();

  // 4. Tạo batch — thực hiện nhiều thao tác Firestore trong 1 lần gọi (nguyên tử)
  final batch = _db.batch();

  // 4a. Lưu đơn hàng vào collection 'orders'
  batch.set(orderRef, order.toMap());

  // 4b. Trừ tồn kho từng sản phẩm bằng FieldValue.increment (an toàn khi đồng thời)
  for (final item in cartItems) {
    final productRef = _db.collection('products').doc(item.product.id);
    batch.update(productRef, {
      'stock': FieldValue.increment(-item.quantity), // Trừ đúng số lượng đặt
    });
  }

  // 5. Commit batch → Firestore thực hiện TẤT CẢ hoặc KHÔNG GÌ (all-or-nothing)
  await batch.commit();

  return order; // Trả về đối tượng Order đã lưu (có ID thực)
}
```

#### `getOrders()` — Lấy lịch sử đơn hàng

```dart
Future<List<Order>> getOrders() async {
  final snapshot = await _db
    .collection('orders')
    .orderBy('createdAt', descending: true) // Mới nhất lên đầu
    .get();
  return snapshot.docs.map((doc) =>
    Order.fromFirestore(doc.data(), doc.id)
  ).toList();
}
```

#### `deleteAllOrders()` — Xóa toàn bộ lịch sử (Batch Delete)

```dart
Future<void> deleteAllOrders() async {
  final snapshot = await _db.collection('orders').get();
  final batch = _db.batch();
  // Đánh dấu xóa từng document
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit(); // Xóa tất cả trong một lần gọi
}
```

---

## 7. Tầng Screen — Mô tả chi tiết các màn hình

### 7.1 `HomeScreen` — `lib/screens/home_screen.dart`

Màn hình chính của ứng dụng. Quản lý danh sách sản phẩm, bộ lọc danh mục, Error UI, giả lập mạng và cơ chế truy cập ẩn admin.

**State quan trọng:**

```dart
List<Product> _products       = []; // Danh sách SP hiển thị hiện tại
bool _isLoading               = false; // true khi đang gọi Firestore
String? _errorMessage         = null; // null = OK, có nội dung = lỗi
String _selectedCategory      = 'Tất cả'; // Danh mục đang chọn
bool _isSimulatingError       = false; // Trạng thái giả lập lỗi mạng
int _secretTapCount           = 0; // Đếm số lần nhấn bí mật vào tiêu đề
DateTime? _lastTapTime        = null; // Thời điểm nhấn gần nhất (kiểm tra timeout)
```

**Các hàm quan trọng:**

#### `_loadProducts()` — Tải dữ liệu từ Firestore

```dart
Future<void> _loadProducts() async {
  setState(() { _isLoading = true; _errorMessage = null; });
  try {
    // Nếu chọn "Tất cả" → gọi getProducts(), ngược lại → getProductsByCategory()
    final products = (_selectedCategory == 'Tất cả')
      ? await _firebaseService.getProducts()
      : await _firebaseService.getProductsByCategory(_selectedCategory);
    setState(() { _products = products; _isLoading = false; });
  } catch (e) {
    // Bất kỳ lỗi nào (kể cả lỗi giả lập) đều hiển thị Error UI
    setState(() { _errorMessage = e.toString(); _isLoading = false; });
  }
}
```

#### `_toggleSimulateError()` — Bật/tắt giả lập lỗi mạng

```dart
void _toggleSimulateError() {
  setState(() => _isSimulatingError = !_isSimulatingError);
  // Đồng bộ cờ vào FirebaseService (cờ static, ảnh hưởng toàn app)
  FirebaseService.simulateNetworkError = _isSimulatingError;

  if (_isSimulatingError) {
    // LẬP TỨC reload → khi gọi Firebase thì bị exception ngay
    _loadProducts();
  } else {
    // Tắt giả lập → chỉ hiển thị SnackBar hướng dẫn, KHÔNG tự reload
    // Người dùng cần tự nhấn "Thử lại" để thấy kết quả
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mạng đã khôi phục – nhấn "Thử lại" để tải dữ liệu'))
    );
  }
}
```

#### `_handleSecretTap()` — Cơ chế truy cập admin ẩn

```dart
void _handleSecretTap() {
  final now = DateTime.now();
  // Reset nếu quá 3 giây kể từ lần nhấn trước
  if (_lastTapTime != null && now.difference(_lastTapTime!) > Duration(seconds: 3)) {
    _secretTapCount = 0;
  }
  _secretTapCount++;
  _lastTapTime = now;
  // Đủ 5 lần trong vòng 3 giây → mở trang Admin
  if (_secretTapCount >= 5) {
    _secretTapCount = 0;
    Navigator.push(context, MaterialPageRoute(builder: (_) => AdminScreen()));
  }
}
```

#### `_buildBody()` — Logic render màn hình theo trạng thái

```dart
Widget _buildBody() {
  if (_isLoading)  return LoadingWidget();       // Đang tải → spinner
  if (_errorMessage != null) return AppErrorWidget(  // Lỗi → Error UI + Retry
    message: _errorMessage!,
    onRetry: _loadProducts,                      // Nhấn "Thử lại" → gọi lại _loadProducts
  );
  if (_products.isEmpty) return EmptyWidget();   // Rỗng → nút "Thêm dữ liệu mẫu"
  return GridView(/* danh sách ProductCard */);  // Bình thường → hiển thị lưới
}
```

**Điều hướng sang CartScreen (có await + reload):**

```dart
// Dùng await để chờ người dùng quay về từ CartScreen
// rồi gọi _loadProducts() để cập nhật tồn kho mới nhất
await Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
_loadProducts(); // Reload sau khi quay về
```

---

### 7.2 `ProductDetailScreen` — `lib/screens/product_detail_screen.dart`

Màn hình chi tiết sản phẩm. Cho phép chọn size/màu/số lượng, thêm giỏ hàng hoặc mua ngay.

**State:**

```dart
String? _selectedSize;   // Size đang chọn (null nếu chưa chọn)
String? _selectedColor;  // Màu đang chọn
int _quantity = 1;       // Số lượng muốn mua (1 ≤ qty ≤ stock)
```

**Các hàm quan trọng:**

#### `_showBuyNowDialog(context)` — Hiển thị dialog xác nhận mua ngay

```dart
void _showBuyNowDialog(BuildContext context) {
  // Kiểm tra đã chọn size chưa (nếu SP có nhiều size)
  if (product.sizes.isNotEmpty && _selectedSize == null) {
    // Hiện SnackBar yêu cầu chọn size
    return;
  }
  // Tương tự cho màu sắc

  // Hiện AlertDialog với:
  // - Tên sản phẩm, thương hiệu, giá, số lượng đã chọn
  // - Size/màu đã chọn (nếu có)
  // - Cảnh báo "Hết hàng" nếu stock = 0
  // - Nút "Hủy" | "Mua ngay" (disabled nếu stock < quantity)
  showDialog(context: context, builder: (_) => AlertDialog(...));
}
```

#### `_placeQuickOrder(context)` — Đặt hàng không qua giỏ

```dart
Future<void> _placeQuickOrder(BuildContext context) async {
  try {
    // Tạo CartItem tạm với size/màu/số lượng đã chọn
    final item = CartItem(
      product: widget.product,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColor: _selectedColor,
    );
    // Gọi OrderService: batch write lưu đơn + trừ stock
    final Order order = await OrderService().placeOrder([item]);

    // Hiện SnackBar thành công với mã đơn hàng 8 ký tự
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đặt hàng thành công! Đơn #${order.id.substring(0, 8).toUpperCase()}'),
      action: SnackBarAction(label: 'Lịch sử', onPressed: () => /* mở OrderHistoryScreen */),
    ));
  } catch (e) {
    // Hiện SnackBar lỗi
  }
}
```

#### `_showCartMessage(context)` — Thêm vào giỏ hàng

```dart
void _showCartMessage(BuildContext context) {
  // Kiểm tra size/màu đã chọn chưa (similar như _showBuyNowDialog)
  // Gọi CartService.addItem() với size/màu/số lượng đã chọn
  _cartService.addItem(product, size: _selectedSize, color: _selectedColor, quantity: _quantity);
  // Hiện SnackBar với nút "Xem giỏ"
}
```

---

### 7.3 `CartScreen` — `lib/screens/cart_screen.dart`

Màn hình giỏ hàng. Hiển thị danh sách sản phẩm, tính tổng tiền và thực hiện đặt hàng.

**Các hàm quan trọng:**

#### `_confirmCheckout()` — Xác nhận đặt hàng

```dart
void _confirmCheckout() {
  showDialog(context: context, builder: (_) => AlertDialog(
    title: Text('Xác nhận đặt hàng'),
    content: Text('Tổng: ${_formatPrice(total)} - ${itemCount} sản phẩm'),
    actions: [
      TextButton(child: Text('Hủy'), ...),
      ElevatedButton(child: Text('Đặt hàng'), onPressed: _placeOrder),
    ],
  ));
}
```

#### `_placeOrder()` — Thực thi đặt hàng

```dart
Future<void> _placeOrder() async {
  Navigator.pop(context); // Đóng dialog xác nhận
  setState(() => _isPlacingOrder = true); // Hiện loading overlay

  try {
    final order = await OrderService().placeOrder(_cartService.items);
    _cartService.clear(); // Xóa giỏ hàng sau khi đặt thành công
    _showOrderSuccessDialog(order); // Hiện dialog thành công
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(/* SnackBar lỗi */);
  } finally {
    setState(() => _isPlacingOrder = false); // Ẩn loading overlay
  }
}
```

#### `_showOrderSuccessDialog(order)` — Dialog thành công

```dart
void _showOrderSuccessDialog(Order order) {
  showDialog(builder: (_) => AlertDialog(
    title: Text('Đặt hàng thành công!'),
    content: Text('Mã đơn: #${order.id.substring(0, 8).toUpperCase()}'),
    actions: [
      TextButton(
        child: Text('Về trang chủ'),
        onPressed: () {
          Navigator.pop(context); // Đóng dialog
          Navigator.pop(context); // Quay về HomeScreen (sẽ trigger _loadProducts)
        },
      ),
      ElevatedButton(
        child: Text('Xem lịch sử'),
        onPressed: () => Navigator.pushReplacement(/* OrderHistoryScreen */),
      ),
    ],
  ));
}
```

---

### 7.4 `OrderHistoryScreen` — `lib/screens/order_history_screen.dart`

Màn hình lịch sử đơn hàng. Hiển thị danh sách đơn hàng, mỗi đơn có thể mở rộng để xem chi tiết.

**Các hàm quan trọng:**

#### `_loadOrders()` — Tải lịch sử

```dart
Future<void> _loadOrders() async {
  setState(() { _isLoading = true; _error = null; });
  try {
    final orders = await OrderService().getOrders(); // Đã sort descending by createdAt
    setState(() { _orders = orders; _isLoading = false; });
  } catch (e) {
    setState(() { _error = e.toString(); _isLoading = false; });
  }
}
```

**UI pattern:** Mỗi đơn hàng là một `ExpansionTile`:
- **Header:** mã đơn 8 ký tự, ngày giờ, trạng thái badge, tổng tiền
- **Expanded content:** danh sách `OrderItem` với ảnh, tên, size, màu, đơn giá × số lượng

---

### 7.5 `AdminScreen` — `lib/screens/admin_screen.dart`

Trang quản trị dành cho admin — ẩn với người dùng thường. Hỗ trợ CRUD sản phẩm đầy đủ.

**Hàm xóa toàn bộ (cascade):**

```dart
Future<void> _confirmDeleteAll() async {
  // Hiện dialog xác nhận với cảnh báo rõ ràng
  final confirmed = await showDialog<bool>(builder: (_) => AlertDialog(
    content: Text('Xóa toàn bộ ${_products.length} sản phẩm?\n'
                  'Lịch sử đơn hàng và giỏ hàng cũng sẽ bị xóa.\n'
                  'Hành động này không thể hoàn tác.'),
    ...
  ));

  if (confirmed == true) {
    // 1. Xóa toàn bộ sản phẩm (batch delete collection products)
    await _firebaseService.deleteAllProducts();
    // 2. Xóa toàn bộ lịch sử đơn hàng (batch delete collection orders)
    await OrderService().deleteAllOrders();
    // 3. Xóa giỏ hàng đang có trong bộ nhớ
    CartService().clear();
    // 4. Reload danh sách (sẽ rỗng)
    _loadProducts();
  }
}
```

---

### 7.6 `SearchScreen` — `lib/screens/search_screen.dart`

Tìm kiếm real-time. Kết quả lọc ngay khi người dùng gõ, kết hợp với chip filter danh mục và sort.

**Hàm lọc kết quả:**

```dart
void _filterProducts(String query) {
  List<Product> result = _allProducts.where((p) =>
    p.name.toLowerCase().contains(query.toLowerCase()) ||
    p.brand.toLowerCase().contains(query.toLowerCase())
  ).toList();

  // Áp dụng filter danh mục
  if (_selectedCategory != 'Tất cả') {
    result = result.where((p) => p.category == _selectedCategory).toList();
  }

  // Áp dụng sắp xếp
  switch (_sortOption) {
    case 'price_asc':  result.sort((a, b) => a.price.compareTo(b.price));
    case 'price_desc': result.sort((a, b) => b.price.compareTo(a.price));
    case 'rating':     result.sort((a, b) => b.rating.compareTo(a.rating));
  }

  setState(() => _filtered = result);
}
```

---

### 7.7 Widget `AppErrorWidget` — `lib/widgets/app_error_widget.dart`

Widget tái sử dụng hiển thị trạng thái lỗi. Được dùng ở `HomeScreen` và `SearchScreen`.

```dart
class AppErrorWidget extends StatelessWidget {
  final String message;     // Nội dung lỗi hiển thị cho người dùng
  final VoidCallback onRetry; // Callback khi nhấn "Thử lại"

  // Render: Icon lỗi + Text message + ElevatedButton "Thử lại"
  // Khi nhấn "Thử lại" → gọi onRetry() → màn hình gọi lại _loadProducts()
}
```

---

## 8. Cấu trúc dữ liệu Firestore

### Collection: `products`

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|:--------:|-------|
| `name` | String | ✅ | Tên sản phẩm |
| `description` | String | ✅ | Mô tả chi tiết |
| `price` | Number | ✅ | Giá bán hiện tại (VNĐ) |
| `originalPrice` | Number | ❌ | Giá gốc (dùng khi `isSale = true`) |
| `imageUrl` | String | ✅ | URL ảnh (Unsplash hoặc CDN khác) |
| `category` | String | ✅ | `Áo` / `Quần` / `Váy` / `Áo khoác` / `Khác` |
| `brand` | String | ✅ | Thương hiệu |
| `rating` | Number | ✅ | Điểm đánh giá (0.0–5.0) |
| `reviewCount` | Number | ✅ | Số lượt đánh giá |
| `stock` | Number | ✅ | Tồn kho — **tự động giảm khi đặt hàng** |
| `sizes` | Array\<String\> | ✅ | VD: `["S","M","L","XL"]` — rỗng nếu SP không có size |
| `colors` | Array\<String\> | ✅ | VD: `["Đen","Trắng","Xanh"]` — rỗng nếu không có màu |
| `isNew` | Boolean | ✅ | `true` → hiện nhãn "MỚI" trên thẻ sản phẩm |
| `isSale` | Boolean | ✅ | `true` → hiện nhãn "-X%" trên thẻ sản phẩm |
| `discountPercent` | Number | ❌ | Giá trị X trong nhãn "-X%" (nullable) |

### Collection: `orders`

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| `totalPrice` | Number | Tổng tiền đơn hàng (VNĐ) |
| `createdAt` | String | ISO 8601 — dùng để sort descending |
| `status` | String | Luôn là `"Đã xác nhận"` |
| `items` | Array | Mảng các `OrderItem` (xem bên dưới) |

**Cấu trúc mỗi phần tử trong `items`:**

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| `productId` | String | Tham chiếu documents `products/{id}` |
| `productName` | String | Chụp lại tại thời điểm đặt |
| `productBrand` | String | Chụp lại tại thời điểm đặt |
| `imageUrl` | String | Chụp lại URL ảnh |
| `price` | Number | Chụp lại đơn giá tại thời điểm đặt |
| `quantity` | Number | Số lượng đặt |
| `selectedSize` | String? | Size đã chọn (null nếu không chọn) |
| `selectedColor` | String? | Màu đã chọn (null nếu không chọn) |

---

## 9. Kiến trúc & Luồng xử lý

### Sơ đồ phân lớp

```
┌─────────────────────────────────────────────────┐
│                   UI LAYER                       │
│  HomeScreen  SearchScreen  ProductDetailScreen   │
│  CartScreen  OrderHistoryScreen  AdminScreen     │
└──────────────────────┬──────────────────────────┘
                       │ gọi hàm service
┌──────────────────────▼──────────────────────────┐
│               SERVICE LAYER                      │
│  FirebaseService   CartService   OrderService    │
│  (Singleton)       (Singleton    (Singleton)     │
│                    +ChangeNotif)                 │
└──────────────────────┬──────────────────────────┘
                       │ đọc/ghi Firestore
┌──────────────────────▼──────────────────────────┐
│               DATA LAYER                         │
│  Cloud Firestore (products, orders)              │
│  In-memory state (CartService._items)            │
└─────────────────────────────────────────────────┘
```

### Luồng 1: Hiển thị sản phẩm & Error UI

```
Khởi động app
  → HomeScreen.initState() → _loadProducts()
      → FirebaseService.getProducts()
          ├─ simulateNetworkError = true → throw Exception → _errorMessage != null
          │        → AppErrorWidget(onRetry: _loadProducts) hiển thị
          │        → Người dùng nhấn "Thử lại" → gọi lại _loadProducts()
          └─ bình thường → trả về List<Product>
                   → setState(_products) → GridView rebuild → ProductCard hiển thị
```

### Luồng 2: Thêm vào giỏ & Cập nhật badge

```
ProductDetailScreen
  → chọn size/màu/số lượng
  → "Thêm vào giỏ" → CartService.addItem(product, size, color, qty)
      → _items thay đổi → notifyListeners()
          → ListenableBuilder trên AppBar rebuild
              → badge hiển thị totalItemCount mới
```

### Luồng 3: Mua ngay (không qua giỏ)

```
ProductDetailScreen
  → "Mua ngay" → _showBuyNowDialog() [kiểm tra size/màu]
      → người dùng xác nhận → _placeQuickOrder()
          → tạo CartItem tạm (qty=_quantity, size, color)
          → OrderService.placeOrder([item])
              → Firestore Batch:
                  ├─ orders.set({ items, totalPrice, createdAt, status })
                  └─ products/{id}.update({ stock: increment(-qty) })
          → SnackBar thành công + nút "Lịch sử"
```

### Luồng 4: Đặt hàng qua giỏ hàng

```
CartScreen
  → "Đặt hàng" → _confirmCheckout() [dialog xác nhận]
      → _placeOrder()
          → setState(_isPlacingOrder = true) [hiện loading overlay]
          → OrderService.placeOrder(cartService.items)
              → Firestore Batch (lưu đơn + trừ stock × n sản phẩm)
          → CartService.clear() [dọn giỏ hàng]
          → _showOrderSuccessDialog(order)
              → "Về trang chủ" → Navigator.pop() × 2
                  → HomeScreen tự reload (Navigator.push dùng await)
              → "Xem lịch sử" → Navigator → OrderHistoryScreen
```

### Luồng 5: Xóa toàn bộ (Admin cascade)

```
AdminScreen
  → nhấn icon delete_sweep → _confirmDeleteAll()
      → AlertDialog xác nhận ("sản phẩm + đơn hàng + giỏ sẽ bị xóa")
      → xác nhận:
          → FirebaseService.deleteAllProducts()  [batch xóa products]
          → OrderService.deleteAllOrders()       [batch xóa orders]
          → CartService.clear()                  [xóa giỏ trong bộ nhớ]
          → _loadProducts() [reload danh sách → rỗng]
          → SnackBar "Đã xóa toàn bộ sản phẩm, đơn hàng và giỏ hàng"
```

### Design Patterns áp dụng

| Pattern | Nơi áp dụng | Lý do |
|---------|-------------|-------|
| **Singleton** | `FirebaseService`, `CartService`, `OrderService` | Đảm bảo cùng state, tránh tạo nhiều kết nối Firestore |
| **ChangeNotifier** | `CartService extends ChangeNotifier` | Notify widget khi giỏ hàng thay đổi mà không cần setState |
| **ListenableBuilder** | Badge giỏ hàng trên AppBar | Chỉ rebuild đúng widget cần thiết, hiệu quả hơn setState toàn màn hình |
| **Factory Constructor** | `Product.fromFirestore()`, `Order.fromFirestore()` | Tách logic ánh xạ Firestore Map → Dart object |
| **Batch Write** | `placeOrder()`, `deleteAllProducts()`, `deleteAllOrders()` | Đảm bảo nhiều thao tác Firestore thành công hoặc thất bại cùng lúc |
| **Snapshot pattern** | `OrderItem` lưu lại thông tin SP | Giữ thông tin đơn hàng chính xác dù SP bị sửa/xóa sau |

---

## 10. Firestore Rules

File `firestore.rules`:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Collection sản phẩm — cho phép đọc/ghi công khai (test mode)
    match /products/{productId} {
      allow read: if true;
      allow write: if true;
    }

    // Collection lịch sử đơn hàng — cho phép đọc/ghi công khai (test mode)
    match /orders/{orderId} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

> **Lưu ý bảo mật:** Cấu hình trên là **test mode** dành cho bài thực hành.  
> Trong production cần Firebase Authentication và quy tắc chặt hơn:
> ```js
> allow read:  if request.auth != null;
> allow write: if request.auth != null && request.auth.token.admin == true;
> ```

**Deploy rules:**

```bash
firebase deploy --only firestore:rules --project <YOUR_PROJECT_ID>
```

---

## 11. Cài đặt & Chạy dự án

### Yêu cầu

- Flutter SDK ≥ 3.10.7
- Dart SDK ≥ 3.x
- Android Studio / VS Code
- Tài khoản Google (để dùng Firebase)

### Bước 1: Clone & mở dự án

```bash
git clone <repository-url>
cd FashionStore
```

### Bước 2: Tạo Firebase Project

1. Vào [console.firebase.google.com](https://console.firebase.google.com) → **Add project**
2. Vào **Firestore Database** → **Create database** → **Start in test mode** → region `asia-southeast1`

### Bước 3: Kết nối Firebase với Flutter

```bash
# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Kết nối và tự tạo firebase_options.dart
flutterfire configure
```

### Bước 4: Cài dependencies & Deploy rules

```bash
flutter pub get
npm install -g firebase-tools
firebase deploy --only firestore:rules --project <YOUR_PROJECT_ID>
```

### Bước 5: Chạy ứng dụng

```bash
flutter run              # Android/iOS (cần emulator/thiết bị thật)
flutter run -d chrome    # Web (Chrome)
flutter run -d windows   # Windows Desktop
```

---

## 12. Hướng dẫn sử dụng

### Lần đầu chạy

1. App khởi động → Firestore trống → hiện nút **"Thêm dữ liệu mẫu"**
2. Nhấn nút → `seedSampleData()` thêm 28 sản phẩm → danh sách hiển thị

### Duyệt & lọc sản phẩm

- Nhấn tab danh mục (Áo / Quần / Váy / Áo khoác) để lọc
- Kéo xuống để pull-to-refresh
- Nhấn 🔍 để vào màn hình tìm kiếm

### Mua hàng — Cách 1: Qua giỏ hàng

1. Nhấn thẻ sản phẩm → vào trang chi tiết
2. Chọn size, màu, số lượng
3. Nhấn **"Thêm vào giỏ hàng"** → badge giỏ cập nhật
4. Nhấn icon 🛍 → vào CartScreen
5. Nhấn **"Đặt hàng"** → xác nhận → đặt hàng thành công

### Mua hàng — Cách 2: Mua ngay

1. Nhấn thẻ sản phẩm → vào trang chi tiết
2. Chọn size, màu, số lượng (nếu có)
3. Nhấn **"Mua ngay"** → dialog xác nhận hiện ra
4. Nhấn **"Mua ngay"** trong dialog → đặt hàng ngay lập tức

### Xem lịch sử đơn hàng

- Nhấn icon 🧾 trên AppBar → `OrderHistoryScreen`
- Nhấn vào đơn hàng để xem chi tiết từng sản phẩm trong đơn

### Kiểm thử Error UI & Retry

1. Nhấn icon 📶 WiFi → giả lập mất mạng → màn hình lỗi hiện ra
2. Nhấn **"Thử lại"** → vẫn lỗi (vì giả lập còn bật)
3. Nhấn lại icon 📶 WiFi-Off → tắt giả lập → SnackBar hướng dẫn
4. Nhấn **"Thử lại"** → tải thành công

### Trang Admin

1. Nhấn **5 lần liên tiếp** (trong 3 giây) vào chữ "FashionStore" trên AppBar
2. Trang Admin mở ra:
   - Nhấn **✏️** để sửa sản phẩm
   - Nhấn **🗑️** để xóa từng sản phẩm
   - Nhấn icon **delete_sweep** trên AppBar → xóa toàn bộ (sản phẩm + đơn hàng + giỏ)

---

## 13. Ghi chú kỹ thuật

- **Giỏ hàng không persistent:** Dữ liệu giỏ lưu trong bộ nhớ (`CartService._items`). Thoát app hoàn toàn sẽ mất giỏ hàng. Để persistent cần thêm `shared_preferences` hoặc `hive`.
- **Tồn kho dùng `FieldValue.increment`:** An toàn khi nhiều người đặt cùng lúc — Firestore xử lý nguyên tử, không cần đọc giá trị cũ trước khi trừ.
- **Batch Write giới hạn 500 thao tác:** Nếu dữ liệu lớn cần chia nhỏ batch.
- **`hide Order` trong import Firestore:** Firestore export class `Order` trùng tên với model — giải quyết bằng `import '...' hide Order;`.
- **Không dùng đăng nhập:** Phù hợp phạm vi bài thực hành. Production cần Firebase Auth.
- **Màu chủ đạo:** `#E91E8C` (hồng đậm — người dùng), `#333333` (đen — admin).
- **Ảnh sản phẩm:** Load từ URL Unsplash, cache bởi `cached_network_image` — app vẫn hiển thị placeholder nếu URL hỏng.
- **Seed data 28 sản phẩm:** Kiểm tra collection trống trước khi seed — không bị duplicate nếu gọi lại.

