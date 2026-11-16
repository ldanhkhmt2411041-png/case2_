const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/task_manager';
    const conn = await mongoose.connect(uri);
    console.log(`✅ MongoDB da ket noi thanh cong: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌ Loi ket noi MongoDB: ${error.message}`);
    console.error('👉 Huong dan khac phuc:');
    console.error('   1. Neu chay MongoDB cuc bo (Local): Hay dam bao ban da bat dich vu MongoDB (hoac mo MongoDB Compass).');
    console.error('   2. Neu dung MongoDB Atlas (Cloud): Hay cap nhat MONGODB_URI trong file api/.env bang chuoi ket noi Cloud.');
    // Khong crash ngay de giup nguoi dung xem ro log
  }
};

module.exports = connectDB;
