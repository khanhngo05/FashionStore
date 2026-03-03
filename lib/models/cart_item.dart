import 'product.dart';

/// Model đại diện cho một mục trong giỏ hàng
class CartItem {
  final Product product;
  final String? selectedSize;
  final String? selectedColor;
  int quantity;

  CartItem({
    required this.product,
    this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
  });

  /// Giá tổng của mục này
  double get totalPrice => product.price * quantity;

  /// Tạo bản sao với số lượng mới
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Key duy nhất để phân biệt sản phẩm cùng loại nhưng khác size/màu
  String get uniqueKey => '${product.id}_${selectedSize ?? ""}_${selectedColor ?? ""}';
}
