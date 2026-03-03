import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Màn hình tìm kiếm sản phẩm
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final CartService _cartService = CartService();

  List<Product> _allProducts = [];
  List<Product> _filtered = [];
  bool _isLoading = true;
  String _query = '';

  // Bộ lọc
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Mặc định';

  final List<String> _categories = ['Tất cả', 'Áo', 'Quần', 'Váy', 'Áo khoác'];
  final List<String> _sortOptions = ['Mặc định', 'Giá tăng dần', 'Giá giảm dần', 'Đánh giá cao'];

  @override
  void initState() {
    super.initState();
    _loadAll();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    try {
      final products = await _firebaseService.getProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onQueryChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> result = List.from(_allProducts);

    // Lọc theo từ khoá
    if (_query.isNotEmpty) {
      result = result.where((p) {
        return p.name.toLowerCase().contains(_query) ||
            p.brand.toLowerCase().contains(_query) ||
            p.category.toLowerCase().contains(_query) ||
            p.description.toLowerCase().contains(_query);
      }).toList();
    }

    // Lọc theo danh mục
    if (_selectedCategory != 'Tất cả') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    // Sắp xếp
    switch (_sortBy) {
      case 'Giá tăng dần':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá giảm dần':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Đánh giá cao':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    setState(() => _filtered = result);
  }

  String _formatPrice(double price) {
    final formatted = price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
    return '$formatted₫';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withAlpha(30),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white60),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Thanh bộ lọc
          _buildFilterBar(),
          // Kết quả
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Lọc danh mục
          Expanded(
            child: SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      _applyFilters();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE91E8C)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE91E8C)
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sắp xếp
          GestureDetector(
            onTap: _showSortSheet,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Sắp xếp',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sắp xếp theo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._sortOptions.map((opt) => RadioListTile<String>(
                  value: opt,
                  groupValue: _sortBy,
                  activeColor: const Color(0xFFE91E8C),
                  title: Text(opt),
                  onChanged: (val) {
                    setState(() => _sortBy = val!);
                    _applyFilters();
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
      );
    }

    if (_allProducts.isEmpty) {
      return const Center(
        child: Text('Không có sản phẩm nào.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              _query.isNotEmpty
                  ? 'Không tìm thấy kết quả cho "$_query"'
                  : 'Không có sản phẩm trong danh mục này',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                'Tìm thấy ${_filtered.length} sản phẩm',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filtered.length,
            itemBuilder: (context, index) {
              final product = _filtered[index];
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
    );
  }
}
