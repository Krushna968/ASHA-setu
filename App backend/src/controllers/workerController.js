const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

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

        res.json({
            patients: worker._count.patients,
            tasks: worker._count.tasks,
            totalVisits: worker.totalVisits,
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

module.exports = { getWorkerStats, updateProfileImage };
