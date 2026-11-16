const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    let uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/task_manager';

    if (uri.includes('<db_username>')) {
      console.error('\n⚠️ CHÚ Ý: Trong chuỗi kết nối MONGODB_URI vẫn còn chữ "<db_username>"!');
      console.error('👉 Vui lòng mở file api/.env và thay "<db_username>" bằng tên tài khoản bạn đã tạo trong MongoDB Atlas (ví dụ: admin, leducanh, ...).\n');
    }

    const conn = await mongoose.connect(uri);
    console.log(`✅ MongoDB đã kết nối thành công tới: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ Lỗi kết nối MongoDB: ${error.message}`);
    console.error('👉 Hướng dẫn khắc phục:');
    console.error('   1. Nếu dùng MongoDB Atlas (Cloud): Kiểm tra lại username, password và IP Access List (đã thêm 0.0.0.0/0 chưa).');
    console.error('   2. Nếu dùng MongoDB cục bộ (Local): Kiểm tra xem MongoDB service / Compass đã được bật chưa.');
  }
};

module.exports = connectDB;
