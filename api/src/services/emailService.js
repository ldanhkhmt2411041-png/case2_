const nodemailer = require('nodemailer');
const EmailLog = require('../models/EmailLog');

// Khoi tao transporter nodemailer
const getTransporter = () => {
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
};

exports.sendEmail = async ({ recipientEmail, subject, html, taskId = null, eventType = 'general' }) => {
  // Luu ban ghi EmailLog pending
  const log = await EmailLog.create({
    taskId,
    recipientEmail,
    eventType,
    subject,
    status: 'pending',
    attempts: 1
  });

  // Kiem tra cau hinh email
  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    const errorMsg = 'Chua cau hinh EMAIL_USER hoac EMAIL_PASS trong .env';
    console.warn(`[Email Warning] ${errorMsg}`);
    log.status = 'failed';
    log.errorMessage = errorMsg;
    await log.save();
    return { success: false, message: errorMsg, log };
  }

  try {
    const transporter = getTransporter();
    const mailOptions = {
      from: `"Task Manager" <${process.env.EMAIL_USER}>`,
      to: recipientEmail,
      subject,
      html
    };

    await transporter.sendMail(mailOptions);

    log.status = 'sent';
    log.sentAt = new Date();
    log.errorMessage = null;
    await log.save();

    return { success: true, log };
  } catch (error) {
    console.error(`[Email Error] Gui email that bai den ${recipientEmail}:`, error.message);
    log.status = 'failed';
    log.errorMessage = error.message;
    await log.save();

    return { success: false, error: error.message, log };
  }
};

exports.retryEmail = async (logId) => {
  const log = await EmailLog.findById(logId);
  if (!log) {
    throw new Error('Khong tim thay ban ghi lich su email');
  }

  log.attempts += 1;
  log.status = 'pending';
  await log.save();

  if (!process.env.EMAIL_USER || !process.env.EMAIL_PASS) {
    log.status = 'failed';
    log.errorMessage = 'Chua cau hinh EMAIL_USER hoac EMAIL_PASS trong .env';
    await log.save();
    return { success: false, log };
  }

  try {
    const transporter = getTransporter();
    const mailOptions = {
      from: `"Task Manager" <${process.env.EMAIL_USER}>`,
      to: log.recipientEmail,
      subject: log.subject,
      html: `<p>Thu lai gui email cho su kien: ${log.eventType}</p>`
    };

    await transporter.sendMail(mailOptions);

    log.status = 'sent';
    log.sentAt = new Date();
    log.errorMessage = null;
    await log.save();

    return { success: true, log };
  } catch (error) {
    log.status = 'failed';
    log.errorMessage = error.message;
    await log.save();
    return { success: false, error: error.message, log };
  }
};
