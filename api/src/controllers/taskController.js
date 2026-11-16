const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const User = require('../models/User');
const { createNotification } = require('../services/notificationService');
const { sendEmail } = require('../services/emailService');

// Helper to determine user's role on a task
const getUserPermission = async (task, userId) => {
  if (task.createdBy.toString() === userId.toString()) {
    return 'creator';
  }
  const isAssignee = task.assigneeIds && task.assigneeIds.some(id => id.toString() === userId.toString());
  const isPrimary = task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId.toString();
  if (isAssignee || isPrimary) {
    return 'assignee';
  }
  const share = await TaskShare.findOne({ taskId: task._id, userId });
  if (share) {
    return share.permission; // 'editor' or 'viewer'
  }
  return null;
};

// @desc    Lay danh sach cong viec (ho tro loc scope, status, priority, q, sap xep)
// @route   GET /api/tasks
// @access  Private
exports.getTasks = async (req, res) => {
  try {
    const { status, priority, q, scope, sortBy, order } = req.query;
    const userId = req.user.id;

    // Determine query based on scope
    let filter = {};

    if (scope === 'created') {
      filter.createdBy = userId;
    } else if (scope === 'assigned') {
      filter.$or = [
        { assigneeIds: userId },
        { primaryAssigneeId: userId }
      ];
    } else if (scope === 'shared') {
      const shares = await TaskShare.find({ userId }).select('taskId');
      const sharedTaskIds = shares.map(s => s.taskId);
      filter._id = { $in: sharedTaskIds };
    } else {
      // Default: Tat ca cong viec lien quan den user
      const shares = await TaskShare.find({ userId }).select('taskId');
      const sharedTaskIds = shares.map(s => s.taskId);
      filter.$or = [
        { createdBy: userId },
        { assigneeIds: userId },
        { primaryAssigneeId: userId },
        { _id: { $in: sharedTaskIds } }
      ];
    }

    if (status && status.trim() !== '') {
      filter.status = status;
    }

    if (priority && priority.trim() !== '') {
      filter.priority = priority;
    }

    if (q && q.trim() !== '') {
      filter.$and = filter.$and || [];
      filter.$and.push({
        $or: [
          { title: { $regex: q.trim(), $options: 'i' } },
          { description: { $regex: q.trim(), $options: 'i' } }
        ]
      });
    }

    // Sorting
    let sortOptions = { createdAt: -1 };
    if (sortBy) {
      const sortDirection = order === 'asc' ? 1 : -1;
      sortOptions = { [sortBy]: sortDirection };
    }

    const tasks = await Task.find(filter)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email')
      .sort(sortOptions);

    res.status(200).json({
      success: true,
      count: tasks.length,
      data: tasks
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Tao cong viec moi
// @route   POST /api/tasks
// @access  Private
exports.createTask = async (req, res) => {
  try {
    const { title, description, startDate, dueDate, priority, status, assigneeIds, primaryAssigneeId } = req.body;

    const task = await Task.create({
      title,
      description,
      startDate,
      dueDate,
      priority,
      status,
      createdBy: req.user.id,
      assigneeIds: assigneeIds || [],
      primaryAssigneeId: primaryAssigneeId || null
    });

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    res.status(201).json({
      success: true,
      data: populatedTask
    });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// @desc    Xem chi tiet cong viec
// @route   GET /api/tasks/:id
// @access  Private
exports.getTaskById = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    const permission = await getUserPermission(task, req.user.id);
    if (!permission) {
      return res.status(403).json({ success: false, message: 'Ban khong co quyen truy cap cong viec nay' });
    }

    res.status(200).json({
      success: true,
      data: task,
      permission
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Cap nhat thong tin cong viec
// @route   PUT /api/tasks/:id
// @access  Private
exports.updateTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    const permission = await getUserPermission(task, req.user.id);
    if (!permission || permission === 'viewer') {
      return res.status(403).json({ success: false, message: 'Ban khong co quyen chinh sua cong viec nay' });
    }

    const oldDueDate = task.dueDate ? new Date(task.dueDate).getTime() : null;
    const newDueDate = req.body.dueDate ? new Date(req.body.dueDate).getTime() : null;
    const isDueDateChanged = oldDueDate !== newDueDate;

    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    )
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    // Thong bao khi thong tin quan trong hoac han hoan thanh thay doi
    if (isDueDateChanged) {
      const recipientIds = [];
      if (updatedTask.assigneeIds && updatedTask.assigneeIds.length > 0) {
        updatedTask.assigneeIds.forEach(u => recipientIds.push(u));
      }
      if (updatedTask.createdBy && updatedTask.createdBy._id.toString() !== req.user.id) {
        recipientIds.push(updatedTask.createdBy);
      }

      for (const recipient of recipientIds) {
        if (recipient._id.toString() !== req.user.id) {
          await createNotification({
            userId: recipient._id,
            taskId: updatedTask._id,
            type: 'update',
            title: `Thay doi han hoan thanh: ${updatedTask.title}`,
            message: `Han hoan thanh da duoc cap nhat thanh: ${updatedTask.dueDate ? new Date(updatedTask.dueDate).toLocaleDateString('vi-VN') : 'Khong xac dinh'}`
          });

          if (recipient.email) {
            await sendEmail({
              recipientEmail: recipient.email,
              subject: `[TaskManager] Thay đổi hạn hoàn thành: ${updatedTask.title}`,
              html: `
                <h3>Cập nhật thông tin công việc</h3>
                <p>Xin chào <strong>${recipient.fullName || recipient.email}</strong>,</p>
                <p>Công việc <strong>${updatedTask.title}</strong> vừa được cập nhật hạn hoàn thành mới: <strong>${updatedTask.dueDate ? new Date(updatedTask.dueDate).toLocaleDateString('vi-VN') : 'Không xác định'}</strong>.</p>
                <p>Vui lòng kiểm tra lại tiến độ để hoàn thành đúng hạn.</p>
              `,
              taskId: updatedTask._id,
              eventType: 'due_date_changed'
            });
          }
        }
      }
    }

    res.status(200).json({
      success: true,
      data: updatedTask
    });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// @desc    Xoa cong viec (Chi nguoi tao moi co quyen xoa)
// @route   DELETE /api/tasks/:id
// @access  Private
exports.deleteTask = async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    if (task.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Chi nguoi tao moi co quyen xoa cong viec' });
    }

    await TaskShare.deleteMany({ taskId: req.params.id });
    await task.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Xoa cong viec thanh cong'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Cap nhat trang thai cong viec
// @route   PATCH /api/tasks/:id/status
// @access  Private
exports.updateTaskStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!['todo', 'in_progress', 'completed'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Trang thai khong hop le' });
    }

    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ success: false, message: 'Khong tim thay cong viec' });
    }

    const permission = await getUserPermission(task, req.user.id);
    if (!permission || permission === 'viewer') {
      return res.status(403).json({ success: false, message: 'Ban khong co quyen cap nhat trang thai' });
    }

    const oldStatus = task.status;
    task.status = status;
    await task.save();

    const populatedTask = await Task.findById(task._id)
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    // Thong bao khi cong viec hoan thanh
    if (status === 'completed' && oldStatus !== 'completed') {
      const notifyUsers = [];
      if (populatedTask.createdBy && populatedTask.createdBy._id.toString() !== req.user.id) {
        notifyUsers.push(populatedTask.createdBy);
      }
      if (populatedTask.assigneeIds) {
        populatedTask.assigneeIds.forEach(u => {
          if (u._id.toString() !== req.user.id && !notifyUsers.some(nu => nu._id.toString() === u._id.toString())) {
            notifyUsers.push(u);
          }
        });
      }

      for (const u of notifyUsers) {
        await createNotification({
          userId: u._id,
          taskId: populatedTask._id,
          type: 'status_change',
          title: `Cong viec da hoan thanh: ${populatedTask.title}`,
          message: `Cong viec "${populatedTask.title}" da duoc danh dau la DA HOAN THANH.`
        });

        if (u.email) {
          await sendEmail({
            recipientEmail: u.email,
            subject: `[TaskManager] Công việc đã hoàn thành: ${populatedTask.title}`,
            html: `
              <h3>Thông báo hoàn thành công việc</h3>
              <p>Xin chào <strong>${u.fullName || u.email}</strong>,</p>
              <p>Công việc <strong>${populatedTask.title}</strong> vừa được hoàn thành thành công!</p>
              <p>Cảm ơn sự đóng góp của bạn.</p>
            `,
            taskId: populatedTask._id,
            eventType: 'task_completed'
          });
        }
      }
    }

    res.status(200).json({ success: true, data: populatedTask });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
