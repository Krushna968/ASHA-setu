const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const mobileNumber = '9321609760';
    const otp = '123456';
    const otpExpiry = new Date(Date.now() + 60 * 60000); // 1 hour

    try {
        const worker = await prisma.worker.update({
            where: { mobileNumber },
            data: { otp, otpExpiry }
        });
        console.log(`Successfully set OTP to ${otp} for ${worker.name} (${worker.mobileNumber})`);
    } catch (e) {
        console.error("Error setting OTP:", e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
