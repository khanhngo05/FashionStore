import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// Dịch vụ quản lý giỏ hàng - Singleton + ChangeNotifier
class CartService extends ChangeNotifier {
  // Singleton
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  /// Danh sách các mục trong giỏ hàng
  List<CartItem> get items => List.unmodifiable(_items);

  /// Tổng số lượng sản phẩm trong giỏ
  int get totalItemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// Tổng giá tiền
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Kiểm tra giỏ hàng có trống không
  bool get isEmpty => _items.isEmpty;

  /// Thêm sản phẩm vào giỏ hàng
  void addItem(Product product, {String? size, String? color, int quantity = 1}) {
    final key = '${product.id}_${size ?? ""}_${color ?? ""}';
    final existingIndex = _items.indexWhere((i) => i.uniqueKey == key);

    if (existingIndex >= 0) {
      // Đã có trong giỏ → tăng số lượng
      final existing = _items[existingIndex];
      final newQty = (existing.quantity + quantity).clamp(1, product.stock);
      _items[existingIndex] = existing.copyWith(quantity: newQty);
    } else {
      // Thêm mới
      _items.add(CartItem(
        product: product,
        selectedSize: size,
        selectedColor: color,
        quantity: quantity.clamp(1, product.stock),
      ));
    }
    notifyListeners();
  }

  /// Xóa một mục khỏi giỏ hàng
  void removeItem(String uniqueKey) {
    _items.removeWhere((i) => i.uniqueKey == uniqueKey);
    notifyListeners();
  }

  /// Cập nhật số lượng
  void updateQuantity(String uniqueKey, int quantity) {
    final index = _items.indexWhere((i) => i.uniqueKey == uniqueKey);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final item = _items[index];
        final maxQty = item.product.stock;
        _items[index] = item.copyWith(quantity: quantity.clamp(1, maxQty));
      }
      notifyListeners();
    }
  }

  /// Xóa toàn bộ giỏ hàng
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
