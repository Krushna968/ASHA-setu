const prisma = require('../lib/prisma');

// Worker fetches their own messages
const getMessages = async (req, res) => {
    try {
        const workerId = req.user.id;

        const messages = await prisma.message.findMany({
            where: {
                OR: [
                    { senderId: workerId, senderType: 'WORKER' },
                    { receiverId: workerId, receiverType: 'WORKER' }
                ]
            },
            orderBy: { createdAt: 'desc' }
        });

        res.json(messages);
    } catch (err) {
        console.error("Messages Fetch Error:", err);
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
};

// Admin fetches all messages sent TO admin (from SakhiAI forwarding)
const getAdminMessages = async (req, res) => {
    try {
        const messages = await prisma.message.findMany({
            where: { receiverType: 'ADMIN' },
            orderBy: { createdAt: 'desc' }
        });

        // Enrich with worker name
        const enriched = await Promise.all(
            messages.map(async (msg) => {
                let workerName = 'Unknown Worker';
                let workerVillage = '';
                let workerEmployeeId = '';
                try {
                    const worker = await prisma.worker.findUnique({
                        where: { id: msg.senderId },
                        select: { name: true, village: true, employeeId: true }
                    });
                    if (worker) {
                        workerName = worker.name;
                        workerVillage = worker.village;
                        workerEmployeeId = worker.employeeId;
                    }
                } catch (_) { }
                return { ...msg, workerName, workerVillage, workerEmployeeId };
            })
        );

        res.json(enriched);
    } catch (err) {
        console.error("Admin Messages Fetch Error:", err);
        res.status(500).json({ error: 'Failed to fetch admin messages' });
    }
};

const sendMessage = async (req, res) => {
    try {
        const workerId = req.user.id;
        const { content, receiverId, receiverType } = req.body;

        if (!content || !receiverId || !receiverType) {
            return res.status(400).json({ error: 'Content, receiverId, and receiverType are required' });
        }

        const message = await prisma.message.create({
            data: {
                content,
                senderId: workerId,
                senderType: 'WORKER',
                receiverId,
                receiverType
            }
        });

        res.json({ message: 'Message sent successfully', data: message });
    } catch (err) {
        console.error("Send Message Error:", err);
        res.status(500).json({ error: 'Failed to send message' });
    }
};

module.exports = { getMessages, getAdminMessages, sendMessage };
