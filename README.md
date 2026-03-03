# FashionStore - Ứng dụng Thương Mại Điện Tử Thời Trang

> **Môn học:** Phát triển Ứng dụng Đa Nền Tảng (PTUDDD)
> **Bài thực hành:** TH3
> **Sinh viên:** Ngô Xuân Khánh — MSSV: 2351060453

---

## Mục lục

1. [Giới thiệu](#1-giới-thiệu)
2. [Tính năng](#2-tính-năng)
3. [Công nghệ sử dụng](#3-công-nghệ-sử-dụng)
4. [Cấu trúc dự án](#4-cấu-trúc-dự-án)
5. [Cấu trúc dữ liệu Firestore](#5-cấu-trúc-dữ-liệu-firestore)
6. [Cài đặt và Cấu hình](#6-cài-đặt-và-cấu-hình)
7. [Hướng dẫn sử dụng](#7-hướng-dẫn-sử-dụng)
8. [Kiến trúc ứng dụng](#8-kiến-trúc-ứng-dụng)
9. [Các màn hình](#9-các-màn-hình)
10. [Firestore Rules](#10-firestore-rules)
11. [Ghi chú](#11-ghi-chú)

---

## 1. Giới thiệu

**FashionStore** là ứng dụng thương mại điện tử thời trang xây dựng bằng **Flutter**, sử dụng **Firebase Cloud Firestore** làm backend thời gian thực. Ứng dụng hỗ trợ người dùng xem, lọc, tìm kiếm sản phẩm, quản lý giỏ hàng và cho phép admin quản lý danh mục sản phẩm trực tiếp trên ứng dụng.

---

## 2. Tính năng

### Người dùng

| Tính năng | Mô tả |
|-----------|-------|
| Danh sách sản phẩm | Hiển thị sản phẩm dạng GridView 2 cột, hỗ trợ pull-to-refresh |
| Lọc theo danh mục | Lọc theo: Tất cả / Áo / Quần / Váy / Áo khoác |
| Tìm kiếm | Tìm kiếm real-time theo tên; lọc thêm theo danh mục và sắp xếp theo giá / đánh giá |
| Chi tiết sản phẩm | Xem ảnh, mô tả, giá, thương hiệu, đánh giá sao, chọn size và màu sắc |
| Giỏ hàng | Thêm/xóa sản phẩm, tăng/giảm số lượng, tính tổng tiền, xác nhận đặt hàng |
| Badge giỏ hàng | Hiển thị số lượng sản phẩm trên icon giỏ hàng ở AppBar, cập nhật tức thời |
| Seed dữ liệu | Thêm dữ liệu mẫu vào Firestore khi database còn trống |
| Xử lý lỗi | Hiển thị trạng thái Loading / Success / Error với nút Retry |

### Admin (ẩn)

| Tính năng | Mô tả |
|-----------|-------|
| Truy cập ẩn | Nhấn **5 lần liên tiếp** vào tiêu đề "FashionStore" trên AppBar màn hình chính |
| Danh sách sản phẩm | Xem toàn bộ sản phẩm kèm ảnh, tên, giá, tồn kho, danh mục, nhãn New/Sale |
| Thêm sản phẩm | Form đầy đủ: tên, mô tả, giá, URL ảnh, thương hiệu, size, màu, tồn kho, v.v. |
| Chỉnh sửa sản phẩm | Nhấn vào sản phẩm để mở form chỉnh sửa với dữ liệu điền sẵn |
| Xóa sản phẩm | Xóa có hộp thoại xác nhận, danh sách cập nhật ngay lập tức |
| Làm mới | Nút refresh để tải lại danh sách từ Firestore |

---

## 3. Công nghệ sử dụng

| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| Flutter | SDK ^3.10.7 | Framework UI đa nền tảng |
| Dart | ^3.x | Ngôn ngữ lập trình |
| Firebase Core | ^3.13.0 | Khởi tạo và cấu hình Firebase |
| Cloud Firestore | ^5.6.6 | Cơ sở dữ liệu NoSQL thời gian thực |
| cached_network_image | ^3.4.1 | Load và cache ảnh từ URL mạng |
| shimmer | ^3.0.0 | Hiệu ứng skeleton loading khi chờ dữ liệu |
| Material 3 | — | Hệ thống thiết kế UI hiện đại |

---

## 4. Cấu trúc dự án

```
FashionStore/
├── lib/
│   ├── main.dart                        # Điểm vào ứng dụng, khởi tạo Firebase
│   ├── firebase_options.dart            # Cấu hình Firebase theo từng nền tảng
│   │
│   ├── models/
│   │   ├── product.dart                 # Model sản phẩm (fromFirestore / toFirestore)
│   │   └── cart_item.dart               # Model mục trong giỏ hàng
│   │
│   ├── services/
│   │   ├── firebase_service.dart        # CRUD sản phẩm với Firestore (Singleton)
│   │   └── cart_service.dart            # Quản lý giỏ hàng (Singleton + ChangeNotifier)
│   │
│   ├── screens/
│   │   ├── home_screen.dart             # Màn hình chính: danh sách, lọc danh mục, seed data
│   │   ├── product_detail_screen.dart   # Chi tiết sản phẩm, chọn size / màu
│   │   ├── search_screen.dart           # Tìm kiếm real-time, bộ lọc nâng cao
│   │   ├── cart_screen.dart             # Giỏ hàng, tính tổng, đặt hàng
│   │   ├── admin_screen.dart            # Trang quản trị sản phẩm (truy cập ẩn)
│   │   └── add_edit_product_screen.dart # Form thêm / chỉnh sửa sản phẩm
│   │
│   └── widgets/
│       ├── product_card.dart            # Card sản phẩm dùng trong GridView
│       └── app_error_widget.dart        # Widget hiển thị lỗi + nút Retry
│
├── assets/
│   └── images/                          # Ảnh tài nguyên cục bộ
│
├── firestore.rules                      # Quy tắc bảo mật Firestore
├── firestore.indexes.json               # Cấu hình index Firestore
├── firebase.json                        # Cấu hình Firebase CLI
└── pubspec.yaml                         # Khai báo dependencies và assets
```

---

## 5. Cấu trúc dữ liệu Firestore

### Collection: `products`

| Trường | Kiểu | Bắt buộc | Mô tả |
|--------|------|----------|-------|
| `name` | String | ✅ | Tên sản phẩm |
| `description` | String | ✅ | Mô tả sản phẩm |
| `price` | Number | ✅ | Giá bán (VNĐ) |
| `originalPrice` | Number | ❌ | Giá gốc trước khi giảm (nullable) |
| `imageUrl` | String | ✅ | URL ảnh sản phẩm |
| `category` | String | ✅ | Danh mục: `Áo` / `Quần` / `Váy` / `Áo khoác` / `Khác` |
| `brand` | String | ✅ | Tên thương hiệu |
| `rating` | Number | ✅ | Điểm đánh giá trung bình (0.0 – 5.0) |
| `reviewCount` | Number | ✅ | Số lượt đánh giá |
| `stock` | Number | ✅ | Số lượng tồn kho |
| `sizes` | Array\<String\> | ✅ | Các size có sẵn, vd: `["S","M","L","XL"]` |
| `colors` | Array\<String\> | ✅ | Các màu có sẵn, vd: `["Đen","Trắng","Xanh"]` |
| `isNew` | Boolean | ✅ | Đánh dấu sản phẩm mới (hiển thị nhãn "Mới") |
| `isSale` | Boolean | ✅ | Đánh dấu đang giảm giá (hiển thị nhãn "Sale") |

**Ví dụ một document:**

```json
{
  "name": "Áo thun basic unisex",
  "description": "Áo thun cotton 100%, form suông thoải mái.",
  "price": 199000,
  "originalPrice": 299000,
  "imageUrl": "https://example.com/images/ao-thun.jpg",
  "category": "Áo",
  "brand": "LocalBrand",
  "rating": 4.5,
  "reviewCount": 128,
  "stock": 50,
  "sizes": ["S", "M", "L", "XL", "XXL"],
  "colors": ["Đen", "Trắng", "Xám"],
  "isNew": false,
  "isSale": true
}
```

---

## 6. Cài đặt và Cấu hình

### Yêu cầu môi trường

- Flutter SDK ≥ 3.10.7
- Dart SDK ≥ 3.x
- Android Studio hoặc Visual Studio Code
- Tài khoản Firebase (Google Account)

### Bước 1: Clone dự án

```bash
git clone <repository-url>
cd FashionStore
```

### Bước 2: Tạo Project Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Nhấn **Add project** → đặt tên project → **Create project**
3. Vào **Firestore Database** → **Create database** → chọn **Start in test mode** → chọn region `asia-southeast1`

### Bước 3: Kết nối Firebase (Khuyên dùng FlutterFire CLI)

```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Kết nối project và tự động tạo firebase_options.dart
flutterfire configure
```

> **Thủ công:** Thêm app Android/iOS trong Firebase Console → tải `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS) → đặt vào đúng thư mục → cập nhật `lib/firebase_options.dart`.

### Bước 4: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 5: Chạy ứng dụng

```bash
# Android hoặc iOS (cần thiết bị / emulator)
flutter run

# Web
flutter run -d chrome

# Windows Desktop
flutter run -d windows
```

---

## 7. Hướng dẫn sử dụng

### Màn hình chính

- Khởi động app → danh sách sản phẩm hiển thị dạng lưới 2 cột.
- Nếu database trống, nhấn nút **"Thêm dữ liệu mẫu"** để seed sản phẩm vào Firestore.
- Nhấn các tab danh mục (Áo / Quần / Váy / Áo khoác) để lọc.
- Kéo xuống để **làm mới** danh sách.
- Nhấn vào card sản phẩm để xem chi tiết.
- Nhấn icon **kính lúp** để vào màn hình tìm kiếm.
- Nhấn icon **giỏ hàng** để xem giỏ hàng.

### Tìm kiếm

- Gõ từ khóa → kết quả lọc theo **tên sản phẩm** theo thời gian thực.
- Nhấn icon **bộ lọc** để mở tùy chọn nâng cao:
  - Lọc theo danh mục
  - Sắp xếp: Mặc định / Giá tăng dần / Giá giảm dần / Đánh giá cao nhất

### Chi tiết sản phẩm

- Xem ảnh lớn, mô tả đầy đủ, đánh giá sao, thông tin thương hiệu.
- Chọn **size** và **màu sắc** trước khi thêm vào giỏ.
- Chỉnh **số lượng** (giới hạn bởi tồn kho thực tế).
- Nhấn **"Thêm vào giỏ hàng"** → SnackBar xác nhận xuất hiện, badge trên icon cập nhật ngay.

### Giỏ hàng

- Xem danh sách sản phẩm đã chọn: ảnh, tên, size, màu, đơn giá, số lượng.
- Tăng/giảm số lượng từng mục bằng nút `+` / `-`.
- Vuốt trái hoặc nhấn nút xóa để loại bỏ một sản phẩm.
- Nhấn **"Xóa tất cả"** để dọn sạch giỏ (có hộp thoại xác nhận).
- Nhấn **"Đặt hàng"** → xác nhận → giỏ hàng được xóa, SnackBar thông báo thành công.

### Trang Admin (ẩn)

> Dành cho người quản lý — người dùng thông thường **không biết** đường vào.

**Cách mở:**  
Trên màn hình chính, nhấn **5 lần liên tiếp** (trong vòng 2 giây) vào chữ **"FashionStore"** trên AppBar.

**Chức năng:**
- Danh sách toàn bộ sản phẩm trong Firestore.
- Nhấn **"+ Thêm sản phẩm"** để nhập sản phẩm mới.
- Nhấn vào sản phẩm → **Sửa** để chỉnh sửa thông tin.
- Nhấn vào sản phẩm → **Xóa** → xác nhận để xóa khỏi Firestore.
- Nhấn icon **refresh** để tải lại danh sách.

---

## 8. Kiến trúc ứng dụng

Dự án áp dụng kiến trúc phân lớp đơn giản:

```
UI Layer       →  Screens & Widgets
                       ↕
Service Layer  →  FirebaseService, CartService
                       ↕
Data Layer     →  Cloud Firestore / In-memory state
```

### Design Patterns áp dụng

| Pattern | Nơi áp dụng | Mục đích |
|---------|-------------|----------|
| **Singleton** | `FirebaseService`, `CartService` | Đảm bảo chỉ một instance xuyên suốt vòng đời app |
| **ChangeNotifier** | `CartService` | Notify UI khi trạng thái giỏ hàng thay đổi |
| **ListenableBuilder** | AppBar badge, CartScreen | Lắng nghe `CartService` và rebuild widget đúng chỗ |
| **Factory constructor** | `Product.fromFirestore()` | Ánh xạ dữ liệu Firestore sang model Dart |
| **Repository-like** | `FirebaseService` | Tách biệt logic truy cập dữ liệu khỏi UI |

### Luồng dữ liệu chính

```
Firestore ──► FirebaseService.getProducts()
           ──► HomeScreen._loadProducts() ──► setState ──► GridView ──► ProductCard

ProductCard ──► "Thêm vào giỏ" ──► CartService.addItem()
            ──► notifyListeners() ──► ListenableBuilder rebuild ──► Badge số lượng cập nhật
```

---

## 9. Các màn hình

| Màn hình | File | Chức năng chính |
|----------|------|-----------------|
| Home | `screens/home_screen.dart` | Danh sách GridView, filter danh mục, seed data, truy cập admin ẩn |
| Chi tiết | `screens/product_detail_screen.dart` | Thông tin sản phẩm đầy đủ, chọn size/màu, thêm giỏ hàng |
| Tìm kiếm | `screens/search_screen.dart` | Tìm kiếm real-time, filter & sort nâng cao |
| Giỏ hàng | `screens/cart_screen.dart` | Quản lý giỏ, tính tổng tiền, xác nhận đặt hàng |
| Admin | `screens/admin_screen.dart` | CRUD sản phẩm, truy cập ẩn bằng 5 lần nhấn tiêu đề |
| Thêm/Sửa | `screens/add_edit_product_screen.dart` | Form nhập liệu đầy đủ, validation, lưu lên Firestore |

---

## 10. Firestore Rules

File `firestore.rules`:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if true;   // Tất cả người dùng đều đọc được
      allow write: if true;  // Test mode - cho phép ghi không cần xác thực
    }
  }
}
```

> **Cảnh báo bảo mật:** Cấu hình hiện tại là **test mode** dùng cho bài thực hành.  
> Trong môi trường sản phẩm thực tế cần tích hợp **Firebase Authentication** và đặt quy tắc:
> ```js
> allow write: if request.auth != null && request.auth.token.admin == true;
> ```

---

## 11. Ghi chú

- Ứng dụng **không yêu cầu đăng nhập** — phù hợp với phạm vi bài thực hành.
- **Seed data** chỉ nên chạy một lần khi khởi tạo database lần đầu.
- Giỏ hàng lưu **trong bộ nhớ** (không lưu ổ đĩa) — thoát app sẽ mất dữ liệu giỏ hàng.
- Ảnh sản phẩm load từ URL mạng, được cache bằng `cached_network_image`.
- Trang Admin **cố tình ẩn** (nhấn 5 lần vào tiêu đề) để người dùng bình thường không phát hiện.
- Màu chủ đạo của app: hồng đậm `#E91E8C` (người dùng) và đen `#333333` (admin).
