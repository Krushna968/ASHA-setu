const { PrismaClient } = require('@prisma/client');
const PDFDocument = require('pdfkit');
const prisma = new PrismaClient();

const generateMonthlyReportPdf = async (req, res) => {
    try {
        const workerId = req.user.id;

        // Fetch worker stats
        const worker = await prisma.worker.findUnique({
            where: { id: workerId },
            include: {
                _count: {
                    select: { patients: true, tasks: true }
                },
                visitHistory: {
                    where: {
                        visitDate: {
                            gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1) // Start of current month
                        }
                    }
                }
            }
        });

        if (!worker) {
            return res.status(404).json({ error: 'Worker not found' });
        }

        // Create PDF document
        const doc = new PDFDocument({ margin: 50 });

        // Setup response headers
        res.setHeader('Content-disposition', 'attachment; filename="ASHA_Monthly_Report.pdf"');
        res.setHeader('Content-type', 'application/pdf');

        doc.pipe(res);

        // Add Header
        doc.fontSize(20).text('ASHA Setu - Monthly Activity Report', { align: 'center' });
        doc.moveDown();
        doc.fontSize(12).text(`Worker Name: ${worker.name}`);
        doc.text(`Employee ID: ${worker.employeeId}`);
        doc.text(`Village: ${worker.village}`);
        doc.text(`Date Generated: ${new Date().toLocaleDateString()}`);
        doc.moveDown();

        // Add Summary Stats
        doc.fontSize(16).text('Summary Statistics', { underline: true });
        doc.fontSize(12).text(`Total Registered Patients: ${worker._count.patients}`);
        doc.text(`Total Tasks Tracked: ${worker._count.tasks}`);
        doc.text(`Total Lifetime Visits: ${worker.totalVisits}`);
        doc.text(`Visits This Month: ${worker.visitHistory.length}`);
        doc.moveDown();

        // Add Recent Visits Table-like structure
        doc.fontSize(16).text('Recent Visits This Month', { underline: true });
        doc.moveDown();

        if (worker.visitHistory.length === 0) {
            doc.fontSize(12).text('No visits recorded this month.');
        } else {
            worker.visitHistory.slice(0, 10).forEach((visit, index) => {
                doc.fontSize(12).text(`${index + 1}. Date: ${new Date(visit.visitDate).toLocaleDateString()} | Outcome: ${visit.outcome}`);
                if (visit.notes) {
                    doc.fontSize(10).text(`   Notes: ${visit.notes}`);
                }
                doc.moveDown(0.5);
            });
        }

        // Add Footer
        doc.moveDown(2);
        doc.fontSize(10).text('This is an auto-generated report for Government HMIS integration.', { align: 'center', color: 'grey' });

        doc.end();

    } catch (error) {
        console.error("PDF Generation Error:", error);
        if (!res.headersSent) {
            res.status(500).json({ error: 'Failed to generate PDF report' });
        }
    }
};

module.exports = { generateMonthlyReportPdf };
