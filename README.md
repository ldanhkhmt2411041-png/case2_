# Case Study 2: Ứng dụng Quản lý và Giao công việc nhóm

- **Họ và tên:** Lê Đức Anh
- **MSSV:** KHMT2411041
- **Backend:** Node.js / Express REST API / MongoDB / Nodemailer
- **Frontend:** Flutter

---

## 1. Mục tiêu và phạm vi
Ứng dụng cho phép người dùng quản lý công việc cá nhân, giao công việc cho một hoặc nhiều người, chia sẻ công việc để nhiều người cùng xem hoặc chỉnh sửa theo quyền (viewer/editor), theo dõi tiến độ, gửi email và nhận thông báo trong ứng dụng.

## 2. Cấu trúc dự án
- `api/`: Backend Node.js / Express / MongoDB / Nodemailer
- `TaskManager/`: Frontend Flutter mobile app

## 3. Danh sách chức năng đã hoàn thành
- **A. Quản lý tài khoản và xác thực:** Đăng ký, đăng nhập, JWT authentication, xem & cập nhật thông tin cá nhân (`/auth/me`), đổi mật khẩu (`/auth/change-password`).
- **B. Quản lý công việc:** CRUD công việc, lọc theo trạng thái, mức độ ưu tiên, phân loại phạm vi (Tất cả, Của tôi, Được giao, Được chia sẻ), tìm kiếm và sắp xếp.
- **C. Giao việc và chia sẻ:** Giao việc cho một hoặc nhiều người dùng, chọn người phụ trách chính, chia sẻ công việc với quyền viewer/editor, cập nhật và thu hồi quyền truy cập.
- **D. Thông báo & Email:** 
  - Gửi email khi giao việc, chia sẻ, cập nhật thông tin/hạn hoàn thành, hoàn thành công việc.
  - Lưu lịch sử gửi email (`email_logs`) và hỗ trợ thử gửi lại (`retry`).
  - Hệ thống thông báo trong ứng dụng (`notifications`), đếm chưa đọc, đánh dấu đã đọc và mở trực tiếp công việc liên quan.
  - Tiến trình tự động quét và gửi email / thông báo nhắc việc trước hạn 24 giờ.
- **E. Thống kê & Tiện ích:**
  - Thống kê tổng số công việc theo trạng thái.
  - Thống kê công việc được giao, đang phụ trách chính, đã tạo, được chia sẻ.
  - Thống kê công việc sắp đến hạn (<48h) và quá hạn.
  - Lưu và hiển thị lịch sử hoạt động chi tiết của công việc (`task_activities`).

## 4. Hướng dẫn khởi chạy
### Backend (`api`)
```bash
cd api
npm install
cp .env.example .env # Cấu hình MONGODB_URI, JWT_SECRET, EMAIL_USER, EMAIL_PASS
npm run dev # hoặc npm start
```

### Frontend (`TaskManager`)
```bash
cd TaskManager
flutter pub get
flutter run
```
