const Notification = require('../models/Notification');

exports.createNotification = async ({ userId, taskId, type, title, message }) => {
  try {
    const notification = await Notification.create({
      userId,
      taskId: taskId || null,
      type: type || 'general',
      title,
      message,
      isRead: false
    });
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error.message);
    return null;
  }
};
