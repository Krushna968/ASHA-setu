const prisma = require('../lib/prisma');
const admin = require('firebase-admin');

const getWorkerStats = async (req, res) => {
    try {
        const workerId = req.user.id;

        const worker = await prisma.worker.findUnique({
            where: { id: workerId },
            include: {
                _count: {
                    select: { patients: true, tasks: true }
                }
            }
        });

        if (!worker) {
            return res.status(404).json({ error: 'Worker profile not found' });
        }

        // Calculate Today's Metrics
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);

        // 1. Visits Completed Today
        const completedToday = await prisma.visitHistory.count({
            where: {
                workerId,
                visitDate: {
                    gte: today,
                    lt: tomorrow
                }
            }
        });

        // 2. High-Risk Household Count
        const highRiskCount = await prisma.household.count({
            where: {
                workerId,
                status: 'high-risk',
                isClosed: false
            }
        });

        // 3. Pending Tasks Due Today (or overdue)
        const dueTodayCount = await prisma.task.count({
            where: {
                workerId,
                status: { not: 'COMPLETED' },
                dueDate: { lt: tomorrow }
            }
        });

        res.json({
            patients: worker._count.patients,
            tasks: worker._count.tasks, // Total tasks (for overall progress)
            totalVisits: worker.totalVisits,

            // New action metrics
            completedToday,
            targetToday: 8, // Default target
            highRiskCount,
            dueTodayCount,

            name: worker.name,
            employeeId: worker.employeeId,
            village: worker.village,
            profileImage: worker.profileImage
        });

    } catch (err) {
        console.error("Dashboard Stats Fetch Error:", err);
        res.status(500).json({ error: 'Failed to fetch dashboard statistics' });
    }
}

const updateProfileImage = async (req, res) => {
    try {
        const workerId = req.user.id;

        let imageUrl = req.body.imageUrl; // Fallback for existing clients sending Firebase URLs

        // If Multer processed a file upload, construct the local URL
        if (req.file) {
            const host = req.get('host'); // E.g., '192.168.1.100:5000'
            const protocol = req.protocol; // 'http' or 'https'
            imageUrl = `${protocol}://${host}/uploads/${req.file.filename}`;
        }

        if (!imageUrl) {
            return res.status(400).json({ error: 'Image file or URL is required' });
        }

        const worker = await prisma.worker.update({
            where: { id: workerId },
            data: { profileImage: imageUrl }
        });

        res.json({ message: 'Profile image updated successfully', profileImage: worker.profileImage });
    } catch (err) {
        console.error("Profile Image Update Error:", err);
        res.status(500).json({ error: 'Failed to update profile image' });
    }
};

const updateFcmToken = async (req, res) => {
    try {
        const workerId = req.user.id;
        const { fcmToken } = req.body;

        if (!fcmToken) {
            return res.status(400).json({ error: 'FCM Token is required' });
        }

        const worker = await prisma.worker.update({
            where: { id: workerId },
            data: { fcmToken }
        });

        res.json({ message: 'FCM Token updated successfully' });
    } catch (err) {
        console.error("FCM Token Update Error:", err);
        res.status(500).json({ error: 'Failed to update FCM Token' });
    }
};

const sendTestNotification = async (req, res) => {
    try {
        const workerId = req.user.id;

        const worker = await prisma.worker.findUnique({
            where: { id: workerId }
        });

        if (!worker || !worker.fcmToken) {
            return res.status(404).json({ error: 'Worker or FCM Token not found' });
        }

        const message = {
            notification: {
                title: 'ASHA Setu Test',
                body: 'This is a test notification from the backend!'
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            token: worker.fcmToken
        };

        const response = await admin.messaging().send(message);
        console.log('Successfully sent test message:', response);
        res.json({ message: 'Test notification sent successfully', response });
    } catch (error) {
        console.error('Error sending test notification:', error);
        res.status(500).json({ error: 'Failed to send test notification' });
    }
};

module.exports = { getWorkerStats, updateProfileImage, updateFcmToken, sendTestNotification };
