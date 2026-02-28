const { PrismaClient } = require('@prisma/client');
require('dotenv').config();
const prisma = new PrismaClient();

async function listAllWorkers() {
    try {
        const workers = await prisma.worker.findMany();
        console.log('--- List of Workers in Database ---');
        workers.forEach(w => {
            console.log(`Name: ${w.name}, Mobile: ${w.mobileNumber}, Village: ${w.village}`);
        });
        console.log('-----------------------------------');
    } catch (error) {
        console.error('Error fetching workers:', error);
    } finally {
        await prisma.$disconnect();
    }
}

listAllWorkers();
