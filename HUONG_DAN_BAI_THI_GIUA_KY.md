# Bài thi giữa kỳ: Ứng dụng quản lý giảng viên (Flutter + MongoDB)

> **Gửi AI code:** Hãy đọc toàn bộ file này trước, sau đó thực hiện **tuần tự từng bước**. Sau mỗi bước phải chạy và kiểm tra theo mục "Hoàn thành khi". Chỉ sang bước tiếp theo khi bước hiện tại đã đạt. Nếu bị chặn (thiếu Node, thiếu MongoDB, lỗi môi trường), hãy dừng lại và báo cho người dùng, đừng tự đổi hướng.

---

## 0. Đề bài và ràng buộc bắt buộc

**Đề thi giữa kỳ (Lập trình đa nền tảng, đề mở):** Xây dựng app **nhập, hiển thị, sửa, xóa** người dùng trong cơ sở dữ liệu Học phần (**`QLHocPhan`**) chứa collection giảng viên (**`GiangVien`**) ở phân hệ admin. Dùng Flutter hoặc React Native, .NET MAUI (bài này dùng **Flutter**).

| Yêu cầu | Điểm | Cách đáp ứng trong project này |
|---|---|---|
| 1. Dùng cơ sở dữ liệu Firebase hoặc MongoDB, thực hiện thêm, hiển thị các trường: `IDGV, Fullname, Image, SumClass` (Mã giảng viên, họ và tên, hình ảnh, tổng số lớp). **Chạy trên nền tảng web** | 8.0 | Flutter Web + backend Node/Express + **MongoDB** (database `QLHocPhan`, collection `GiangVien`), đủ CRUD |
| 2. Đăng nhập, xóa, sửa, các chức năng nâng cao khác | 1.5 | Đăng nhập admin (JWT), sửa, xóa có xác nhận, tìm kiếm, phân trang, thống kê tổng số lớp |
| 3. Nhập được hình ảnh và hiển thị thông tin người dùng (**trên nền tảng di động**) | 0.5 | Chạy bản Android (máy ảo), chọn ảnh từ thư viện hoặc camera, xem chi tiết |

### Kết quả phải nộp (người dùng tự làm, AI không viết)
- File báo cáo chi tiết các bước thực hiện, ảnh chụp minh họa, lệnh tải thư viện liên quan, ảnh chụp CSDL; **nộp file cơ sở dữ liệu (json, sql…)**.
- Link GitHub source code.
- Link video demo.

### ⚠️ CHÚ Ý QUAN TRỌNG (đề nhấn mạnh, vi phạm có thể bị trừ điểm nặng)

1. **Chỉ chấp nhận cơ sở dữ liệu gồm đúng 4 trường: `IDGV`, `Fullname`, `Image`, `SumClass`. Không tự bổ sung thêm trường.**
   - MongoDB tự tạo `_id` làm khóa chính mặc định, đây là trường hệ thống và được chấp nhận.
   - Trong Mongoose **bắt buộc** đặt `versionKey: false` và `timestamps: false` để không sinh `__v`, `createdAt`, `updatedAt`.
   - Tuyệt đối không thêm `email`, `matkhau`, `role`, `avatarUrl`... vào collection `GiangVien`.
2. **Bắt buộc có file cơ sở dữ liệu để nộp** (JSON). Bước 10 tạo file này bằng script.
3. Tên database là **`QLHocPhan`**, tên collection là **`GiangVien`**, tên trường viết **đúng chính tả, đúng hoa thường** như trên: `IDGV`, `Fullname`, `Image`, `SumClass`.
4. **Đăng nhập admin không lưu trong collection `GiangVien`** (vì không được thêm trường). Tài khoản admin lấy từ biến môi trường `ADMIN_USERNAME`, `ADMIN_PASSWORD` trong `server/.env`. Xem mục 4.3.

### Ý nghĩa các trường

| Trường | Kiểu | Ý nghĩa | Ràng buộc |
|---|---|---|---|
| `IDGV` | String | Mã giảng viên (ví dụ `GV001`) | Bắt buộc, duy nhất, tự in hoa, bỏ khoảng trắng |
| `Fullname` | String | Họ và tên | Bắt buộc |
| `Image` | String | Hình ảnh, lưu dạng data URI base64 `data:image/jpeg;base64,...` | Tùy chọn, rỗng hoặc bắt đầu bằng `data:image/` |
| `SumClass` | Number | Tổng số lớp giảng viên phụ trách | Số nguyên >= 0, mặc định 0 |

