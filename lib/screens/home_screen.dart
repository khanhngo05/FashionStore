import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';
import '../widgets/app_error_widget.dart';
import 'product_detail_screen.dart';
import 'admin_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';

/// Màn hình chính - hiển thị danh sách sản phẩm
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final CartService _cartService = CartService();

  // Trạng thái
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'Tất cả';
  bool _isSeeding = false;
  int _cartCount = 0;

  // Trạng thái giả lập lỗi mạng
  bool _isSimulatingError = false;

  // Bí mật: nhấn 5 lần vào tiêu đề để mở trang admin
  int _secretTapCount = 0;
  DateTime? _lastTapTime;

  final List<String> _categories = [
    'Tất cả',
    'Áo',
    'Quần',
    'Váy',
    'Áo khoác',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() => _cartCount = _cartService.totalItemCount);
  }

  /// Hàm tải dữ liệu sản phẩm từ Firebase
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Product> products;
      if (_selectedCategory == 'Tất cả') {
        products = await _firebaseService.getProducts();
      } else {
        products = await _firebaseService.getProductsByCategory(_selectedCategory);
      }

      // Nếu chưa có dữ liệu, hỏi người dùng có muốn seed không
      if (products.isEmpty && _selectedCategory == 'Tất cả') {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _products = [];
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  /// Seed dữ liệu mẫu vào Firestore
  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    try {
      await _firebaseService.seedSampleData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm dữ liệu mẫu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  /// Bật/tắt giả lập lỗi mạng
  void _toggleSimulateError() {
    final turningOn = !_isSimulatingError;
    setState(() {
      _isSimulatingError = turningOn;
      FirebaseService.simulateNetworkError = turningOn;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              turningOn ? Icons.wifi_off : Icons.wifi,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                turningOn
                    ? 'Đã bật giả lập lỗi mạng'
                    : 'Mạng đã khôi phục – nhấn "Thử lại" để tải dữ liệu',
              ),
            ),
          ],
        ),
        backgroundColor:
            turningOn ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Chỉ tự động gọi lại khi BẬT lỗi (để kích hoạt màn hình lỗi).
    // Khi TẮT lỗi, giữ nguyên màn hình lỗi; người dùng phải bấm "Thử lại".
    if (turningOn) {
      _loadProducts();
    }
  }

  /// Nhấn 5 lần trong 3 giây để mở trang admin ẩn
  void _handleSecretTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 3)) {
      _secretTapCount = 1;
    } else {
      _secretTapCount++;
    }
    _lastTapTime = now;

    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Banner chào mừng
          _buildWelcomeBanner(),
          // Bộ lọc danh mục
          _buildCategoryFilter(),
          // Nội dung chính
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFE91E8C),
      foregroundColor: Colors.white,
      elevation: 0,
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSecretTap,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TH3 - Ngô Xuân Khánh - 2351060453',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
            Text(
              'G10 Store',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Nút giả lập lỗi mạng
        Tooltip(
          message: _isSimulatingError ? 'Tắt giả lập lỗi mạng' : 'Giả lập lỗi mạng',
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isSimulatingError ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                key: ValueKey(_isSimulatingError),
                color: _isSimulatingError ? Colors.red.shade200 : Colors.white,
              ),
            ),
            onPressed: _toggleSimulateError,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
          tooltip: 'Tìm kiếm',
        ),
        // Nút lịch sử đơn hàng
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: 'Lịch sử đơn hàng',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            );
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              tooltip: 'Giỏ hàng',
            ),
            if (_cartCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _cartCount > 99 ? '99+' : '$_cartCount',
                      style: const TextStyle(
                        color: Color(0xFFE91E8C),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE91E8C), Color(0xFFFF6B9D)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào mừng đến với G10 Store!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Khám phá hàng nghìn sản phẩm thời trang',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.checkroom, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() => _selectedCategory = category);
                _loadProducts();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE91E8C)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE91E8C)
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    // TRẠNG THÁI ĐANG TẢI
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFE91E8C),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải sản phẩm...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // TRẠNG THÁI LỖI
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadProducts,
      );
    }

    // TRẠNG THÁI RỖNG (chưa có dữ liệu)
    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Chưa có sản phẩm nào',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thêm dữ liệu mẫu để bắt đầu trải nghiệm',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSeeding ? null : _seedData,
                icon: _isSeeding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(_isSeeding ? 'Đang thêm...' : 'Thêm dữ liệu mẫu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E8C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // TRẠNG THÁI THÀNH CÔNG - Hiển thị GridView sản phẩm
    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFFE91E8C),
      child: Column(
        children: [
          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'Tất cả'
                      ? 'Tất cả sản phẩm'
                      : _selectedCategory,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_products.length} sản phẩm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
