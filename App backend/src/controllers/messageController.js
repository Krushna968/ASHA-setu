const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

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

module.exports = { getMessages, sendMessage };
