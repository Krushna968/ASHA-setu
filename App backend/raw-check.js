const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function rawCheck() {
    try {
        const workers = await prisma.$queryRaw`SELECT count(*) FROM "Worker"`;
        console.log('Raw Worker count:', workers);

        const visits = await prisma.$queryRaw`SELECT count(*) FROM "VisitHistory"`;
        console.log('Raw Visit count:', visits);

        const tables = await prisma.$queryRaw`SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'`;
        console.log('Tables:', tables);

    } catch (e) {
        console.error('Raw check failed:', e);
    } finally {
        await prisma.$disconnect();
    }
}

rawCheck();
