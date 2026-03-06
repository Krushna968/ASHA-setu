const { PrismaClient } = require('@prisma/client');

// Use a singleton pattern to avoid exhausting DB connections
const prisma = new PrismaClient({
    log: ['error'], // Avoid flooding logs, but keep errors
});

module.exports = prisma;
