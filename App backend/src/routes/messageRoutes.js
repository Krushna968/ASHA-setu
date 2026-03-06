const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, messageController.getMessages);
router.post('/', authMiddleware, messageController.sendMessage);

// Admin-only: fetch all messages forwarded to admin (e.g. from SakhiAI)
router.get('/admin', messageController.getAdminMessages);

module.exports = router;
