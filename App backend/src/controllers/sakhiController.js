const sakhiService = require('../services/sakhiService');

const chatWithSakhi = async (req, res) => {
    try {
        const { message, conversationHistory = [] } = req.body;

        if (!message || !message.trim()) {
            return res.status(400).json({ error: 'Message is required.' });
        }

        // Determine role and context from the authenticated user
        const workerId = req.worker?.id || req.body.workerId || '';
        const workerName = req.worker?.name || req.body.workerName || 'User';
        const workerVillage = req.worker?.village || req.body.workerVillage || '';
        const role = req.body.role || 'worker'; // 'worker' or 'admin'

        const result = await sakhiService.chat(
            message,
            conversationHistory,
            role,
            workerName,
            workerVillage,
            workerId
        );

        res.json({
            reply: result.reply,
            toolsUsed: result.toolsUsed
        });
    } catch (error) {
        console.error('SakhiAI Controller Error:', error);
        res.status(500).json({ error: 'SakhiAI encountered an internal error.' });
    }
};

module.exports = { chatWithSakhi };
