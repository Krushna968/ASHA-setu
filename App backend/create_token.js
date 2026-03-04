const { PrismaClient } = require('@prisma/client');
const jwt = require('jsonwebtoken');
const fs = require('fs');
require('dotenv').config();

const prisma = new PrismaClient();

async function main() {
    const mobileNumber = '9321609760';

    try {
        const worker = await prisma.worker.findUnique({
            where: { mobileNumber },
            include: {
                _count: {
                    select: { patients: true, tasks: true }
                }
            }
        });

        if (!worker) {
            console.log("Worker not found");
            return;
        }

        const token = jwt.sign(
            { id: worker.id, employeeId: worker.employeeId, mobileNumber: worker.mobileNumber },
            process.env.JWT_SECRET || 'secretKey123',
            { expiresIn: '365d' }
        );

        const workerData = {
            id: worker.id,
            name: worker.name,
            employeeId: worker.employeeId,
            village: worker.village,
            stats: {
                patients: worker._count.patients,
                tasks: worker._count.tasks,
                totalVisits: worker.totalVisits
            }
        };

        const result = { token, worker: workerData };
        fs.writeFileSync('bypass.json', JSON.stringify(result, null, 2), 'utf8');
        console.log("Saved to bypass.json");

    } catch (e) {
        console.error("Error:", e);
    } finally {
        await prisma.$disconnect();
    }
}

main();
