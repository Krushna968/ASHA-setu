const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const { chatWithSakhi } = require('../controllers/sakhiController');

// POST /api/sakhi/chat — Send a message to SakhiAI
router.post('/chat', authMiddleware, chatWithSakhi);

module.exports = router;
