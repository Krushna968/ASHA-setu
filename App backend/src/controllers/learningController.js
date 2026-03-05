const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const getModules = async (req, res) => {
    try {
        const workerId = req.user.id;

        // Fetch all modules
        const modules = await prisma.learningModule.findMany({
            include: {
                progress: {
                    where: { workerId }
                }
            }
        });

        // Format to include status directly
        const formattedModules = modules.map(m => ({
            id: m.id,
            title: m.title,
            description: m.description,
            contentUrl: m.contentUrl,
            durationMin: m.durationMin,
            status: m.progress.length > 0 ? m.progress[0].status : 'NOT_STARTED'
        }));

        res.json(formattedModules);
    } catch (err) {
        console.error("Learning Modules Fetch Error:", err);
        res.status(500).json({ error: 'Failed to fetch learning modules' });
    }
};

const updateProgress = async (req, res) => {
    try {
        const workerId = req.user.id;
        const { moduleId, status } = req.body;

        if (!moduleId || !status) {
            return res.status(400).json({ error: 'Module ID and status are required' });
        }

        const progress = await prisma.learningProgress.upsert({
            where: {
                workerId_moduleId: { workerId, moduleId }
            },
            update: {
                status,
                completedAt: status === 'COMPLETED' ? new Date() : null
            },
            create: {
                workerId,
                moduleId,
                status,
                completedAt: status === 'COMPLETED' ? new Date() : null
            }
        });

        res.json({ message: 'Learning progress updated', progress });
    } catch (err) {
        console.error("Update Progress Error:", err);
        res.status(500).json({ error: 'Failed to update learning progress' });
    }
};

module.exports = { getModules, updateProgress };
