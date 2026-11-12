# MIDTERM REPORT: CROSS-PLATFORM APPLICATION

| Field | Information |
|---|---|
| **Full name** | Huynh Van Truong Hai |
| **Student ID** | 23IT064 |
| **Course Section** | Phát triển ứng dụng di động đa nền tảng (1) |
| **Class** | 23GIT |
| **Email** | *(Update your email here)* |
| **Repository** | *(Update your GitHub repository link here)* |
| **Video Demo** | *(Update your demo video link here)* |
| **Database** | `database/GiangVien.json` |

---

## 1. Overview

This project develops a cross-platform lecturer management application for the **`QLHocPhan`** database. The frontend is implemented with **Flutter** and runs on both **Web** and **Android**. The backend uses **Node.js** and **Express** to expose REST API endpoints, while **MongoDB Atlas** stores lecturer records in the **`GiangVien`** collection. The application supports administrator login (JWT), displaying lecturer records, adding records, editing records, deleting records with confirmation, searching, pagination, class-count statistics, and selecting or capturing an image on mobile.

The lecturer data model strictly follows the assignment's required business fields only: **`IDGV`**, **`Fullname`**, **`Image`**, and **`SumClass`** (lecturer ID, full name, image, and total number of classes). MongoDB automatically provides its default document identifier `_id`, while Mongoose metadata (`__v`, `createdAt`, `updatedAt`) is explicitly disabled so that no extra fields are introduced. The report and implementation demonstrate both the Web management workflow (8.0 + 1.5 points) and the mobile image-selection and information-display workflow (0.5 points).

---

## 2. Tools and Technologies

| Component | Purpose in this project |
|---|---|
| **Flutter** | Builds the application UI for Web (data table) and Android (card list) from a single codebase. |
| **Dart** | Programming language used to implement Flutter screens, data models, and HTTP API services. |
| **http** | Flutter package used to send REST API requests to the Express backend with JSON payloads and timeout handling. |
| **image_picker** | Flutter package used to select images from the gallery (Web and Android) or capture photos from the camera (Android). |
| **shared_preferences** | Flutter package used to persist the administrator's JWT authentication token locally across sessions. |
| **Node.js** | JavaScript runtime used to execute the backend server and database utility scripts. |
| **Express.js** | Web framework used to define REST API routes for admin authentication and lecturer CRUD operations. |
| **MongoDB Atlas** | Cloud-hosted NoSQL database hosting the `QLHocPhan` database and `GiangVien` collection. |
| **Mongoose** | ODM library used to enforce the strict 4-field `GiangVien` schema and perform queries/aggregations. |
| **jsonwebtoken (JWT)** | Generates and verifies signed tokens to protect all lecturer management API endpoints. |
| **dotenv & cors** | Loads environment variables from `server/.env` and enables cross-origin requests from Flutter Web. |

---

## 3. Project Setup

### 3.1 Checking the Development Environment and Flutter Project

Before implementing the application, the Flutter and Node.js development environments are verified. The Flutter project is already configured in the root directory (`flutter_middterm_crud_application`) with support for both **Web** and **Android** platforms.

> **[Screenshot note]:** Chụp ảnh terminal khi chạy lệnh `flutter --version` và `node -v` để xác nhận môi trường lập trình đã sẵn sàng (Figure 1).

Figure 1. Verifying the Flutter and Node.js development environment in the terminal.

The terminal output confirms that the Flutter SDK and Node.js runtime are properly installed, providing the foundation for both frontend and backend development.

### 3.2 Installing Flutter Dependencies

After verifying the project structure, the required Flutter packages (`http`, `image_picker`, and `shared_preferences`) are added to `pubspec.yaml`. These dependencies provide HTTP networking, cross-platform image selection, and persistent token storage.

> **[Screenshot note]:** Chụp ảnh terminal khi chạy lệnh `flutter pub add http image_picker shared_preferences` và kết quả cài đặt thành công (Figure 2).

Figure 2. Installing Flutter dependencies (`http`, `image_picker`, `shared_preferences`).

