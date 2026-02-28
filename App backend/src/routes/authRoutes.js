const express = require('express');
const { loginWorker, verifyOtp } = require('../controllers/authController');

const router = express.Router();

router.post('/login', loginWorker);
router.post('/verify-otp', verifyOtp);

module.exports = router;
