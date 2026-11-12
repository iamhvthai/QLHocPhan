# Quản lý giảng viên (Flutter + Node/Express + MongoDB)

Database `QLHocPhan`, collection `GiangVien` với đúng 4 trường: `IDGV`, `Fullname`, `Image`, `SumClass` (cộng `_id` của MongoDB).

## Yêu cầu
Node.js >= 18, Flutter SDK, tài khoản MongoDB Atlas (cluster miễn phí, Network Access cho phép IP của bạn).

## Cấu hình backend
```powershell
cd server
copy .env.example .env     # rồi điền MONGODB_URI (tên DB: QLHocPhan), JWT_SECRET, ADMIN_USERNAME, ADMIN_PASSWORD
npm install
npm run seed               # tạo 5 giảng viên mẫu
npm run dev                # chạy API tại http://localhost:3000
```
Tài khoản admin mẫu: `admin` / `Admin@123` (đặt trong `.env`, không lưu trong DB).

## Chạy app
```powershell
flutter pub get
flutter run -d chrome      # web
flutter run                # Android (máy ảo dùng 10.0.2.2; điện thoại thật: sửa _lanOverride trong lib/config/api_config.dart thành IP LAN)
```
Trên Windows cần bật Developer Mode (`start ms-settings:developers`) để build plugin.

## Kiểm tra và xuất CSDL
```powershell
cd server
npm run verify:fields      # kiểm tra mọi bản ghi chỉ có _id, IDGV, Fullname, Image, SumClass
npm run export-db          # xuất ../database/GiangVien.json
```
