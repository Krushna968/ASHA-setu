const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addWorker() {
    await prisma.worker.upsert({
        where: { mobileNumber: '9029232428' },
        update: {},
        create: {
            employeeId: 'ASHA-' + Date.now(),
            name: 'Rajat (Demo User)',
            mobileNumber: '9029232428',
            village: 'Demo Village 3'
        }
    });
    console.log("Worker 9029232428 registered successfully!");
}

addWorker().catch(console.error).finally(() => prisma.$disconnect());
