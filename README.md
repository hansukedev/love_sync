# Love Sync ❤️

![Build Status](https://github.com/hansukedev/love_sync/actions/workflows/android_build.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**Love Sync** là ứng dụng di động dành riêng cho các cặp đôi, giúp "đồng bộ" cảm xúc và giữ lửa tình yêu theo thời gian thực. Ứng dụng được xây dựng bằng **Flutter** với phong cách thiết kế **White Liquid Glassmorphism** (Kính trắng tinh tế).

---

## ✨ Tính Năng Nổi Bật

* **🎨 Giao diện Glassmorphism:** Thiết kế hiện đại, sang trọng với hiệu ứng kính mờ và tông màu trắng chủ đạo.
* **🔗 Ghép đôi (Pairing):** Kết nối hai người dùng thông qua mã Code bảo mật 6 ký tự.
* **🥰 Đồng bộ Cảm xúc (Mood Sync):** Cập nhật trạng thái (Vui, Buồn, Nhớ...) theo thời gian thực (Realtime). Máy đối phương sẽ thay đổi màu sắc và nhận thông báo ngay lập tức.
* **📅 Đếm ngày yêu:** Lưu giữ kỷ niệm từ ngày bắt đầu quen nhau.
* **☁️ Cloud Sync:** Dữ liệu được đồng bộ tức thì qua Firebase Realtime Database.
* **🔒 Riêng tư & Bảo mật:** Hỗ trợ đăng nhập ẩn danh hoặc Google, dữ liệu được bảo vệ an toàn.

---

## 🛠️ Công Nghệ Sử Dụng

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Backend:** Google Firebase
    * Firebase Auth (Google & Anonymous Login)
    * Firebase Realtime Database
* **State Management:** Provider
* **CI/CD:** GitHub Actions (Tự động Build APK & Release)

---

## 🚀 Hướng Dẫn Cài Đặt (Local Development)

Nếu bạn muốn tải mã nguồn về và chạy trên máy tính cá nhân:

### 1. Yêu cầu
* Flutter SDK đã được cài đặt và cấu hình.
* Tài khoản Firebase.

### 2. Clone dự án
```bash
git clone [https://github.com/hansukedev/love_sync.git](https://github.com/hansukedev/love_sync.git)
cd love_sync
flutter pub get
```
### 3. Cấu hình Firebase (Bắt buộc)
Vì lý do bảo mật, các file cấu hình Firebase (`google-services.json`, `firebase_options.dart`) không được công khai trên GitHub. Bạn cần tạo project Firebase riêng:

1.  Cài đặt FlutterFire CLI (nếu chưa có):
    ```bash
    dart pub global activate flutterfire_cli
    ```
2.  Chạy lệnh cấu hình và chọn project của bạn:
    ```bash
    flutterfire configure
    ```
3.  Tải file `google-services.json` từ Firebase Console và đặt vào thư mục `android/app/` (nếu lệnh trên chưa tự tạo).

### 4. Chạy ứng dụng
```bash
flutter run
```
## 📦 Tải Xuống (Download)

Phiên bản mới nhất (APK) được build tự động thông qua GitHub Actions và có sẵn tại mục **Releases**.

👉 [**Tải về file APK tại đây**](https://github.com/hansukedev/love_sync/releases)

---

## 🤝 Đóng Góp

Mọi đóng góp đều được hoan nghênh! Nếu bạn tìm thấy lỗi hoặc có ý tưởng mới, hãy tạo **Issue** hoặc gửi **Pull Request**.

## 📄 Giấy Phép

Dự án này được phát hành dưới giấy phép [MIT License](LICENSE).
