const Task = require('../models/Task');
const User = require('../models/User');
const { createNotification } = require('./notificationService');
const { sendEmail } = require('./emailService');

// Kiem tra cac cong viec sap den han trong vong 24h
const checkUpcomingDeadlines = async () => {
  try {
    const now = new Date();
    const next24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);

    const upcomingTasks = await Task.find({
      dueDate: { $gte: now, $lte: next24Hours },
      status: { $ne: 'completed' }
    })
      .populate('createdBy', 'fullName email')
      .populate('assigneeIds', 'fullName email')
      .populate('primaryAssigneeId', 'fullName email');

    for (const task of upcomingTasks) {
      // Gui thong bao cho nguoi phu trach chinh hoac tat ca assignees
      const recipients = [];
      if (task.primaryAssigneeId) {
        recipients.push(task.primaryAssigneeId);
      }
      if (task.assigneeIds && task.assigneeIds.length > 0) {
        task.assigneeIds.forEach(a => {
          if (!recipients.some(r => r._id.toString() === a._id.toString())) {
            recipients.push(a);
          }
        });
      }
      if (task.createdBy && !recipients.some(r => r._id.toString() === task.createdBy._id.toString())) {
        recipients.push(task.createdBy);
      }

      for (const recipient of recipients) {
        // Tao in-app notification
        await createNotification({
          userId: recipient._id,
          taskId: task._id,
          type: 'deadline_reminder',
          title: `[Nhac viec] Cong viec "${task.title}" sap den han!`,
          message: `Cong viec co han chot vao luc ${new Date(task.dueDate).toLocaleString('vi-VN')}. Vui long kiem tra va hoan thanh.`
        });

        // Gui email
        if (recipient.email) {
          await sendEmail({
            recipientEmail: recipient.email,
            subject: `[Nhắc việc] Công việc "${task.title}" sắp đến hạn hoàn thành`,
            html: `
              <h3>Nhắc việc trước hạn</h3>
              <p>Xin chào <strong>${recipient.fullName || recipient.email}</strong>,</p>
              <p>Công việc <strong>${task.title}</strong> sắp đến hạn vào lúc: <strong>${new Date(task.dueDate).toLocaleString('vi-VN')}</strong>.</p>
              <p>Mức độ ưu tiên: ${task.priority.toUpperCase()}</p>
              <p>Trạng thái hiện tại: ${task.status.toUpperCase()}</p>
              <p>Vui lòng đăng nhập TaskManager để cập nhật tiến độ công việc.</p>
            `,
            taskId: task._id,
            eventType: 'deadline_reminder'
          });
        }
      }
    }
  } catch (error) {
    console.error('Loi khi kiem tra deadline reminder:', error.message);
  }
};

// Khoi dong scheduler dinh ky moi 1 gio
exports.startReminderScheduler = (intervalMs = 60 * 60 * 1000) => {
  console.log('⏰ Khoi dong tien trinh tu dong nhac viec truoc han 24 gio...');
  // Chay ngay 1 lan khi server start
  setTimeout(checkUpcomingDeadlines, 5000);
  // Dinh ky
  return setInterval(checkUpcomingDeadlines, intervalMs);
};

exports.checkUpcomingDeadlines = checkUpcomingDeadlines;
