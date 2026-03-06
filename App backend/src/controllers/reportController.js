const prisma = require('../lib/prisma');

exports.submitDailyReport = async (req, res) => {
    try {
        const { workerId, reportData } = req.body;

        if (!workerId || !reportData) {
            return res.status(400).json({ error: 'Worker ID and report data are required' });
        }

        // Check if report for today already exists (optional, but good for cleanliness)
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const report = await prisma.report.create({
            data: {
                workerId,
                content: reportData,
                date: new Date(),
            }
        });

        res.status(201).json({
            message: 'Report submitted successfully',
            reportId: report.id
        });
    } catch (error) {
        console.error('Error submitting report:', error);
        res.status(500).json({ error: 'Failed to submit report' });
    }
};

exports.getWorkerReports = async (req, res) => {
    try {
        const { workerId } = req.params;

        const reports = await prisma.report.findMany({
            where: { workerId },
            orderBy: { date: 'desc' }
        });

        res.json(reports);
    } catch (error) {
        console.error('Error fetching reports:', error);
        res.status(500).json({ error: 'Failed to fetch reports' });
    }
};

exports.generateMonthlyReportPdf = async (req, res) => {
    try {
        const workerId = req.user?.id;
        if (!workerId) return res.status(401).json({ error: 'Unauthorized' });

        const reports = await prisma.report.findMany({
            where: { workerId },
            orderBy: { date: 'desc' },
            take: 30
        });

        res.json({
            message: 'Report data retrieved. PDF generation is handled client-side.',
            reports
        });
    } catch (error) {
        console.error('Error generating report:', error);
        res.status(500).json({ error: 'Failed to generate report' });
    }
};
