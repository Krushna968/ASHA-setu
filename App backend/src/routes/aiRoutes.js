const express = require('express');
const router = express.Router();
const aiController = require('../controllers/aiController');
const authMiddleware = require('../middleware/authMiddleware');

// Route to manually test calculating patient risk
router.post('/risk', authMiddleware, aiController.calculatePatientRisk);

// Route to generate or fetch the daily AI itinerary for the current worker
router.get('/itinerary', authMiddleware, aiController.generateDailyItinerary);

module.exports = router;
