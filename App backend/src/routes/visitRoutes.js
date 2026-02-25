const express = require('express');
const { logVisit } = require('../controllers/visitController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.post('/', logVisit);

module.exports = router;