The terminal output confirms that all three Flutter packages were resolved and added to the project without version conflicts.

### 3.3 Configuring Android Platform Settings

To ensure the Android emulator can communicate with the local Express backend over HTTP during development, `android.permission.INTERNET` and `android:usesCleartextTraffic="true"` are configured in `android/app/src/main/AndroidManifest.xml`. Additionally, `kotlin.incremental=false` is added to `android/gradle.properties` to prevent Kotlin incremental cache errors when the project (`E:`) and Pub cache (`C:`) reside on different Windows drives.

> **[Screenshot note]:** Chụp ảnh file `android/app/src/main/AndroidManifest.xml` hiển thị quyền `INTERNET` và thuộc tính `usesCleartextTraffic="true"` (Figure 3).

Figure 3. Android manifest network permissions and cleartext traffic configuration.

This configuration allows the Android application to send HTTP requests to the host machine (`10.0.2.2:3000`) cleanly.

---

## 4. Database Configuration with MongoDB Atlas

### 4.1 Creating the Database and Collection

MongoDB Atlas is used to host the application's cloud database. The database is named **`QLHocPhan`** and contains the **`GiangVien`** collection. The connection URI is stored in `server/.env` (which is excluded from Git via `.gitignore`) rather than hard-coded in source files.

> **[Screenshot note]:** Chụp ảnh giao diện MongoDB Atlas (Browse Collections) hiển thị database `QLHocPhan`, collection `GiangVien`, và một document mẫu chỉ chứa `_id`, `IDGV`, `Fullname`, `Image`, `SumClass` (Figure 4).

Figure 4. The `QLHocPhan` database and `GiangVien` collection in MongoDB Atlas.

Inspecting the collection confirms that every document contains only MongoDB's `_id` and the four required fields (`IDGV`, `Fullname`, `Image`, `SumClass`).

### 4.2 Seeding, Verifying Fields, and Exporting Database

Three utility scripts are implemented in `server/scripts/`:
- `seed.js` (`npm run seed`): Inserts 5 initial sample lecturers using upsert by `IDGV`.
- `verifyFields.js` (`npm run verify:fields`): Queries the raw `GiangVien` collection and verifies that every single document has the exact key set `{_id, IDGV, Fullname, Image, SumClass}`.
- `exportDb.js` (`npm run export-db`): Exports all documents to `database/GiangVien.json` for submission.

> **[Screenshot note]:** Chụp ảnh terminal chạy `npm run verify:fields` và `npm run export-db`, kèm ảnh nội dung file `database/GiangVien.json` (Figure 5).

Figure 5. Verifying strict 4-field compliance and exporting `database/GiangVien.json`.

The verification output confirms zero invalid documents, and the exported JSON file is ready for submission alongside the source code.

---

## 5. Backend Implementation with Node.js and Express

### 5.1 Initializing the Node.js Project

The backend is maintained separately from the Flutter frontend in the `server/` directory. The Node.js project is initialized there so that backend dependencies, environment configuration, and API routes remain independent of the Flutter application.

> **[Screenshot note]:** Chụp ảnh terminal tạo thư mục `server/` và chạy `npm init -y` (Figure 6).

Figure 6. Initializing the Node.js backend project in the `server/` directory.

The terminal confirms that `package.json` has been created inside `server/`.

### 5.2 Installing Backend Dependencies

The backend dependencies are installed to support Express routing, MongoDB access via Mongoose, CORS, environment loading, and JWT authentication, along with `nodemon` for automatic server reloads during development.

> **[Screenshot note]:** Chụp ảnh terminal chạy `npm install express mongoose cors dotenv jsonwebtoken` và `npm install -D nodemon` (Figure 7).

Figure 7. Installing Node.js backend dependencies.

The installation output indicates that all required packages have been added cleanly.

### 5.3 Configuring the Backend Project

`server/package.json` defines the project metadata and npm scripts (`start`, `dev`, `seed`, `verify:fields`, `export-db`), while `server/src/index.js` configures `cors()`, `express.json({ limit: '5mb' })` (to accommodate base64 image payloads), mounts `/api/auth` and `/api/giangvien`, and listens on `0.0.0.0:3000` so both Web and the Android emulator can reach the server.

