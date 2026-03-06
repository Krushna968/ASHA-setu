const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log('--- Checking Visits ---');
    const visits = await prisma.visitHistory.findMany({
        include: {
            patient: true,
            worker: {
                select: {
                    name: true,
                    employeeId: true
                }
            }
        }
    });

    console.log(`Total visits in DB: ${visits.length}`);
    visits.forEach(v => {
        console.log(`Visit ID: ${v.id}`);
        console.log(`  Date: ${v.visitDate}`);
        console.log(`  Worker: ${v.worker.name} (${v.workerId})`);
        console.log(`  Patient: ${v.patient?.name} (${v.patientId})`);
        console.log(`  Outcome: ${v.outcome}`);
        console.log('---');
    });

    console.log('\n--- Checking Patients ---');
    const patients = await prisma.patient.findMany();
    console.log(`Total patients in DB: ${patients.length}`);

    console.log('\n--- Checking Workers ---');
    const workers = await prisma.worker.findMany();
    console.log(`Total workers in DB: ${workers.length}`);
}

main()
    .catch(e => console.error(e))
    .finally(async () => {
        await prisma.$disconnect();
    });
