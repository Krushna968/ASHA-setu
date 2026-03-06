const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function inspect() {
    try {
        const workerCount = await prisma.worker.count().catch(e => { console.log('Worker table fail:', e.message); return -1; });
        const visitCount = await prisma.visitHistory.count().catch(e => { console.log('Visit table fail:', e.message); return -1; });
        const patientCount = await prisma.patient.count().catch(e => { console.log('Patient table fail:', e.message); return -1; });
        const householdCount = await prisma.household.count().catch(e => { console.log('Household table fail:', e.message); return -1; });
        const taskCount = await prisma.task.count().catch(e => { console.log('Task table fail:', e.message); return -1; });

        // Fetch sample data
        const workers = await prisma.worker.findMany({ select: { id: true, name: true, mobileNumber: true }, take: 5 });
        const households = await prisma.household.findMany({ take: 5 }); // Fetching a sample of households

        console.log('--- DB STATS ---');
        console.log(`Workers: ${workerCount}`);
        console.log(`Visits: ${visitCount}`);
        console.log(`Patients: ${patientCount}`);
        console.log(`Households: ${householdCount}`);
        console.log(`Tasks: ${taskCount}`);

        if (workerCount > 0) {
            console.log('Sample Workers:', workers.map(w => ({ id: w.id, name: w.name, mobile: w.mobileNumber })));
        }
        if (householdCount > 0) {
            console.log('Sample Households:', households.map(h => ({ houseNumber: h.houseNumber, village: h.village, workerId: h.workerId })));
        }

    } catch (e) {
        console.error('Inspection failed:', e);
    } finally {
        await prisma.$disconnect();
    }
}

inspect();
