const express = require('express');
const router = express.Router();
const { retryEmailLog } = require('../controllers/emailLogController');
const { protect } = require('../middlewares/authMiddleware');

router.use(protect);

router.post('/:id/retry', retryEmailLog);

module.exports = router;
