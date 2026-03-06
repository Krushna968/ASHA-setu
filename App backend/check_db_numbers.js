const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const workers = await prisma.worker.findMany({
        take: 5,
        select: {
            mobileNumber: true,
            name: true
        }
    });
    console.log('Sample Workers:');
    console.log(JSON.stringify(workers, null, 2));
}

main()
    .catch(e => console.error(e))
    .finally(async () => {
        await prisma.$disconnect();
    });
