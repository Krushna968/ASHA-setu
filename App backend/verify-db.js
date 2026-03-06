const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function check() {
    try {
        console.log('--- DB Check Starting ---');
        const workers = await prisma.worker.findMany();
        console.log(`Total Workers: ${workers.length}`);
        workers.forEach(w => console.log(`Worker: ${w.name} (${w.mobileNumber}) ID: ${w.id}`));

        const visits = await prisma.visitHistory.count();
        console.log(`Total Visits: ${visits}`);

        const demoWorker = await prisma.worker.findUnique({
            where: { mobileNumber: '9321609760' }
        });
        console.log(`Demo Worker found: ${demoWorker ? 'YES' : 'NO'}`);

    } catch (e) {
        console.error('Check failed:', e);
    } finally {
        await prisma.$disconnect();
    }
}

check();
