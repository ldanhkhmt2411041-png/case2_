const TaskActivity = require('../models/TaskActivity');

exports.logActivity = async ({ taskId, userId, action, details = {} }) => {
  try {
    const activity = await TaskActivity.create({
      taskId,
      userId,
      action,
      details
    });
    return activity;
  } catch (error) {
    console.error('Error logging activity:', error.message);
    return null;
  }
};
