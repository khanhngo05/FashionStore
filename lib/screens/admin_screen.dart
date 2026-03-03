import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'add_edit_product_screen.dart';
import '../widgets/app_error_widget.dart';

/// Trang quản trị - chỉ admin mới biết đường vào
/// Truy cập: nhấn 5 lần vào tiêu đề "FashionStore" trên AppBar màn hình chính
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await _firebaseService.getProducts();
      if (mounted) setState(() => _products = products);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TH3 - Ngô Xuân Khánh - 2351060453',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
            Text(
              '🔐 Quản trị sản phẩm',
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreen(),
            ),
          );
          if (changed == true) _loadProducts();
        },
        backgroundColor: const Color(0xFF333333),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm sản phẩm'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF333333)),
            SizedBox(height: 12),
            Text('Đang tải...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return AppErrorWidget(message: _errorMessage!, onRetry: _loadProducts);
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Chưa có sản phẩm nào',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  await _firebaseService.seedSampleData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm dữ liệu mẫu!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadProducts();
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = e.toString();
                    });
                  }
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Thêm dữ liệu mẫu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFF333333),
      child: Column(
        children: [
          // Thống kê nhanh
          Container(
            color: const Color(0xFF333333),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildStatChip(Icons.inventory_2_outlined,
                    '${_products.length} sản phẩm'),
                const SizedBox(width: 16),
                _buildStatChip(Icons.new_releases_outlined,
                    '${_products.where((p) => p.isNew).length} mới'),
                const SizedBox(width: 16),
                _buildStatChip(Icons.local_offer_outlined,
                    '${_products.where((p) => p.isSale).length} sale'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductTile(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildProductTile(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.category,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Row(
              children: [
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    color: Color(0xFFE91E8C),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                if (product.isNew)
                  _buildTag('MỚI', Colors.green),
                if (product.isSale)
                  _buildTag('SALE', Colors.red),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: Color(0xFF333333)),
          tooltip: 'Chỉnh sửa',
          onPressed: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditProductScreen(product: product),
              ),
            );
            if (changed == true) _loadProducts();
          },
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported,
            size: 24, color: Colors.grey),
      );

  Widget _buildTag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '$formatted₫';
  }
}
