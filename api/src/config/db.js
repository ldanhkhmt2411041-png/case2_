const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const defaultUri = 'mongodb+srv://ldanhkhmt2411041_db_user:vNkf02TdtflXoHKG@cluster0.8cisebk.mongodb.net/task_manager?retryWrites=true&w=majority';
    const uri = process.env.MONGODB_URI || defaultUri;

    const conn = await mongoose.connect(uri);
    console.log(`✅ MongoDB đã kết nối thành công: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ Lỗi kết nối MongoDB: ${error.message}`);
    console.error('👉 Hướng dẫn khắc phục:');
    console.error('   1. Đảm bảo máy tính có kết nối Internet để kết nối tới MongoDB Atlas Cloud.');
    console.error('   2. Kiểm tra IP Access List trên MongoDB Atlas đã mở quyền (0.0.0.0/0).');
  }
};

module.exports = connectDB;
