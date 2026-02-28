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

// Initialize Firebase Admin SDK
let serviceAccount;
try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT_BASE64) {
        console.log('Loading Firebase credentials from Base64 environment variable...');
        // Decode the base64 string back to utf8 JSON
        const decodedStr = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, 'base64').toString('utf8');
        serviceAccount = JSON.parse(decodedStr);
    } else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        const rawJson = process.env.FIREBASE_SERVICE_ACCOUNT.trim();
        console.log('Attempting to parse FIREBASE_SERVICE_ACCOUNT (Length:', rawJson.length, ')');

        try {
            // Try 1: Standard parse
            serviceAccount = JSON.parse(rawJson);
        } catch (parseError) {
            try {
                // Try 2: Handle raw newlines (common in multi-line pastes)
                serviceAccount = JSON.parse(rawJson.replace(/\n/g, '\\n'));
            } catch (secondError) {
                // Try 3: Handle escaped backslashes if double-escaped during paste
                serviceAccount = JSON.parse(rawJson.replace(/\\\\n/g, '\\n'));
                console.log('Used fallback parsing for service account');
            }
        }

        // Critical: Restoring real newlines to the private key for the PEM format
        if (serviceAccount && serviceAccount.private_key) {
            serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');
        }
    } else {
        serviceAccount = require('./serviceAccountKey.json');
    }
} catch (error) {
    console.error('Error loading Firebase service account:', error.message);
}

if (serviceAccount) {
    try {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('Firebase Admin SDK initialized successfully');
    } catch (e) {
        console.error('Firebase initialization error:', e.message);
    }
} else {
    console.warn('Firebase Admin SDK not initialized: Missing service account credentials.');
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

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Mobile Backend server running on port ${PORT} (0.0.0.0)`);
});