> **[Screenshot note]:** Chụp ảnh file `server/package.json` và `server/src/index.js` (Figure 8).

Figure 8. Backend `package.json` scripts and Express server entry point (`index.js`).

This setup provides a consistent entry point and clear error-handling middleware for invalid JSON or oversized image payloads.

### 5.4 Connecting to MongoDB (`server/src/config/db.js`)

A dedicated database configuration module connects Express to MongoDB Atlas using `process.env.MONGODB_URI` with a 15-second timeout. On success, it logs the connected database name (`QLHocPhan`); on failure, it prints actionable hints (authentication vs. Atlas Network Access IP whitelist) and exits.

> **[Screenshot note]:** Chụp ảnh code file `server/src/config/db.js` và log terminal khi chạy `npm run dev` báo `Đã kết nối MongoDB, database: QLHocPhan` (Figure 9).

Figure 9. MongoDB connection module and successful startup log.

Keeping the connection URI in `.env` prevents database credentials from being exposed in version control.

### 5.5 Defining the `GiangVien` Model (`server/src/models/GiangVien.js`)

The `GiangVien` model defines the exact structure of documents in the `GiangVien` collection:
- `IDGV`: `String`, required, unique, trimmed, automatically converted to uppercase.
- `Fullname`: `String`, required, trimmed.
- `Image`: `String`, default `''` (stores a base64 data URI).
- `SumClass`: `Number`, required, integer `>= 0`, default `0`.

Both `versionKey: false` and `timestamps: false` are explicitly set alongside `strict: true` and `collection: 'GiangVien'`.

> **[Screenshot note]:** Chụp ảnh code file `server/src/models/GiangVien.js` (Figure 10).

Figure 10. `GiangVien` Mongoose schema with strictly 4 business fields.

This schema guarantees that no extraneous fields (`__v`, `createdAt`, `updatedAt`) are ever written to MongoDB.

### 5.6 Administrator Authentication (`auth.routes.js` & `middleware/auth.js`)

Because adding account fields (`username`, `password`, `role`) to `GiangVien` would violate the assignment's strict 4-field rule, administrator credentials (`ADMIN_USERNAME`, `ADMIN_PASSWORD`) are configured in `server/.env`. `POST /api/auth/login` verifies credentials using `crypto.timingSafeEqual` and issues a signed JWT, while `GET /api/auth/me` validates existing tokens. All lecturer routes are guarded by `middleware/auth.js`.

> **[Screenshot note]:** Chụp ảnh code file `server/src/routes/auth.routes.js` (Figure 11).

Figure 11. Administrator login and token verification routes.

This design protects all CRUD operations while keeping the `GiangVien` collection 100% compliant with the schema constraint.

### 5.7 Retrieving All Lecturers (`GET /api/giangvien`)

The list endpoint supports keyword searching (`search` matched case-insensitively against `IDGV` or `Fullname` with escaped regex characters) and pagination (`page`, `limit`). It also runs a MongoDB aggregation pipeline to compute `totalSumClass` across matching records and formats each document via `publicGiangVien.js`.

> **[Screenshot note]:** Chụp ảnh code phần `router.get('/')` trong `server/src/routes/giangvien.routes.js` (Figure 12).

Figure 12. Get-all-lecturers API with search, pagination, and class-count aggregation.

The frontend uses this response to render both the lecturer list/table and the summary statistics cards.

### 5.8 Retrieving a Lecturer by ID (`GET /api/giangvien/:id`)

The detail endpoint validates whether `req.params.id` is a valid MongoDB `ObjectId` and queries `GiangVien.findById`. If the ID format is invalid or no matching document exists, it returns HTTP `404` with a clear Vietnamese error message.

> **[Screenshot note]:** Chụp ảnh code phần `router.get('/:id')` trong `server/src/routes/giangvien.routes.js` (Figure 13).

Figure 13. Get-lecturer-by-ID API implementation.

This endpoint allows the detail screen to reload fresh data after an edit operation.

