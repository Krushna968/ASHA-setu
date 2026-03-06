require('dotenv').config();
const { calculatePatientRisk, generateDailyItinerary } = require('./src/services/aiIntelligenceService');
const prisma = require('./src/lib/prisma');

async function testAI() {
    try {
        console.log("Finding a worker...");
        const worker = await prisma.worker.findFirst({
            include: { patients: true }
        });

        if (!worker) {
            console.log("No workers found in DB.");
            return;
        }

        console.log(`Testing with Worker: ${worker.name} (ID: ${worker.id})`);

        if (worker.patients && worker.patients.length > 0) {
            const testPatient = worker.patients[0];
            console.log(`\n--- Testing Patient Risk for: ${testPatient.name} ---`);
            const riskResult = await calculatePatientRisk(testPatient.id);
            console.log("Risk Result:", riskResult);
        } else {
            console.log("No patients found for this worker to test risk score.");
        }

        console.log(`\n--- Testing Daily Itinerary generation ---`);
        const itinerary = await generateDailyItinerary(worker.id);
        console.log("Itinerary Result:", JSON.stringify(itinerary, null, 2));

    } catch (e) {
        console.error("Test failed:", e);
    } finally {
        await prisma.$disconnect();
    }
}

testAI();
