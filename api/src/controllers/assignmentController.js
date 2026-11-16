const Task = require('../models/Task');
const User = require('../models/User');
const { createNotification } = require('../services/notificationService');
const { sendEmail } = require('../services/emailService');

exports.getAssignees = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    res.status(200).json({
      success: true,
      primaryAssignee: task.primaryAssigneeId,
      assignees: task.assigneeIds
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.addAssignees = async (req, res) => {
  try {
    const { userIds, primaryAssigneeId } = req.body;
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Chi nguoi tao moi co quyen giao viec' });
    }

    const newlyAddedIds = [];

    if (userIds && Array.isArray(userIds)) {
      userIds.forEach(uid => {
        if (!task.assigneeIds.some(id => id.toString() === uid.toString())) {
          task.assigneeIds.push(uid);
          newlyAddedIds.push(uid);
        }
      });
    }

    if (primaryAssigneeId) {
      task.primaryAssigneeId = primaryAssigneeId;
      if (!task.assigneeIds.some(id => id.toString() === primaryAssigneeId.toString())) {
        task.assigneeIds.push(primaryAssigneeId);
        if (!newlyAddedIds.includes(primaryAssigneeId)) {
          newlyAddedIds.push(primaryAssigneeId);
        }
      }
    }

    await task.save();

    // Gui thong bao va email cho nhung nguoi moi duoc giao viec
    if (newlyAddedIds.length > 0) {
      const addedUsers = await User.find({ _id: { $in: newlyAddedIds } });
      for (const u of addedUsers) {
        // Tao in-app notification
        await createNotification({
          userId: u._id,
          taskId: task._id,
          type: 'assignment',
          title: `Ban duoc giao cong viec moi: ${task.title}`,
          message: `${req.user.name || req.user.fullName || 'Nguoi tao'} da giao cong viec "${task.title}" cho ban.`
        });

        // Gui email
        await sendEmail({
          recipientEmail: u.email,
          subject: `[TaskManager] Bạn được giao công việc: ${task.title}`,
          html: `
            <h3>Thông báo giao việc</h3>
            <p>Xin chào <strong>${u.fullName || u.email}</strong>,</p>
            <p>Bạn đã được giao công việc: <strong>${task.title}</strong></p>
            <p><strong>Mô tả:</strong> ${task.description || 'Không có mô tả'}</p>
            <p><strong>Hạn hoàn thành:</strong> ${task.dueDate ? new Date(task.dueDate).toLocaleDateString('vi-VN') : 'Không giới hạn'}</p>
            <p><strong>Mức độ ưu tiên:</strong> ${task.priority.toUpperCase()}</p>
            <p>Vui lòng đăng nhập ứng dụng TaskManager để xem chi tiết.</p>
          `,
          taskId: task._id,
          eventType: 'task_assigned'
        });
      }
    }

    const updatedTask = await Task.findById(task._id)
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    res.status(200).json({ success: true, data: updatedTask });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.updatePrimaryAssignee = async (req, res) => {
  try {
    const { userId } = req.params;
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Chi nguoi tao moi co quyen cap nhat' });
    }

    task.primaryAssigneeId = userId;
    if (!task.assigneeIds.some(id => id.toString() === userId.toString())) {
      task.assigneeIds.push(userId);
    }

    await task.save();

    // Thong bao cho nguoi phu trach chinh
    await createNotification({
      userId,
      taskId: task._id,
      type: 'assignment',
      title: `Ban duoc chi dinh la nguoi phu trach chinh: ${task.title}`,
      message: `Ban da duoc chi dinh lam nguoi phu trach chinh cho cong viec "${task.title}".`
    });

    res.status(200).json({ success: true, data: task });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

exports.removeAssignee = async (req, res) => {
  try {
    const { userId } = req.params;
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Chi nguoi tao moi co quyen huy giao viec' });
    }

    task.assigneeIds = task.assigneeIds.filter(id => id.toString() !== userId);
    if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      task.primaryAssigneeId = null;
    }

    await task.save();
    res.status(200).json({ success: true, data: task });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
