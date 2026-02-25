const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all tasks for worker
const getTasks = async (req, res) => {
    try {
        const workerId = req.user.id;

        const tasks = await prisma.task.findMany({
            where: { workerId },
            orderBy: { dueDate: 'asc' }
        });

        res.json({ tasks });
    } catch (error) {
        console.error("getTasks error", error);
        res.status(500).json({ error: 'Failed to retrieve tasks' });
    }
};

// Update task status
const updateTaskStatus = async (req, res) => {
    try {
        const { taskId } = req.params;
        const { status } = req.body; // 'PENDING', 'IN_PROGRESS', 'COMPLETED'
        const workerId = req.user.id;

        // Verify task belongs to worker
        const task = await prisma.task.findFirst({
            where: { id: taskId, workerId }
        });

        if (!task) {
            return res.status(404).json({ error: 'Task not found' });
        }

        const updatedTask = await prisma.task.update({
            where: { id: taskId },
            data: { status }
        });

        res.json({ message: 'Task updated', task: updatedTask });
    } catch (error) {
        console.error("updateTaskStatus error", error);
        res.status(500).json({ error: 'Failed to update task' });
    }
};

module.exports = { getTasks, updateTaskStatus };
