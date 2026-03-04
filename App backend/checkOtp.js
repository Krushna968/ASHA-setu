const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const mobileNumber = '9321609760';

    try {
        const worker = await prisma.worker.findUnique({
            where: { mobileNumber }
        });
        console.log(`Worker: ${worker.name}, OTP: ${worker.otp}, Expiry: ${worker.otpExpiry}, Now: ${new Date()}`);
    } catch (e) {
        console.error("Error:", e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
