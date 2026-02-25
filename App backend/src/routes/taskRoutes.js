const express = require('express');
const { getTasks, updateTaskStatus } = require('../controllers/taskController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.get('/', getTasks);
router.put('/:taskId/status', updateTaskStatus);

module.exports = router;
