const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Add a new patient
const addPatient = async (req, res) => {
    try {
        const { name, age, category, address } = req.body;
        const workerId = req.user.id; // from JWT token auth middleware

        if (!name || !age || !category || !address) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        const patient = await prisma.patient.create({
            data: {
                name,
                age: parseInt(age),
                category,
                address,
                workerId
            }
        });

        res.status(201).json({ message: 'Patient added successfully', patient });
    } catch (error) {
        console.error("addPatient error", error);
        res.status(500).json({ error: 'Failed to add patient' });
    }
};

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