### 5.9 Adding a New Lecturer (`POST /api/giangvien`)

The create endpoint passes `req.body` through a strict `validate()` helper that extracts only the 4 allowed fields, checks that `IDGV` and `Fullname` are non-empty, verifies `SumClass` is a non-negative integer, and validates that `Image` (if provided) is a `data:image/` URI within size limits. Duplicate `IDGV` errors (MongoDB code `11000`) return HTTP `409`.

> **[Screenshot note]:** Chụp ảnh code hàm `validate()` và `router.post('/')` trong `server/src/routes/giangvien.routes.js` (Figure 14).

Figure 14. Create-lecturer API with strict 4-field validation and duplicate-ID handling.

This ensures invalid or duplicate lecturer records are rejected cleanly before reaching the database.

### 5.10 Updating Lecturer Information (`PUT /api/giangvien/:id`)

The update endpoint validates the document `_id`, runs the same `validate()` helper on the incoming 4 fields, and updates the record via `GiangVien.findByIdAndUpdate` with `new: true` and `runValidators: true`. Duplicate `IDGV` conflicts return HTTP `409`, and missing IDs return `404`.

> **[Screenshot note]:** Chụp ảnh code phần `router.put('/:id')` trong `server/src/routes/giangvien.routes.js` (Figure 15).

Figure 15. Update-lecturer API implementation.

Returning the updated document allows the Flutter UI to immediately reflect all changes.

### 5.11 Deleting a Lecturer (`DELETE /api/giangvien/:id`)

The delete endpoint checks `ObjectId` validity and removes the target document via `GiangVien.findByIdAndDelete`. If the record does not exist, it returns HTTP `404`; otherwise, it returns HTTP `200` with `{ message: 'Đã xóa' }`.

> **[Screenshot note]:** Chụp ảnh code phần `router.delete('/:id')` trong `server/src/routes/giangvien.routes.js` (Figure 16).

Figure 16. Delete-lecturer API implementation.

After receiving `200`, the Flutter dashboard refreshes the list and updates the statistics.

---

## 6. Frontend Implementation with Flutter

The Flutter frontend is built with Material 3 (`ThemeData` centralized in `lib/main.dart` using a teal seed color `0xFF00897B`, rounded 12dp inputs/buttons, and 16dp cards/dialogs). `ApiService` (`lib/services/api_service.dart`) attaches the Bearer token automatically, enforces a 15-second timeout, and redirects to the login screen on HTTP `401`. `ApiConfig` (`lib/config/api_config.dart`) targets `http://localhost:3000/api` on Web and `http://10.0.2.2:3000/api` on the Android emulator.

### 6.1 Web Platform – Administrator Login

The login screen (`lib/screens/login_screen.dart`) provides a centered card with username and password fields, password visibility toggle, Enter-to-submit support, loading indicator, and a styled error banner when invalid credentials are entered.

> **[Screenshot note]:** Chụp ảnh màn hình đăng nhập trên Chrome (cả trạng thái bình thường hoặc khi báo lỗi sai mật khẩu) (Figure 17).

Figure 17. Administrator sign-in screen on Flutter Web.

Upon successful login, the JWT is saved via `TokenStorage` and the administrator is navigated to the management dashboard.

### 6.2 Web Platform – Lecturer Management Dashboard

On Web (`width >= 800px`), `GiangVienListScreen` (`lib/screens/giangvien_list_screen.dart`) displays two summary statistic cards (total lecturers and total classes), a debounced search bar, pagination controls, a thin top loading bar, and a `DataTable` displaying `Ảnh`, `Mã GV`, `Họ và tên`, `Số lớp`, and action buttons (View, Edit, Delete). When no avatar image is uploaded, `GiangVienAvatar` renders the lecturer's initials with a deterministic color.

> **[Screenshot note]:** Chụp ảnh màn hình danh sách giảng viên dạng bảng (`DataTable`) trên Chrome (Figure 18).

Figure 18. Lecturer management dashboard (`DataTable` layout) on Web.