### Phạm vi công việc
- **AI code làm:** toàn bộ code (backend, Flutter), script seed/kiểm tra/xuất DB, `.gitignore`, `README.md` chạy dự án.
- **Người dùng tự làm:** file báo cáo, chụp ảnh minh họa, đẩy GitHub, quay video demo. **Không viết các phần này.**

---

## 1. Kiến trúc và lý do

```
Flutter (Web / Android)  --HTTP JSON-->  Node.js + Express  --Mongoose-->  MongoDB Atlas (cloud)
                                                                           DB: QLHocPhan
                                                                           Collection: GiangVien
```

**Vì sao cần backend:** Flutter Web chạy trong trình duyệt, không thể mở kết nối TCP trực tiếp tới MongoDB. Nhúng chuỗi kết nối DB vào app cũng lộ mật khẩu. Vì vậy dùng API trung gian. **Không dùng package `mongo_dart`.**

### Cấu trúc thư mục

```
flutter_middterm_crud_application/
├── server/
│   ├── package.json
│   ├── .env                  (KHÔNG commit)
│   ├── .env.example
│   ├── src/
│   │   ├── index.js
│   │   ├── config/db.js
│   │   ├── models/GiangVien.js
│   │   ├── middleware/auth.js
│   │   ├── utils/publicGiangVien.js
│   │   └── routes/
│   │       ├── auth.routes.js
│   │       └── giangvien.routes.js
│   └── scripts/
│       ├── seed.js
│       ├── verifyFields.js
│       └── exportDb.js
├── lib/                      (project Flutter hiện có ở thư mục gốc)
│   ├── main.dart
│   ├── config/api_config.dart
│   ├── models/giang_vien.dart
│   ├── services/api_service.dart
│   ├── services/token_storage.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── giangvien_list_screen.dart
│   │   ├── giangvien_form_screen.dart
│   │   └── giangvien_detail_screen.dart
│   └── widgets/
│       └── giangvien_avatar.dart
├── database/                 (GiangVien.json được xuất ra đây)
├── .gitignore
└── README.md
```

Môi trường người dùng: **Windows + PowerShell**, Flutter đã cài, đã có máy ảo Android. Project Flutter đã tồn tại ở `E:\flutter\flutter_middterm_crud_application` (hỗ trợ web), **dùng luôn project này**, không tạo project Flutter mới. Chỉ cần thêm nền tảng Android nếu thiếu: `flutter create --platforms=android .`

---

## 2. Quy tắc làm việc

- UI hiển thị bằng **tiếng Việt**, code và tên biến bằng tiếng Anh (riêng tên DB, collection, 4 tên trường giữ đúng như đề).
- Làm **web trước** (build nhanh, ăn 8 điểm), kiểm thử Android **sau cùng**.
- Mật khẩu admin **không bao giờ** log ra console hay commit.
- Mỗi route phải xử lý lỗi và trả JSON dạng `{ "message": "..." }` với mã HTTP đúng (400, 401, 404, 409, 500).
- Không thêm thư viện thừa. Quản lý state bằng `setState`, không cần Provider/Bloc.
- Chạy `flutter analyze` ở cuối mỗi bước Flutter, không để lỗi (error).

---

## 3. Các bước thực hiện

### Bước 1. Kiểm tra môi trường

```powershell
node -v
npm -v
git --version
flutter doctor -v
```

