const cron = require('node-cron');
const prisma = require('../lib/prisma');

const startCronJobs = () => {
    // Schedule tasks to be run on the server
    // For production this could be '0 0 1 * *' (run at midnight on the first of every month)
    // For mock testing, running it every day at midnight '0 0 * * *'

    cron.schedule('0 0 * * *', async () => {
        console.log('⏰ [CRON] Running HMIS Data Aggregation...');

        try {
            // Aggregate total visits this month
            const startOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1);

            const totalVisits = await prisma.visitHistory.count({
                where: {
                    visitDate: {
                        gte: startOfMonth
                    }
                }
            });

            const totalPatients = await prisma.patient.count();
            const totalWorkers = await prisma.worker.count();

            const aggregatedData = {
                timestamp: new Date().toISOString(),
                totalWorkers,
                totalPatients,
                totalVisitsThisMonth: totalVisits
            };

            // In a real scenario, we would push this to a Government API using Axios/Fetch
            // e.g. await axios.post('https://hmis.gov.in/api/v1/sync', aggregatedData);

            console.log('📊 [CRON] HMIS Aggregation Payload Prepared:', aggregatedData);
            console.log('✅ [CRON] Mock HMIS sync successful.');

        } catch (error) {
            console.error('❌ [CRON] HMIS Sync Error:', error);
        }
    });

    console.log('⏱️ Cron jobs initialized.');
};

module.exports = { startCronJobs };
