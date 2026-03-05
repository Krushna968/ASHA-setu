const express = require('express');
const router = express.Router();
const learningController = require('../controllers/learningController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, learningController.getModules);
router.post('/progress', authMiddleware, learningController.updateProgress);

module.exports = router;
