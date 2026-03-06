const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const authMiddleware = require('../middleware/authMiddleware');

// Submit a daily report
router.post('/daily', authMiddleware, reportController.submitDailyReport);

// Get reports for a specific worker
router.get('/worker/:workerId', authMiddleware, reportController.getWorkerReports);

module.exports = router;
