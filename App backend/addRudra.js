const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addRudra() {
    await prisma.worker.upsert({
        where: { mobileNumber: '8652075823' },
        update: {},
        create: {
            employeeId: 'ASHA-RUDRA-001',
            name: 'Rudra',
            mobileNumber: '8652075823',
            village: 'Panvel',
            gender: 'Male'
        }
    });
    console.log("Worker Rudra (8652075823) registered successfully in Panvel!");
}

addRudra().catch(console.error).finally(() => prisma.$disconnect());
