const jwt = require('jsonwebtoken');
const prisma = require('../lib/prisma');

const authMiddleware = async (req, res, next) => {
    // Get token from header
    const token = req.header('Authorization');

    // Check if no token
    if (!token) {
        return res.status(401).json({ error: 'No token, authorization denied' });
    }

    try {
        // Verify token
        // The token usually comes as "Bearer <token>"
        const tokenString = token.startsWith('Bearer ') ? token.slice(7, token.length) : token;

        const decoded = jwt.verify(tokenString, process.env.JWT_SECRET || 'secretKey123');

        // Check if user exists in database (Worker or Admin)
        const worker = await prisma.worker.findUnique({
            where: { id: decoded.id }
        });

        if (worker) {
            req.worker = worker;
            req.user = decoded;
            return next();
        }

        const admin = await prisma.admin.findUnique({
            where: { id: decoded.id }
        });

        if (admin) {
            req.admin = admin;
            req.user = decoded;
            return next();
        }

        return res.status(401).json({ error: 'User account no longer exists. Please log in again.' });
    } catch (err) {
        res.status(401).json({ error: 'Token is not valid' });
    }
};

module.exports = authMiddleware;
