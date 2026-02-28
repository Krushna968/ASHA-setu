const { PrismaClient } = require('@prisma/client');
require('dotenv').config();
const prisma = new PrismaClient();

async function findSpecificWorker() {
    try {
        const workers = await prisma.worker.findMany();
        console.log(`Total workers found: ${workers.length}`);

        const target = workers.find(w => w.mobileNumber === '9321609760');
        if (target) {
            console.log('✅ FOUND worker 9321609760');
            console.log(JSON.stringify(target, null, 2));
        } else {
            console.log('❌ worker 9321609760 NOT FOUND in the current database.');
            console.log('Current workers in DB:');
            workers.forEach(w => console.log(`- ${w.name} (${w.mobileNumber})`));
        }
    } catch (error) {
        console.error('Error:', error);
    } finally {
        await prisma.$disconnect();
    }
}

findSpecificWorker();
