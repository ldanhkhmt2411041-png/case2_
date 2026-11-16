const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// Helper lay danh sach task IDs ma user co quyen truy cap
const getUserAccessibleTaskFilter = async (userId) => {
  const shares = await TaskShare.find({ userId }).select('taskId');
  const sharedTaskIds = shares.map(s => s.taskId);

  return {
    $or: [
      { createdBy: userId },
      { assigneeIds: userId },
      { primaryAssigneeId: userId },
      { _id: { $in: sharedTaskIds } }
    ]
  };
};

// @desc    Thong ke tong so cong viec theo trang thai
// @route   GET /api/statistics/tasks
// @access  Private
exports.getTaskStats = async (req, res) => {
  try {
    const filter = await getUserAccessibleTaskFilter(req.user.id);

    const todoCount = await Task.countDocuments({ ...filter, status: 'todo' });
    const inProgressCount = await Task.countDocuments({ ...filter, status: 'in_progress' });
    const completedCount = await Task.countDocuments({ ...filter, status: 'completed' });
    const totalCount = todoCount + inProgressCount + completedCount;

    res.status(200).json({
      success: true,
      data: {
        total: totalCount,
        todo: todoCount,
        inProgress: inProgressCount,
        completed: completedCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Thong ke cong viec duoc giao va dang phu trach
// @route   GET /api/statistics/assignments
// @access  Private
exports.getAssignmentStats = async (req, res) => {
  try {
    const userId = req.user.id;

    const assignedCount = await Task.countDocuments({ assigneeIds: userId });
    const primaryCount = await Task.countDocuments({ primaryAssigneeId: userId });
    const createdCount = await Task.countDocuments({ createdBy: userId });

    const shares = await TaskShare.find({ userId }).select('taskId');
    const sharedCount = shares.length;

    res.status(200).json({
      success: true,
      data: {
        assigned: assignedCount,
        primary: primaryCount,
        created: createdCount,
        shared: sharedCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Thong ke cong viec sap den han va qua han
// @route   GET /api/statistics/deadlines
// @access  Private
exports.getDeadlineStats = async (req, res) => {
  try {
    const filter = await getUserAccessibleTaskFilter(req.user.id);
    const now = new Date();
    const next48Hours = new Date(now.getTime() + 48 * 60 * 60 * 1000);

    // Overdue: dueDate < now & status != completed
    const overdueCount = await Task.countDocuments({
      ...filter,
      dueDate: { $lt: now },
      status: { $ne: 'completed' }
    });

    // Upcoming: now <= dueDate <= next48Hours & status != completed
    const upcomingCount = await Task.countDocuments({
      ...filter,
      dueDate: { $gte: now, $lte: next48Hours },
      status: { $ne: 'completed' }
    });

    // Completed on time / normal
    const completedCount = await Task.countDocuments({
      ...filter,
      status: 'completed'
    });

    res.status(200).json({
      success: true,
      data: {
        overdue: overdueCount,
        upcoming: upcomingCount,
        completed: completedCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
