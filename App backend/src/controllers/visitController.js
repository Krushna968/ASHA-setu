const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Log a visit
const logVisit = async (req, res) => {
    try {
        const { patientId, visitDate, outcome } = req.body;
        const workerId = req.user.id; // from JWT token

        if (!patientId || !outcome) {
            return res.status(400).json({ error: 'Patient ID and Outcome are required' });
        }

        const visit = await prisma.visitHistory.create({
            data: {
                workerId,
                patientId,
                visitDate: visitDate ? new Date(visitDate) : new Date(),
                outcome
            }
        });

        // Increment worker's total visits
        await prisma.worker.update({
            where: { id: workerId },
            data: { totalVisits: { increment: 1 } }
        });

        res.status(201).json({ message: 'Visit logged successfully', visit });
    } catch (error) {
        console.error("logVisit error", error);
        res.status(500).json({ error: 'Failed to log visit' });
    }
};

module.exports = { logVisit };
