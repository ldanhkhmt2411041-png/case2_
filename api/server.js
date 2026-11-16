const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./src/config/db');
const { startReminderScheduler } = require('./src/services/reminderService');

dotenv.config();
connectDB();

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/users', require('./src/routes/userRoutes'));
app.use('/api/tasks', require('./src/routes/taskRoutes'));
app.use('/api/notifications', require('./src/routes/notificationRoutes'));
app.use('/api/email-logs', require('./src/routes/emailLogRoutes'));
app.use('/api/statistics', require('./src/routes/statisticsRoutes'));

app.get('/', (req, res) => {
  res.send('API TaskManager dang hoat dong!');
});

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0'; // Cho phep truy cap tu moi noi (localhost, LAN, emulator, may khac)

const server = app.listen(PORT, HOST, () => {
  console.log(`=======================================================`);
  console.log(`🚀 Server Backend dang chay tai: http://localhost:${PORT}`);
  console.log(`🌐 Lang nghe ket noi tu moi dia chi IP (0.0.0.0:${PORT})`);
  console.log(`📡 API Base URL: http://localhost:${PORT}/api`);
  console.log(`=======================================================`);
  // Khoi dong scheduler tu dong kiem tra deadline 24h
  startReminderScheduler();
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\n❌ LOI: Cong ${PORT} dang bi mot tien trinh khac chiem dung!`);
    console.error(`👉 Cach khac phuc nhanh:`);
    console.error(`   1. Chay lenh giai phong cong: npx kill-port ${PORT}`);
    console.error(`   2. Hoac mo file api/.env va sua PORT thanh 3000 (hoac 5001)\n`);
  } else {
    console.error('Loi server:', err);
  }
});