- Cần Node.js >= 18. Nếu thiếu, **dừng lại và yêu cầu người dùng cài** (nodejs.org, bản LTS).
- **CSDL dùng MongoDB Atlas (cloud).** Người dùng tự tạo cluster và lấy chuỗi kết nối, dạng:
  `mongodb+srv://<user>:<password>@<cluster>.mongodb.net/QLHocPhan?retryWrites=true&w=majority`
  - Hỏi người dùng dán chuỗi này để đưa vào `server/.env` (biến `MONGODB_URI`). Nếu chưa có thì **dừng lại và nhắc người dùng setup Atlas**.
  - Tên database trong chuỗi kết nối phải là **`/QLHocPhan`** ngay sau `.mongodb.net`, nếu thiếu thì dữ liệu bị ghi vào database mặc định `test`.
  - Nếu mật khẩu có ký tự đặc biệt (`@ : / ? # %`), phải **mã hóa URL** (ví dụ `@` thành `%40`) hoặc đổi sang mật khẩu chỉ có chữ và số.
  - Tuyệt đối không ghi chuỗi kết nối vào code, README hay file nào được commit. Chỉ nằm trong `server/.env`.
- Chạy `git init` ở thư mục gốc nếu chưa có, tạo `.gitignore` (xem Bước 11).

**Hoàn thành khi:** có Node >= 18, có `MONGODB_URI` dùng được.

---

### Bước 2. Khởi tạo backend

```powershell
mkdir server
cd server
npm init -y
npm install express mongoose cors dotenv jsonwebtoken
npm install -D nodemon
```

- Sửa `package.json`:

```json
"scripts": {
  "start": "node src/index.js",
  "dev": "nodemon src/index.js",
  "seed": "node scripts/seed.js",
  "verify:fields": "node scripts/verifyFields.js",
  "export-db": "node scripts/exportDb.js"
}
```

- Tạo `.env.example` (và `.env` có giá trị thật):

```env
PORT=3000
MONGODB_URI=mongodb+srv://USER:PASSWORD@CLUSTER.mongodb.net/QLHocPhan?retryWrites=true&w=majority
JWT_SECRET=doi_thanh_chuoi_bi_mat_dai
JWT_EXPIRES_IN=7d
ADMIN_USERNAME=admin
ADMIN_PASSWORD=Admin@123
```

**Hoàn thành khi:** `npm install` thành công, có `.env` và `.env.example`.

---

### Bước 3. Model `GiangVien` (đúng 4 trường)

`server/src/models/GiangVien.js`:

```js
const mongoose = require('mongoose');

const giangVienSchema = new mongoose.Schema(
  {
    IDGV:     { type: String, required: true, unique: true, trim: true, uppercase: true },
    Fullname: { type: String, required: true, trim: true },
    Image:    { type: String, default: '' },   // data URI base64: "data:image/jpeg;base64,...."
    SumClass: { type: Number, required: true, default: 0, min: 0, validate: Number.isInteger },
  },
  {
    versionKey: false,   // BẮT BUỘC: không tạo __v
    timestamps: false,   // BẮT BUỘC: không tạo createdAt/updatedAt
    strict: true,        // bỏ qua mọi trường lạ
    collection: 'GiangVien',
  }
);

module.exports = mongoose.model('GiangVien', giangVienSchema);
```

Quyết định thiết kế (giữ nguyên):
- **`Image` lưu chuỗi base64** (data URI) trong chính trường này để không cần thêm trường và file DB xuất ra chứa luôn ảnh.
- Database tên `QLHocPhan` được xác định bằng chuỗi kết nối.

`server/src/utils/publicGiangVien.js`: chuyển document thành object gửi client, đổi `_id` thành `id`:

```js
module.exports = (g) => ({
  id: g._id.toString(),
  IDGV: g.IDGV,
  Fullname: g.Fullname,
  Image: g.Image || '',
  SumClass: g.SumClass ?? 0,
});
```

`server/src/config/db.js`: kết nối Atlas bằng `mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 })`, in log thành công (kèm tên database đang dùng, phải là `QLHocPhan`), thất bại thì in thông báo gợi ý rồi `process.exit(1)`:
- Lỗi `bad auth` / `Authentication failed`: sai user hoặc mật khẩu trong chuỗi kết nối.
- Lỗi `ENOTFOUND` / `querySrv` / `Server selection timed out`: IP chưa được thêm vào **Network Access** của Atlas, hoặc mạng/DNS chặn. Gợi ý thêm `0.0.0.0/0`, đổi DNS sang 8.8.8.8 hoặc thử mạng khác.

**Hoàn thành khi:** schema đúng 4 trường, có `versionKey: false` và `timestamps: false`.

---

