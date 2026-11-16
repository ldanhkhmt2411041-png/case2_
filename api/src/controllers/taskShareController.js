const TaskShare = require('../models/TaskShare');
const Task = require('../models/Task');
const User = require('../models/User');
const { createNotification } = require('../services/notificationService');
const { sendEmail } = require('../services/emailService');

exports.getShares = async (req, res) => {
  try {
    const shares = await TaskShare.find({ taskId: req.params.id })
      .populate('userId', 'fullName email')
      .populate('sharedBy', 'fullName email');

    res.status(200).json({ success: true, data: shares });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.addShare = async (req, res) => {
  try {
    const { userId, permission } = req.body;
    const taskId = req.params.id;

    const task = await Task.findById(taskId);
    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Chi nguoi tao moi co quyen chia se' });
    }

    const share = await TaskShare.findOneAndUpdate(
      { taskId, userId },
      { permission: permission || 'viewer', sharedBy: req.user.id },
      { new: true, upsert: true }
    );

    // Gui thong bao va email cho nguoi duoc chia se
    const sharedUser = await User.findById(userId);
    if (sharedUser) {
      const permText = (permission === 'editor') ? 'Chỉnh sửa (Editor)' : 'Chỉ xem (Viewer)';

      await createNotification({
        userId: sharedUser._id,
        taskId: task._id,
        type: 'sharing',
        title: `Ban duoc chia se cong viec: ${task.title}`,
        message: `${req.user.name || req.user.fullName || 'Nguoi dung'} da chia se cong viec "${task.title}" voi quyen ${permText}.`
      });

      await sendEmail({
        recipientEmail: sharedUser.email,
        subject: `[TaskManager] Bạn được chia sẻ công việc: ${task.title}`,
        html: `
          <h3>Thông báo chia sẻ công việc</h3>
          <p>Xin chào <strong>${sharedUser.fullName || sharedUser.email}</strong>,</p>
          <p>Bạn đã được mời tham gia công việc: <strong>${task.title}</strong></p>
          <p><strong>Quyền truy cập:</strong> ${permText}</p>
          <p><strong>Mô tả:</strong> ${task.description || 'Không có mô tả'}</p>
          <p><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Không giới hạn'}</p>
          <p>Vui lòng đăng nhập ứng dụng TaskManager để xem chi tiết.</p>
        `,
        taskId: task._id,
        eventType: 'task_shared'
      });
    }

    res.status(200).json({ success: true, data: share });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updateSharePermission = async (req, res) => {
  try {
    const { shareId } = req.params;
    const { permission } = req.body;

    const share = await TaskShare.findById(shareId);
    if (!share) {
      return res.status(404).json({ success: false, message: 'Khong tim thay ban ghi chia se' });
    }

    share.permission = permission;
    await share.save();

    res.status(200).json({ success: true, data: share });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.removeShare = async (req, res) => {
  try {
    const { shareId } = req.params;
    const share = await TaskShare.findById(shareId);

    if (!share) {
      return res.status(404).json({ success: false, message: 'Khong tim thay ban ghi chia se' });
    }

    await share.deleteOne();
    res.status(200).json({ success: true, message: 'Thu hoi quyen chia se thanh cong' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