This layout provides a clear overview of all lecturer records and supports quick navigation and actions.

### 6.3 Web Platform – Adding and Editing a Lecturer

`GiangVienFormScreen` (`lib/screens/giangvien_form_screen.dart`) serves both Add and Edit workflows. It groups the image picker card at the top and the three text fields (`IDGV`, `Fullname`, `SumClass` with digits-only input formatter) below. Selected images are resized (max 512x512) and encoded as base64 data URIs.

> **[Screenshot note]:** Chụp ảnh form Thêm / Sửa giảng viên trên Chrome khi đang nhập liệu và chọn ảnh (Figure 19).

Figure 19. Add / Edit lecturer form on Web.

Submitting the form disables the save button, displays a spinner, and shows server validation messages (e.g., duplicate `IDGV`) in an inline error banner if any occur.

### 6.4 Web Platform – Viewing Details, Searching, and Deleting

Clicking a lecturer row or view icon opens `GiangVienDetailScreen` (`lib/screens/giangvien_detail_screen.dart`) with a Hero-animated avatar and action buttons (`Sửa`, `Xóa`). Clicking Delete opens `confirmDelete` (`lib/widgets/common.dart`), which warns that the action cannot be undone before calling the delete API. The search bar filters records in real time by `IDGV` or `Fullname`, and displays an empty-state view with a "Xóa tìm kiếm" button if nothing matches.

> **[Screenshot note]:** Chụp ảnh hộp thoại xác nhận xóa và màn hình kết quả tìm kiếm trên Chrome (Figure 20).

Figure 20. Delete confirmation dialog and search filtering on Web.

After deleting or editing a record, the list and summary cards automatically refresh from MongoDB.

### 6.5 Mobile Platform – Image Selection and Information Display (Android)

On narrow screens (`width < 800px`), the list automatically switches to a `ListView` of cards. When adding or editing a lecturer on Android, the form enables both **"Chọn từ thư viện"** (gallery) and **"Chụp ảnh"** (camera, hidden on Web via `!kIsWeb`). After saving, the card list and detail screen display the lecturer's selected image alongside `IDGV`, `Fullname`, and `SumClass`.

> **[Screenshot note]:** Chụp ảnh trên máy ảo Android gồm: (1) Danh sách dạng thẻ, (2) Form chọn ảnh từ thư viện hoặc chụp ảnh bằng camera, và (3) Màn hình chi tiết hiển thị ảnh lớn cùng thông tin giảng viên (Figure 21).

Figure 21. Android mobile workflow: card list, image selection (gallery/camera), and detail display.

This verifies that the mobile platform requirement (0.5 points) works end-to-end with the same MongoDB Atlas database.

---

## 7. Application Architecture

The application is organized into three main layers:
1. **Presentation Layer (Flutter):** Renders responsive Web (`DataTable`) and Android (`ListView`) interfaces, validates user input, encodes images into base64 data URIs, and persists JWT tokens locally.
2. **Application & API Layer (Node.js + Express):** Authenticates requests via JWT, enforces strict validation on the 4 required fields, and exposes REST endpoints under `/api/auth` and `/api/giangvien`.
3. **Database Layer (MongoDB Atlas):** Stores all lecturer documents in the `GiangVien` collection inside the `QLHocPhan` database.

### 7.1 Request and Data Flow

When the administrator performs an action, the Flutter `ApiService` sends an HTTP request with the `Authorization: Bearer <token>` header to the Express server. The Express middleware verifies the JWT, the route handler validates the payload and queries MongoDB through the Mongoose `GiangVien` model, and the server returns a JSON response. The Flutter UI then updates its state or displays a `SnackBar` / `ErrorBanner`. This separation keeps database credentials safely in `server/.env` rather than inside client-side code.

### 7.2 Main Application Flow

On launch, `_Splash` in `main.dart` checks for a stored JWT token via `TokenStorage.read()`. If valid (`GET /api/auth/me` succeeds), it opens `GiangVienListScreen`; otherwise, it navigates to `LoginScreen`. Once signed in, the administrator can view statistics, search, paginate, inspect details, add new lecturers, edit existing records, or delete records with confirmation.