### Bước 4. API backend

#### 4.1. `src/index.js`
- `dotenv.config()`, `express()`, `cors()` (cho phép mọi origin khi dev), `express.json({ limit: '5mb' })` (vì ảnh base64).
- Route `GET /api/health` trả `{ ok: true }`.
- Mount `/api/auth` và `/api/giangvien`.
- Middleware bắt lỗi chung ở cuối, **lắng nghe `0.0.0.0`** để máy ảo/điện thoại truy cập được:

```js
app.listen(PORT, '0.0.0.0', () => console.log(`Server chạy cổng ${PORT}`));
```

#### 4.2. `src/middleware/auth.js`
- Đọc header `Authorization: Bearer <token>`, verify bằng `JWT_SECRET`, gắn `req.auth = { username }`. Sai hoặc thiếu token trả **401**.

#### 4.3. Phân hệ admin (không lưu trong DB)
- Admin là tài khoản cấu hình trong `.env` (`ADMIN_USERNAME`, `ADMIN_PASSWORD`). Collection `GiangVien` chỉ chứa dữ liệu giảng viên với đúng 4 trường.
- Đăng nhập đúng thì server cấp JWT. Mọi API quản lý giảng viên đều cần token.
- So sánh mật khẩu bằng `crypto.timingSafeEqual` (hoặc so sánh chuỗi đơn giản vì đây là bài thi).

#### 4.4. `src/routes/auth.routes.js`

| Method | Đường dẫn | Mô tả |
|---|---|---|
| POST | `/api/auth/login` | Body `{ username, password }`. Khớp với `.env` thì trả `{ token, username }`. Sai trả 401 "Tên đăng nhập hoặc mật khẩu không đúng" |
| GET | `/api/auth/me` | (cần token) trả `{ username }`, dùng kiểm tra phiên khi mở lại app |

#### 4.5. `src/routes/giangvien.routes.js` (tất cả cần token)

| Method | Đường dẫn | Mô tả |
|---|---|---|
| GET | `/api/giangvien?search=&page=1&limit=10` | Tìm theo `IDGV` hoặc `Fullname` (không phân biệt hoa thường, **escape ký tự regex** của chuỗi tìm kiếm). Trả `{ data, page, limit, total, totalPages, totalSumClass }` (`totalSumClass` là tổng `SumClass` của kết quả tìm, dùng aggregate) |
| GET | `/api/giangvien/:id` | Chi tiết một giảng viên. ID sai định dạng hoặc không tồn tại trả 404 |
| POST | `/api/giangvien` | Thêm |
| PUT | `/api/giangvien/:id` | Sửa `IDGV`, `Fullname`, `Image`, `SumClass` |
| DELETE | `/api/giangvien/:id` | Xóa. Không tồn tại trả 404 |

**Validate phía server (bắt buộc):**
- `IDGV`: không rỗng. Trùng mã (lỗi Mongo code `11000`) trả **409** "Mã giảng viên đã tồn tại".
- `Fullname`: không rỗng.
- `SumClass`: số nguyên >= 0 (chấp nhận số hoặc chuỗi số, ép về `Number`), sai trả 400.
- `Image`: rỗng hoặc bắt đầu bằng `data:image/`, độ dài <= khoảng 2.000.000 ký tự, nếu quá trả 400 "Ảnh quá lớn".
- Chỉ lấy đúng 4 trường từ `req.body` (destructure), **không** truyền thẳng `req.body` vào model.

**Hoàn thành khi:** code đầy đủ, server khởi động và in log đã kết nối MongoDB, database `QLHocPhan`.

---

### Bước 5. Script seed

`server/scripts/seed.js`: kết nối DB, tạo (upsert theo `IDGV`, **không xóa dữ liệu có sẵn** trừ khi chạy với `--reset`):

| IDGV | Fullname | Image | SumClass |
|---|---|---|---|
| GV001 | Nguyễn Văn An | (rỗng) | 3 |
| GV002 | Trần Thị Bình | (rỗng) | 4 |
| GV003 | Lê Minh Chi | (rỗng) | 2 |
| GV004 | Phạm Quốc Dũng | (rỗng) | 5 |
| GV005 | Hoàng Thu Hà | (rỗng) | 1 |

