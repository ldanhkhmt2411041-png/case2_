const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/tasks', require('./routes/taskRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/email-logs', require('./routes/emailLogRoutes'));
app.use('/api/statistics', require('./routes/statisticsRoutes'));

app.get('/', (req, res) => {
  res.send('API TaskManager dang hoat dong!');
});

module.exports = app;
