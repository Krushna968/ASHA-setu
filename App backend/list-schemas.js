const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function listSchemas() {
    try {
        console.log('--- Listing Schemas ---');
        const schemas = await prisma.$queryRaw`SELECT schema_name FROM information_schema.schemata`;
        console.log('Schemas:', schemas.map(s => s.schema_name));

        console.log('\n--- Listing All Tables (any schema) ---');
        const tables = await prisma.$queryRaw`SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'pg_catalog')`;
        console.table(tables);

    } catch (e) {
        console.error('Failed to list schemas:', e);
    } finally {
        await prisma.$disconnect();
    }
}

listSchemas();
