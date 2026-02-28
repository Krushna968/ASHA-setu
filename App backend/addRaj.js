const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addRaj() {
    await prisma.worker.upsert({
        where: { mobileNumber: '9137113650' },
        update: {},
        create: {
            employeeId: 'ASHA-RAJ-001',
            name: 'Raj',
            mobileNumber: '9137113650',
            village: 'Kalyan',
            gender: 'Male'
        }
    });
    console.log("Worker Raj (9137113650) registered successfully in Kalyan!");
}

addRaj().catch(console.error).finally(() => prisma.$disconnect());