In ra tài khoản admin (lấy từ `.env`) để người dùng đăng nhập. Ảnh thật sẽ được thêm qua giao diện app.

```powershell
npm run seed
```

**Hoàn thành khi:** seed chạy thành công, chạy lần 2 không bị lỗi trùng.

---

### Bước 6. Kiểm thử API trước khi làm Flutter

Chạy `npm run dev` ở một terminal, terminal khác test bằng `curl.exe` (trên PowerShell phải gõ `curl.exe`, không phải `curl`):

```powershell
curl.exe http://localhost:3000/api/health
curl.exe -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"Admin@123\"}"
```

Dùng token nhận được để thử `GET/POST/PUT/DELETE /api/giangvien`. Kiểm tra các trường hợp lỗi: thiếu token (401), trùng `IDGV` (409), ID sai (404), `SumClass` âm hoặc không phải số (400), đăng nhập sai (401).

**Hoàn thành khi:** toàn bộ endpoint hoạt động đúng như bảng ở Bước 4.

---

### Bước 7. Cấu hình Flutter và tầng dữ liệu

Dùng project Flutter hiện có ở thư mục gốc:

```powershell
flutter pub add http image_picker shared_preferences
flutter create --platforms=android,web .
```

#### Cấu hình Android (bắt buộc để gọi API từ máy ảo)

Mở `android/app/src/main/AndroidManifest.xml`:
1. Thêm quyền trước thẻ `<application>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
2. Thêm thuộc tính vào thẻ `<application>` (Android 9+ chặn HTTP thường):
   ```xml
   android:usesCleartextTraffic="true"
   ```

#### Địa chỉ API: `lib/config/api_config.dart`

Không dùng `dart:io` (không chạy được trên web). Dùng `foundation`:

```dart
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Máy ảo Android: 10.0.2.2 trỏ về localhost của máy tính.
  // Điện thoại thật: đổi thành IP LAN của máy tính, ví dụ 'http://192.168.1.10:3000/api'.
  static const String _lanOverride = '';

  static String get baseUrl {
    if (_lanOverride.isNotEmpty) return _lanOverride;
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }
}
```

**Lưu ý môi trường:** lần build Android đầu có thể mất vài phút. Nếu gặp lỗi Gradle `Read timed out` hoặc thiếu NDK, **dừng lại và báo người dùng**. Trong lúc đó vẫn phát triển tiếp trên Chrome.

#### Tầng dữ liệu
- `models/giang_vien.dart`: class `GiangVien { id, idgv, fullname, image, sumClass }` với `fromJson`, `toJson`. JSON dùng đúng khóa `IDGV`, `Fullname`, `Image`, `SumClass`.
- `services/token_storage.dart`: lưu, đọc, xóa token bằng `shared_preferences`.
- `services/api_service.dart`:
  - Các hàm: `login`, `me`, `getGiangVien({search, page, limit})`, `getOne`, `create`, `update`, `delete`.
  - Tự gắn header `Authorization: Bearer <token>` và `Content-Type: application/json`.
  - Có `timeout` (ví dụ 15 giây).
  - Khi lỗi, ném `ApiException(message, statusCode)` với `message` lấy từ JSON `{message}`. Nếu mất kết nối, thông báo "Không kết nối được máy chủ".
  - Nếu nhận **401** (trừ lúc login), xóa token và đưa người dùng về màn hình đăng nhập.

**Hoàn thành khi:** `flutter analyze` sạch lỗi và `flutter run -d chrome` mở được app.

---

### Bước 8. Giao diện Flutter

Giao diện hiện đại, Material 3, màu chủ đạo xanh dương, **giới hạn chiều rộng tối đa khoảng 1000px và căn giữa** để web trông đẹp.

#### `widgets/giangvien_avatar.dart`
Nhận `Image` (chuỗi data URI). Nếu rỗng hiện icon người, nếu có thì bỏ tiền tố `data:image/...;base64,` rồi `base64Decode` và hiển thị bằng `Image.memory` (`gaplessPlayback: true`, có `errorBuilder` hiện icon lỗi). Dùng `CircleAvatar` hoặc bo góc.

#### `screens/login_screen.dart`
- Ô tên đăng nhập, ô mật khẩu (có nút ẩn/hiện), nút "Đăng nhập" có trạng thái loading.
- Validate không rỗng, hiển thị lỗi từ server.
- Thành công: lưu token, chuyển sang danh sách (`pushReplacement`).

#### `main.dart`
- Màn hình khởi động: nếu có token thì gọi `me`. Hợp lệ vào danh sách, không thì vào đăng nhập.

#### `screens/giangvien_list_screen.dart` (trang admin chính)
- AppBar: tiêu đề "Quản lý giảng viên", hiển thị tên admin đang đăng nhập, nút "Đăng xuất".
- Ô **tìm kiếm** (debounce khoảng 400ms) theo mã GV/họ tên.
- **Phân trang**: nút trước/sau, hiển thị "Trang x / y", tổng số giảng viên và tổng số lớp (`totalSumClass`).
- **Bố cục responsive** bằng `LayoutBuilder`:
  - Rộng >= 800px (web): `DataTable` với cột **Ảnh, IDGV, Fullname, SumClass, Thao tác** (xem, sửa, xóa).
  - Hẹp (di động): `ListView` dạng `Card`, mỗi mục có ảnh, họ tên, mã GV, tổng số lớp, bấm vào để xem chi tiết, menu sửa/xóa.
- Nút thêm (FAB hoặc nút "Thêm giảng viên").
- **Xóa có hộp thoại xác nhận**, xóa xong tải lại danh sách và hiện `SnackBar`.
- Có trạng thái loading, danh sách trống ("Không có giảng viên nào"), hiển thị lỗi kèm nút "Thử lại".

#### `screens/giangvien_form_screen.dart` (dùng chung cho Thêm và Sửa)
- Trường: `IDGV` (Mã giảng viên), `Fullname` (Họ và tên), `SumClass` (Tổng số lớp, bàn phím số, số nguyên >= 0), `Image` (Hình ảnh).
- Chọn ảnh bằng `image_picker`:
  - Nút "Chọn từ thư viện" (cả web và di động).
  - Nút "Chụp ảnh" **chỉ hiện khi `!kIsWeb`**.
  - Hiển thị xem trước ảnh và nút "Xóa ảnh".

```dart
final XFile? f = await ImagePicker().pickImage(
  source: source, maxWidth: 512, maxHeight: 512, imageQuality: 70);
