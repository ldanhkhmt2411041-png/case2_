const express = require('express');
const router = express.Router();
const {
  getTaskStats,
  getAssignmentStats,
  getDeadlineStats
} = require('../controllers/statisticsController');
const { protect } = require('../middlewares/authMiddleware');

router.use(protect);

router.get('/tasks', getTaskStats);
router.get('/assignments', getAssignmentStats);
router.get('/deadlines', getDeadlineStats);

module.exports = router;
