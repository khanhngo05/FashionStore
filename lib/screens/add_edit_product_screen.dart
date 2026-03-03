import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

/// Màn hình thêm mới hoặc chỉnh sửa sản phẩm
class AddEditProductScreen extends StatefulWidget {
  /// Nếu product != null → chế độ chỉnh sửa, null → thêm mới
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _originalPriceCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _reviewCountCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _sizesCtrl;
  late final TextEditingController _colorsCtrl;

  String _selectedCategory = 'Áo';
  bool _isNew = false;
  bool _isSale = false;

  final List<String> _categories = ['Áo', 'Quần', 'Váy', 'Áo khoác', 'Khác'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price.toInt().toString() ?? '');
    _originalPriceCtrl = TextEditingController(
        text: p?.originalPrice?.toInt().toString() ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _ratingCtrl =
        TextEditingController(text: p?.rating.toString() ?? '0.0');
    _reviewCountCtrl =
        TextEditingController(text: p?.reviewCount.toString() ?? '0');
    _stockCtrl = TextEditingController(text: p?.stock.toString() ?? '0');
    _sizesCtrl =
        TextEditingController(text: p?.sizes.join(', ') ?? '');
    _colorsCtrl =
        TextEditingController(text: p?.colors.join(', ') ?? '');

    if (p != null) {
      _selectedCategory = p.category;
      _isNew = p.isNew;
      _isSale = p.isSale;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _imageUrlCtrl.dispose();
    _brandCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewCountCtrl.dispose();
    _stockCtrl.dispose();
    _sizesCtrl.dispose();
    _colorsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'originalPrice': _originalPriceCtrl.text.trim().isEmpty
            ? null
            : double.parse(_originalPriceCtrl.text.trim()),
        'imageUrl': _imageUrlCtrl.text.trim(),
        'category': _selectedCategory,
        'brand': _brandCtrl.text.trim(),
        'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 0.0,
        'reviewCount': int.tryParse(_reviewCountCtrl.text.trim()) ?? 0,
        'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
        'sizes': _sizesCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'colors': _colorsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'isNew': _isNew,
        'isSale': _isSale,
      };

      final db = FirebaseFirestore.instance;

      if (_isEditing) {
        // Cập nhật sản phẩm hiện có
        await db.collection('products').doc(widget.product!.id).update(data);
      } else {
        // Thêm sản phẩm mới
        await db.collection('products').add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Cập nhật thành công!' : 'Thêm sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // true = có thay đổi
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        _showError('Lỗi Firebase: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (mounted) {
        _showError('Lỗi: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: Text(
            'Bạn có chắc muốn xoá sản phẩm "${widget.product!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product!.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xoá sản phẩm!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } on FirebaseException catch (e) {
      if (mounted) _showError('Lỗi Firebase: ${e.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E8C),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TH3 - Ngô Xuân Khánh - 2351060453',
              style: TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Text(
              _isEditing ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xoá sản phẩm',
              onPressed: _isLoading ? null : _deleteProduct,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE91E8C)),
                  SizedBox(height: 12),
                  Text('Đang lưu...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Preview ảnh
                  _buildImagePreview(),
                  const SizedBox(height: 16),

                  _buildSection('Thông tin cơ bản', [
                    _buildField(
                      controller: _nameCtrl,
                      label: 'Tên sản phẩm *',
                      icon: Icons.label_outline,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    _buildField(
                      controller: _brandCtrl,
                      label: 'Thương hiệu *',
                      icon: Icons.storefront_outlined,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Vui lòng nhập thương hiệu' : null,
                    ),
                    _buildCategoryDropdown(),
                    _buildField(
                      controller: _descCtrl,
                      label: 'Mô tả sản phẩm',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                  ]),

                  _buildSection('Giá bán', [
                    _buildField(
                      controller: _priceCtrl,
                      label: 'Giá bán (₫) *',
                      icon: Icons.sell_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Vui lòng nhập giá';
                        if (double.tryParse(v.trim()) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    _buildField(
                      controller: _originalPriceCtrl,
                      label: 'Giá gốc (₫) - để trống nếu không giảm',
                      icon: Icons.money_off_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.trim().isEmpty) return null;
                        if (double.tryParse(v.trim()) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ]),

                  _buildSection('Hình ảnh & Kho', [
                    _buildField(
                      controller: _imageUrlCtrl,
                      label: 'URL hình ảnh',
                      icon: Icons.image_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    _buildField(
                      controller: _stockCtrl,
                      label: 'Số lượng tồn kho',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ]),

                  _buildSection('Phân loại', [
                    _buildField(
                      controller: _sizesCtrl,
                      label: 'Kích thước (phân cách bằng dấu phẩy)',
                      icon: Icons.straighten_outlined,
                      hint: 'S, M, L, XL',
                    ),
                    _buildField(
                      controller: _colorsCtrl,
                      label: 'Màu sắc (phân cách bằng dấu phẩy)',
                      icon: Icons.palette_outlined,
                      hint: 'Đen, Trắng, Xanh',
                    ),
                  ]),

                  _buildSection('Đánh giá', [
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _ratingCtrl,
                            label: 'Rating (0-5)',
                            icon: Icons.star_outline,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _reviewCountCtrl,
                            label: 'Số đánh giá',
                            icon: Icons.rate_review_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ]),

                  _buildSection('Nhãn hiển thị', [
                    _buildToggleTile(
                      label: 'Sản phẩm mới (NEW)',
                      value: _isNew,
                      color: Colors.green,
                      onChanged: (v) => setState(() => _isNew = v),
                    ),
                    _buildToggleTile(
                      label: 'Đang giảm giá (SALE)',
                      value: _isSale,
                      color: Colors.red,
                      onChanged: (v) => setState(() => _isSale = v),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  // Nút lưu
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(
                          _isEditing ? Icons.save_outlined : Icons.add_circle_outline),
                      label: Text(
                        _isEditing ? 'Lưu thay đổi' : 'Thêm sản phẩm',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E8C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    final url = _imageUrlCtrl.text.trim();
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Nhập URL ảnh bên dưới để xem trước',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFFE91E8C),
            ),
          ),
        ),
        Card(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: children
                  .expand((w) => [w, const SizedBox(height: 10)])
                  .toList()
                ..removeLast(),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE91E8C), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE91E8C), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v!),
      decoration: InputDecoration(
        labelText: 'Danh mục *',
        prefixIcon: const Icon(Icons.category_outlined,
            color: Color(0xFFE91E8C), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFE91E8C), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required bool value,
    required Color color,
    required void Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
        ),
      ],
    );
  }
}