---

## 8. Main Features

### 8.1 Administrator Login
`LoginScreen` validates non-empty credentials and calls `POST /api/auth/login`. Successful authentication stores the JWT in `shared_preferences` so refreshing the browser or reopening the app keeps the session active until logout or token expiration.

### 8.2 Displaying Lecturer Records
`GiangVienListScreen` fetches paginated records (`GET /api/giangvien`) and adapts its layout via `LayoutBuilder`: a `DataTable` on Web (`>= 800px`) and `Card` items on Android (`< 800px`), displaying `IDGV`, `Fullname`, `Image`, and `SumClass`, plus total lecturer and total class counts.

### 8.3 Adding a Lecturer
`GiangVienFormScreen` creates new records via `POST /api/giangvien`. Input validation checks for non-empty `IDGV` and `Fullname`, non-negative integer `SumClass`, and image size limits (`<= 1.5 MB` raw bytes on client, `<= 2,000,000` chars on server).

### 8.4 Updating Lecturer Information
Opening an existing lecturer in `GiangVienFormScreen` pre-populates all fields and submits changes to `PUT /api/giangvien/:id`, updating the record in MongoDB and refreshing both the detail and list screens.

### 8.5 Deleting a Lecturer
Triggering Delete from either the list or detail screen opens `confirmDelete`, clearly stating the lecturer's name and ID and warning that the action cannot be undone, before sending `DELETE /api/giangvien/:id`.

### 8.6 Image Selection and Display on Mobile
Using `image_picker`, Android users can pick a photo from the device gallery or capture a new photo with the camera, preview it immediately in the form, and view it in full size on `GiangVienDetailScreen`.

### 8.7 Search and Pagination
The search field debounces input by 400ms and queries the backend by `IDGV` or `Fullname`, while pagination buttons navigate across pages of 10 lecturers each.

---

## 9. Running the Application

### 9.1 Start the Backend
```powershell
cd server
npm install
npm run seed    # Optional: insert 5 sample lecturers
npm run dev     # Starts Express API on http://localhost:3000
```

### 9.2 Run Flutter on Web
```powershell
flutter pub get
flutter run -d chrome
```

### 9.3 Run Flutter on Android
Start an Android emulator (or connect a physical device with USB debugging enabled; for physical devices, update `_lanOverride` in `lib/config/api_config.dart` to the computer's LAN IP), then run:
```powershell
flutter run
```

### 9.4 Basic Verification & Database Export
Verify CRUD, search, pagination, and mobile image upload, then run:
```powershell
cd server
npm run verify:fields
npm run export-db
```

---

## 10. Challenges and Solutions

| Challenge | Solution / Handling |
|---|---|
| **Admin login without adding DB fields** | Stored admin credentials in `server/.env` and issued JWTs instead of adding user/role fields to the `GiangVien` collection. |
| **Flutter Web cannot connect directly to MongoDB** | Built a Node.js/Express REST API intermediary with CORS enabled so both Web and Android clients share one backend. |
| **Android emulator reaching localhost backend** | Configured `ApiConfig` to use `10.0.2.2:3000` on Android and enabled `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`. |
| **Kotlin incremental build error across Windows drives (`E:` vs `C:`)** | Added `kotlin.incremental=false` to `android/gradle.properties` so Gradle compiles Android plugins cleanly. |
| **Storing images without extra DB fields or external services** | Resized selected images (max 512x512) and stored them as base64 data URIs directly in the `Image` field. |

---

## 11. Conclusion

This project demonstrates a complete cross-platform lecturer management application built with **Flutter**, **Node.js**, **Express**, and **MongoDB Atlas**. The backend provides JWT-authenticated REST APIs for retrieving, adding, updating, and deleting lecturer records in the `QLHocPhan` database's `GiangVien` collection while strictly preserving only the four required fields (`IDGV`, `Fullname`, `Image`, `SumClass`). The Flutter frontend delivers a responsive `DataTable` dashboard on Web and a card-based interface with gallery/camera image selection and detail viewing on Android.
