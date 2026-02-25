const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function main() {
    const w = await prisma.worker.findFirst();
    if (w) {
        console.log("WORKER:", w.mobileNumber);
    } else {
        console.log("NO WORKER FOUND");
        // let's create a mock worker
        const nw = await prisma.worker.create({
            data: {
                employeeId: "ASHA-" + Date.now(),
                name: "Test Worker",
                mobileNumber: "9999999999",
                village: "Test Village"
            }
        });
        console.log("CREATED MOCK:", nw.mobileNumber);
    }
}
main().catch(console.error).finally(() => prisma.$disconnect());
