const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const reports = await prisma.report.findMany({
        include: { worker: true }
    });
    console.log('Total Reports:', reports.length);
    reports.forEach(r => {
        console.log(`ID: ${r.id}, Date: ${r.date}, Worker: ${r.worker.name} (${r.worker.id})`);
    });
    process.exit(0);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
