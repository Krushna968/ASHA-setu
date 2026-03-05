const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function addSwar() {
    try {
        const worker = await prisma.worker.upsert({
            where: { mobileNumber: '7387088205' },
            update: {
                name: 'Swar Shinde',
                village: 'Airoli'
            },
            create: {
                employeeId: 'ASHA-' + Date.now(),
                name: 'Swar Shinde',
                mobileNumber: '7387088205',
                village: 'Airoli'
            }
        });
        console.log(`Worker ${worker.name} (7387088205) registered/updated successfully in ${worker.village}!`);
    } catch (error) {
        console.error("Error registering worker:", error);
    }
}

addSwar()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
