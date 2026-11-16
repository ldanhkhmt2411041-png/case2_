const EmailLog = require('../models/EmailLog');
const Task = require('../models/Task');
const { retryEmail } = require('../services/emailService');

// @desc    Xem lich su gui email cua 1 cong viec
// @route   GET /api/tasks/:id/email-logs
// @access  Private
exports.getEmailLogsByTask = async (req, res) => {
  try {
    const logs = await EmailLog.find({ taskId: req.params.id }).sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: logs.length,
      data: logs
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Thu lai gui email that bai
// @route   POST /api/email-logs/:id/retry
// @access  Private
exports.retryEmailLog = async (req, res) => {
  try {
    const result = await retryEmail(req.params.id);
    res.status(200).json({
      success: result.success,
      data: result.log,
      message: result.success ? 'Gui lai email thanh cong' : 'Gui lai email that bai: ' + result.error
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