if (f == null) return;
final bytes = await f.readAsBytes();
if (bytes.length > 1500000) { /* báo "Ảnh quá lớn, chọn ảnh nhỏ hơn" và return */ }
final mime = f.mimeType ?? 'image/jpeg';
final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
```

- Lưu thành công thì `Navigator.pop(context, true)` để màn danh sách tải lại.

#### `screens/giangvien_detail_screen.dart`
- Hiển thị **ảnh lớn**, họ tên, mã giảng viên, tổng số lớp, kèm nút "Sửa" và "Xóa". Đây là màn đáp ứng yêu cầu 3 (hiển thị thông tin trên di động).

**Hoàn thành khi:** `flutter analyze` sạch lỗi và toàn bộ luồng chạy được trên Chrome.

---

### Bước 9. Chạy và kiểm thử đầy đủ

Terminal 1:
```powershell
cd server
npm run dev
```
Terminal 2 (thư mục gốc):
```powershell
flutter run -d chrome
```
Sau đó test trên Android: mở máy ảo, chọn thiết bị Android rồi `flutter run`.

#### Danh sách kiểm thử (tick từng mục)

**Web (8 điểm + 1.5 điểm):**
- [ ] Đăng nhập admin thành công; sai mật khẩu báo lỗi
- [ ] Đóng tab mở lại vẫn đăng nhập (token được lưu); đăng xuất hoạt động
- [ ] Thêm giảng viên mới có ảnh; danh sách hiển thị đủ `IDGV, Fullname, Image, SumClass`
- [ ] Thêm trùng `IDGV` báo "Mã giảng viên đã tồn tại"
- [ ] `SumClass` nhập số âm hoặc chữ bị từ chối
- [ ] Sửa họ tên, số lớp, đổi ảnh thành công
- [ ] Xóa có hộp thoại xác nhận
- [ ] Tìm kiếm và phân trang đúng (thêm >= 12 giảng viên để thấy nhiều trang)
- [ ] Dữ liệu nằm trong database `QLHocPhan`, collection `GiangVien` trên Atlas

**Android (0.5 điểm):**
- [ ] Đăng nhập được từ máy ảo (API qua `10.0.2.2`)
- [ ] Chọn ảnh từ thư viện (máy ảo: kéo thả ảnh vào cửa sổ emulator) hoặc chụp bằng camera ảo
- [ ] Ảnh hiển thị ở danh sách và màn chi tiết cùng đầy đủ thông tin giảng viên
- [ ] Bố cục dạng thẻ (ListView) hiển thị đẹp, không tràn

---

### Bước 10. Kiểm tra ràng buộc "đúng 4 trường" và xuất file CSDL

#### 10.1. `server/scripts/verifyFields.js`
Kết nối DB bằng driver của Mongoose (`mongoose.connection.db.collection('GiangVien').find().toArray()`) rồi kiểm tra **mọi** document có tập khóa **đúng bằng** `{_id, IDGV, Fullname, Image, SumClass}`. In ra số document hợp lệ, document sai kèm tên trường thừa. `process.exit(1)` nếu có sai.

```powershell
npm run verify:fields
```

#### 10.2. `server/scripts/exportDb.js`
Đọc toàn bộ collection `GiangVien` bằng driver thô, ghi ra `../database/GiangVien.json` (mảng JSON, định dạng đẹp, `_id` chuyển thành chuỗi). Tự tạo thư mục `database/` nếu chưa có.

```powershell
npm run export-db
```

Kết quả: `database/GiangVien.json` có đúng 4 trường + `_id` cho mỗi bản ghi.

> Nên xuất **sau khi** đã nhập vài giảng viên có ảnh thật qua giao diện, để file nộp có dữ liệu ảnh.

**Hoàn thành khi:** `verify:fields` báo toàn bộ hợp lệ và có file `database/GiangVien.json`.

---

### Bước 11. Hoàn thiện repo (chỉ phần code, không đẩy GitHub)

`.gitignore` ở thư mục gốc:

```gitignore
# Node
server/node_modules/
server/.env

