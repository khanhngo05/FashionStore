import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/cart_item.dart';
import '../models/order.dart';

/// Service xử lý đặt hàng: lưu đơn hàng và trừ tồn kho
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';
  static const String _productsCollection = 'products';

  /// Đặt hàng: lưu đơn vào Firestore và trừ tồn kho (dùng batch)
  Future<Order> placeOrder(List<CartItem> cartItems) async {
    if (cartItems.isEmpty) throw Exception('Giỏ hàng trống');

    final orderRef = _db.collection(_ordersCollection).doc();
    final now = DateTime.now();
    final double total =
        cartItems.fold(0, (sum, item) => sum + item.totalPrice);

    final orderItems = cartItems
        .map((ci) => OrderItem(
              productId: ci.product.id,
              productName: ci.product.name,
              productBrand: ci.product.brand,
              imageUrl: ci.product.imageUrl,
              price: ci.product.price,
              quantity: ci.quantity,
              selectedSize: ci.selectedSize,
              selectedColor: ci.selectedColor,
            ))
        .toList();

    final order = Order(
      id: orderRef.id,
      items: orderItems,
      totalPrice: total,
      createdAt: now,
      status: 'Đã xác nhận',
    );

    // Batch: lưu đơn hàng + trừ tồn kho cùng lúc
    final batch = _db.batch();

    // 1) Lưu đơn hàng
    batch.set(orderRef, order.toMap());

    // 2) Trừ tồn kho từng sản phẩm
    for (final item in cartItems) {
      final productRef =
          _db.collection(_productsCollection).doc(item.product.id);
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
    return order;
  }

  /// Lấy danh sách lịch sử đơn hàng (mới nhất trước)
  Future<List<Order>> getOrders() async {
    try {
      final snapshot = await _db
          .collection(_ordersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi tải lịch sử: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể tải lịch sử đơn hàng.');
    }
  }

  /// Xóa toàn bộ lịch sử đơn hàng
  Future<void> deleteAllOrders() async {
    try {
      final snapshot = await _db.collection(_ordersCollection).get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception('Lỗi xóa lịch sử đơn hàng: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Không thể xóa lịch sử đơn hàng.');
    }
  }
}
