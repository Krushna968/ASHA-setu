const express = require('express');
const { addPatient, getWorkerPatients, getPatientDetails } = require('../controllers/patientController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// All patient routes require authentication
router.use(authMiddleware);

router.post('/', addPatient);
router.get('/', getWorkerPatients);
router.get('/:patientId', getPatientDetails);

module.exports = router;
