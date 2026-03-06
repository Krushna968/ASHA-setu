const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function seed() {
    try {
        console.log('--- Seeding Data (v3) ---');
        const targetMobile = '9004962087';

        // 1. Create Worker (from logs)
        const worker = await prisma.worker.upsert({
            where: { mobileNumber: targetMobile },
            update: {},
            create: {
                id: 'worker_9004962087',
                employeeId: 'ASHA-USER-1',
                name: 'Active User',
                mobileNumber: targetMobile,
                village: 'Kharghar',
            }
        });
        console.log('Worker created:', worker.name, targetMobile);

        // 2. Create a Household
        const household = await prisma.household.upsert({
            where: { workerId_houseNumber: { workerId: worker.id, houseNumber: '101' } },
            update: {},
            create: {
                id: 'h_active_1',
                houseNumber: '101',
                workerId: worker.id,
                headName: 'Suresh Patil',
                address: 'Sector 12, Plot 45',
                village: 'Kharghar',
                status: 'pending',
            }
        });
        console.log('Household created:', household.houseNumber);

        // 3. Create a Patient
        const patient = await prisma.patient.upsert({
            where: { id: 'p_active_1' },
            update: {},
            create: {
                id: 'p_active_1',
                name: 'Meena Patil',
                age: 30,
                gender: 'Female',
                householdId: household.id,
                workerId: worker.id,
                category: 'ANC',
            }
        });
        console.log('Patient created:', patient.name);

        // 4. Create a Visit for TODAY
        const today = new Date();
        const visit = await prisma.visitHistory.create({
            data: {
                workerId: worker.id,
                patientId: patient.id,
                visitDate: today,
                outcome: 'Routine Checkup | All clear',
                visitType: 'Routine Checkup',
                notes: 'Seeded visit for active user testing',
            }
        });
        console.log('Visit created for today:', visit.visitDate);

        console.log('--- Seeding Complete ---');
    } catch (e) {
        console.error('Seeding failed:', e);
    } finally {
        await prisma.$disconnect();
    }
}

seed();
