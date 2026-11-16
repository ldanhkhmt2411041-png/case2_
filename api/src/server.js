const dotenv = require('dotenv');
const connectDB = require('./config/db');
const app = require('./app');
const { startReminderScheduler } = require('./services/reminderService');

dotenv.config();
connectDB();

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server dang chay tai cong ${PORT}`);
  startReminderScheduler();
});
