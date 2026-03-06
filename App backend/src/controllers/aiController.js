const { calculatePatientRisk, generateDailyItinerary } = require('../services/aiIntelligenceService');

exports.calculatePatientRisk = async (req, res) => {
    try {
        const { patientId } = req.body;
        if (!patientId) {
            return res.status(400).json({ error: 'patientId is required' });
        }

        const result = await calculatePatientRisk(patientId);
        res.status(200).json(result);
    } catch (error) {
        console.error('Error calculating patient risk:', error);
        res.status(500).json({ error: 'Failed to calculate patient risk', details: error.message });
    }
};

exports.generateDailyItinerary = async (req, res) => {
    try {
        const workerId = req.user.id; // From authMiddleware

        const itinerary = await generateDailyItinerary(workerId);
        res.status(200).json({ itinerary });
    } catch (error) {
        console.error('Error generating daily itinerary:', error);
        res.status(500).json({ error: 'Failed to generate daily itinerary', details: error.message });
    }
};