# Flutter
.dart_tool/
build/
.flutter-plugins*
.packages
android/.gradle/
android/local.properties
*.iml

# IDE / OS
.idea/
.vscode/
.DS_Store
```

(Giữ lại `server/.env.example` và `database/GiangVien.json` để commit.)

`README.md` ngắn gọn gồm: yêu cầu cài đặt, cách tạo cluster MongoDB Atlas và lấy chuỗi kết nối (không ghi chuỗi thật, database tên `QLHocPhan`), cấu hình `.env`, `npm install`, `npm run seed`, `npm run dev`, cách chạy Flutter web và Android, tài khoản admin mẫu, cách đổi `_lanOverride` khi dùng điện thoại thật, cách xuất DB.

**Hoàn thành khi:** repo sạch, không có file `.env`, `node_modules`, `build` trong danh sách sẽ commit.

---

## 4. Bảng nghiệm thu cuối cùng

| Mục | Điều kiện đạt |
|---|---|
| Ràng buộc DB | `npm run verify:fields` báo mọi bản ghi chỉ có `_id, IDGV, Fullname, Image, SumClass`; DB `QLHocPhan`, collection `GiangVien` |
| File CSDL | Có `database/GiangVien.json` |
| 8.0 điểm | Web: thêm, hiển thị `IDGV, Fullname, Image, SumClass` bằng MongoDB hoạt động ổn định |
| 1.5 điểm | Đăng nhập admin, sửa, xóa xác nhận, tìm kiếm, phân trang, thống kê tổng số lớp |
| 0.5 điểm | Android: chọn ảnh và hiển thị thông tin giảng viên |
| Chất lượng | `flutter analyze` không lỗi, không lộ mật khẩu/chuỗi kết nối trong repo, giao diện tiếng Việt, xử lý lỗi và trạng thái loading đầy đủ |

Khi hoàn tất, AI code tóm tắt cho người dùng: các lệnh chạy dự án, tài khoản đăng nhập admin mẫu.
