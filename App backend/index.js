const express = require('express');
const admin = require('firebase-admin');
// NOTE: On Render, set FIREBASE_SERVICE_ACCOUNT as an environment variable (JSON string)
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

// Load environment variables
dotenv.config();

// Initialize Firebase Admin SDK (Optional)
let serviceAccount;
try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
        const decodedStr = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
        serviceAccount = JSON.parse(decodedStr);
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        const rawJson = process.env.FIREBASE_SERVICE_ACCOUNT.trim();
        try {
            serviceAccount = JSON.parse(rawJson);
        } catch (e) {
            // Silently try fallback for common env var escaping issues
            try {
                serviceAccount = JSON.parse(rawJson.replace(/\n/g, '\\n'));
            } catch (e2) {
                // Not valid JSON or Base64 in wrong slot
            }
        }
    }

    if (serviceAccount) {
        // Restore PEM format for private key
        if (serviceAccount.private_key) {
            serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
        }
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('✅ Firebase Admin SDK initialized');
    } else {
        console.log('⚠️ Firebase initialized skipped (Missing/Invalid credentials)');
    }
} catch (error) {
    console.warn('⚠️ Firebase initialization skipped:', error.message);
}

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
// Serve uploaded profile pictures statically
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Import Routes
const authRoutes = require('./src/routes/authRoutes');
const patientRoutes = require('./src/routes/patientRoutes');
const taskRoutes = require('./src/routes/taskRoutes');
const visitRoutes = require('./src/routes/visitRoutes');
const workerRoutes = require('./src/routes/workerRoutes');
const inventoryRoutes = require('./src/routes/inventoryRoutes');

// Mount Routes
app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/visits', visitRoutes);
app.use('/api/worker', workerRoutes);
app.use('/api/inventory', inventoryRoutes);

// Basic health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'ASHA-Setu Mobile Backend is running' });
});

// Database connectivity check
app.get('/api/db-check', async (req, res) => {
    try {
        const { PrismaClient } = require('@prisma/client');
        const prisma = new PrismaClient();
        const count = await prisma.worker.count();
        await prisma.$disconnect();
        res.json({ status: 'ok', workerCount: count });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Mobile Backend server running on port ${PORT} (0.0.0.0)`);
});
