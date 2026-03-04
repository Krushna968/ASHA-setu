const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Add a new patient
const addPatient = async (req, res) => {
    try {
        const { name, age, category, address, householdId, relation, gender } = req.body;
        const workerId = req.user.id; // from JWT token auth middleware

        if (!name || !age || !category) {
            return res.status(400).json({ error: 'Name, age, and category are required' });
        }

        // Build patient data
        const patientData = {
            name,
            age: parseInt(age),
            category,
            workerId,
            relation: relation || null,
            gender: gender || null,
        };

        // If householdId is provided, link to household (preferred over address)
        if (householdId) {
            // Verify household exists and belongs to this worker
            const household = await prisma.household.findFirst({
                where: { id: householdId, workerId }
            });
            if (!household) {
                return res.status(404).json({ error: 'Household not found' });
            }
            patientData.householdId = householdId;
            patientData.address = household.address; // Inherit address from household
        } else if (address) {
            patientData.address = address;
        }

        const patient = await prisma.patient.create({ data: patientData });

        // If linked to a household, recalculate household status
        if (householdId) {
            await _recalcHouseholdStatus(householdId);
        }

        // Return the patient with household info
        const fullPatient = await prisma.patient.findUnique({
            where: { id: patient.id },
            include: {
                household: { select: { houseNumber: true, headName: true } }
            }
        });

        res.status(201).json({ message: 'Patient added successfully', patient: fullPatient });
    } catch (error) {
        console.error("addPatient error", error);
        res.status(500).json({ error: 'Failed to add patient' });
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

// Get all patients for the logged-in worker
const getWorkerPatients = async (req, res) => {
    try {
        const workerId = req.user.id;

        const patients = await prisma.patient.findMany({
            where: { workerId },
            include: {
                visitHistory: {
                    orderBy: { visitDate: 'desc' },
                    take: 1
                },
                household: {
                    select: { houseNumber: true, headName: true }
                }
            },
            orderBy: { name: 'asc' }
        });

        res.json({ patients });
    } catch (error) {
        console.error("getWorkerPatients error", error);
        res.status(500).json({ error: 'Failed to retrieve patients' });
    }
};

// Get single patient details
const getPatientDetails = async (req, res) => {
    try {
        const { patientId } = req.params;
        const workerId = req.user.id;

        const patient = await prisma.patient.findFirst({
            where: {
                id: patientId,
                workerId: workerId
            },
            include: {
                visitHistory: {
                    orderBy: { visitDate: 'desc' }
                },
                household: {
                    select: { houseNumber: true, headName: true, address: true }
                }
            }
        });

        if (!patient) {
            return res.status(404).json({ error: 'Patient not found' });
        }

        res.json({ patient });
    } catch (error) {
        console.error("getPatientDetails error", error);
        res.status(500).json({ error: 'Failed to retrieve patient details' });
    }
};

module.exports = { addPatient, getWorkerPatients, getPatientDetails };
