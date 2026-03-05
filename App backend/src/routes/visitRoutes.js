const express = require('express');
const { logVisit, getVisits } = require('../controllers/visitController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

router.use(authMiddleware);

router.post('/', logVisit);
router.get('/', getVisits);

module.exports = router;
