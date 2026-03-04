const express = require('express');
const {
    createHousehold,
    getWorkerHouseholds,
    getHouseholdDetail,
    closeHousehold,
    updateHouseholdStatus
} = require('../controllers/householdController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// All household routes require authentication
router.use(authMiddleware);

router.post('/', createHousehold);
router.get('/', getWorkerHouseholds);
router.get('/:id', getHouseholdDetail);
router.put('/:id/status', updateHouseholdStatus);
router.put('/:id/close', closeHousehold);

module.exports = router;
