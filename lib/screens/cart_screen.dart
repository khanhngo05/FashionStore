import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'order_history_screen.dart';

/// Màn hình giỏ hàng
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  bool _isPlacingOrder = false;

  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '$formatted₫';
  }

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _confirmCheckout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shopping_bag_outlined, color: Color(0xFFE91E8C)),
            SizedBox(width: 8),
            Text('Xác nhận đặt hàng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_cartService.totalItemCount} sản phẩm',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  _formatPrice(_cartService.totalPrice),
                  style: const TextStyle(
                    color: Color(0xFFE91E8C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Bạn có chắc muốn đặt hàng?\nTồn kho sẽ được cập nhật tự động.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _placeOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đặt hàng'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    try {
      final items = List.of(_cartService.items);
      final Order order = await _orderService.placeOrder(items);
      _cartService.clear();

      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      _showOrderSuccessDialog(order);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đặt hàng: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOrderSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade500, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đặt hàng thành công!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đơn #${order.id.substring(0, 8).toUpperCase()}',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              _formatPrice(order.totalPrice),
              style: const TextStyle(
                color: Color(0xFFE91E8C),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.totalItemCount} sản phẩm • Tồn kho đã được cập nhật',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog
              Navigator.pop(context); // về home
            },
            child: const Text('Về trang chủ'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const OrderHistoryScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded, size: 16),
            label: const Text('Xem lịch sử'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              _cartService.clear();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TH3 - Ngô Xuân Khánh - 2351060453',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Text(
              'Giỏ hàng (${_cartService.totalItemCount})',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Xóa tất cả',
              onPressed: _confirmClearCart,
            ),
        ],
      ),
      body: Stack(
        children: [
          items.isEmpty ? _buildEmptyCart() : _buildCartList(items),
          if (_isPlacingOrder)
            Container(
              color: Colors.black.withAlpha(60),
              child: const Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE91E8C)),
                        SizedBox(height: 16),
                        Text('Đang xử lý đơn hàng...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: items.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 90, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm yêu thích vào giỏ ngay nào!',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Tiếp tục mua sắm'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(List<CartItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCartItemCard(item);
      },
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    final product = item.product;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 90,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.checkroom,
                              color: Colors.grey, size: 36),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.checkroom,
                            color: Colors.grey, size: 36),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  // Size & màu
                  if (item.selectedSize != null ||
                      item.selectedColor != null) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (item.selectedSize != null)
                          _buildChip('Size: ${item.selectedSize}'),
                        if (item.selectedColor != null)
                          _buildChip('Màu: ${item.selectedColor}'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Giá + Số lượng
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          color: Color(0xFFE91E8C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      // Nút - số lượng +
                      _buildQtyButton(
                        Icons.remove,
                        () => _cartService.updateQuantity(
                            item.uniqueKey, item.quantity - 1),
                        small: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildQtyButton(
                        Icons.add,
                        () => _cartService.updateQuantity(
                            item.uniqueKey, item.quantity + 1),
                        small: true,
                      ),
                    ],
                  ),
                  // Tổng tiền item
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tổng: ${_formatPrice(item.totalPrice)}',
                      style: TextStyle(
                          color: Colors.grey[700], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Nút xóa
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => _cartService.removeItem(item.uniqueKey),
              tooltip: 'Xóa',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E8C).withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style:
            const TextStyle(fontSize: 11, color: Color(0xFFE91E8C)),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap,
      {bool small = false}) {
    final size = small ? 28.0 : 36.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: small ? 16 : 20, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tóm tắt
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_cartService.totalItemCount} sản phẩm',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                'Tổng: ${_formatPrice(_cartService.totalPrice)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFE91E8C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Nút đặt hàng
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Đặt hàng - ${_formatPrice(_cartService.totalPrice)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
