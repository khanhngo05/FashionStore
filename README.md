# FashionStore - Ứng dụng Thời Trang Flutter

> **Môn học:** Phát triển ứng dụng di động đa nền tảng  
> **Sinh viên:** Ngô Xuân Khánh - MSSV: 2351060453  
> **Bài thực hành:** TH3

## Mô tả ứng dụng

Ứng dụng FashionStore là ứng dụng thương mại điện tử thời trang xây dựng bằng Flutter, kết nối Firebase Firestore làm backend. Ứng dụng cho phép xem danh sách sản phẩm thời trang, lọc theo danh mục, và xem chi tiết sản phẩm.

## Tính năng

- Hiển thị danh sách sản phẩm dạng GridView (2 cột)
- Lọc sản phẩm theo danh mục (Áo, Quần, Váy, Áo khoác)
- Xem chi tiết sản phẩm (giá, size, màu sắc, mô tả)
- Xử lý 3 trạng thái: Loading, Success, Error với nút Retry
- Pull-to-refresh để làm mới danh sách
- Seed dữ liệu mẫu vào Firestore

## Cấu trúc thư mục

```
lib/
├── main.dart                       # Điểm vào ứng dụng, khởi tạo Firebase
├── firebase_options.dart           # Cấu hình Firebase (cần điền thông tin thực)
├── models/
│   └── product.dart                # Model sản phẩm, map dữ liệu Firestore
├── services/
│   └── firebase_service.dart       # Các hàm gọi Firestore (có try-catch)
├── screens/
│   ├── home_screen.dart            # Màn hình chính GridView + 3 trạng thái
│   └── product_detail_screen.dart  # Màn hình chi tiết sản phẩm
└── widgets/
    ├── product_card.dart           # Widget card sản phẩm
    └── app_error_widget.dart       # Widget hiển thị lỗi + nút Retry
```

## Hướng dẫn cấu hình Firebase

### Bước 1: Tạo project Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Nhấn **"Add project"** và đặt tên project
3. Nhấn **Create project**

### Bước 2: Thêm ứng dụng Android

1. Trong Firebase Console → **"Add app"** → chọn Android
2. Package name: `com.example.fashion_store`
3. Tải file **`google-services.json`**
4. Thay thế `android/app/google-services.json` bằng file vừa tải

### Bước 3: Thiết lập Firestore Database

1. Firebase Console → **Firestore Database** → **Create database**
2. Chọn **Start in test mode**
3. Chọn vùng server (vd: `asia-southeast1`)

### Bước 4: Cập nhật firebase_options.dart

Thay thế các giá trị `YOUR_*` trong `lib/firebase_options.dart` bằng thông tin từ:
Firebase Console → Project Settings → Your apps → SDK setup and configuration

### Bước 5 (Khuyên dùng - FlutterFire CLI)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

## Cài đặt và chạy

```bash
flutter pub get
flutter run
```

## Cấu trúc Firestore (collection: `products`)

| Trường | Kiểu | Mô tả |
|--------|------|-------|
| name | String | Tên sản phẩm |
| description | String | Mô tả |
| price | Number | Giá bán |
| originalPrice | Number | Giá gốc (nullable) |
| imageUrl | String | URL ảnh |
| category | String | Danh mục |
| brand | String | Thương hiệu |
| rating | Number | Điểm đánh giá |
| reviewCount | Number | Số lượt đánh giá |
| stock | Number | Số lượng tồn |
| sizes | Array | Các size |
| colors | Array | Các màu |
| isNew | Boolean | Sản phẩm mới |
| isSale | Boolean | Đang giảm giá |

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
