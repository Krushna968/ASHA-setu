const prisma = require('../lib/prisma');

// Log a visit
const logVisit = async (req, res) => {
    try {
        const { patientId, visitDate, outcome, visitType, symptoms, notes, isHouseClosed, bloodPressure, weight, temperature } = req.body;
        const workerId = req.user.id; // from JWT token

        if (!patientId || !outcome) {
            return res.status(400).json({ error: 'Patient ID and Outcome are required' });
        }

        const visit = await prisma.visitHistory.create({
            data: {
                workerId,
                patientId,
                visitDate: visitDate ? new Date(visitDate) : new Date(),
                outcome,
                visitType: visitType || null,
                symptoms: symptoms || null,
                notes: notes || null,
                isHouseClosed: isHouseClosed || false,
                bloodPressure: bloodPressure || null,
                weight: weight ? parseFloat(weight) : null,
                temperature: temperature ? parseFloat(temperature) : null,
            }
        });

        // Increment worker's total visits
        await prisma.worker.update({
            where: { id: workerId },
            data: { totalVisits: { increment: 1 } }
        });

        // If the patient belongs to a household, update household state
        const patient = await prisma.patient.findUnique({
            where: { id: patientId },
            select: { householdId: true }
        });

        if (patient?.householdId) {
            // If worker marked house as closed during this visit
            if (isHouseClosed) {
                await prisma.household.update({
                    where: { id: patient.householdId },
                    data: { isClosed: true, status: 'closed' }
                });
            } else {
                // Recalculate household status
                await _recalcHouseholdStatus(patient.householdId);
            }
        }

        res.status(201).json({ message: 'Visit logged successfully', visit });
    } catch (error) {
        console.error("logVisit error", error);
        res.status(500).json({ error: 'Failed to log visit' });
    }
};

// Helper: recalculate household status
async function _recalcHouseholdStatus(householdId) {
    try {
        const household = await prisma.household.findUnique({
            where: { id: householdId },
            include: {
                familyMembers: { select: { category: true } }
            }
        });
        if (!household || household.isClosed) return;

        const pendingTasks = await prisma.task.count({
            where: { householdId, status: { not: 'COMPLETED' } }
        });

        const hasHighRisk = household.familyMembers.some(
            m => m.category === 'ANC' || m.category === 'PNC'
        );

        let status;
        if (pendingTasks > 0) {
            status = hasHighRisk ? 'high-risk' : 'pending';
        } else if (household.familyMembers.length > 0) {
            status = 'completed';
        } else {
            status = 'pending';
        }

        await prisma.household.update({
            where: { id: householdId },
            data: { status, pendingTasksCount: pendingTasks }
        });
    } catch (e) {
        console.error("_recalcHouseholdStatus error", e);
    }
}

// Get visits for the logged-in worker
const getVisits = async (req, res) => {
    try {
        const workerId = req.user.id;
        console.log(`[Backend] Fetching visits for workerId: ${workerId}`);

        const visits = await prisma.visitHistory.findMany({
            where: { workerId },
            include: {
                patient: {
                    select: {
                        name: true,
                        category: true,
                        household: { select: { houseNumber: true } }
                    }
                }
            },
            orderBy: { visitDate: 'desc' }
        });

        res.status(200).json({ visits });
    } catch (error) {
        console.error("getVisits error", error);
        res.status(500).json({ error: 'Failed to fetch visits' });
    }
};

module.exports = { logVisit, getVisits };
