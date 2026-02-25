const { PrismaClient } = require('@prisma/client');
const jwt = require('jsonwebtoken');
const twilio = require('twilio');

const prisma = new PrismaClient();

// In-memory store for OTPs (Mobile -> OTP string).  
// In production, use Redis.
const otpStore = new Map();

// Initialize Twilio client only if credentials exist
let twilioClient = null;
if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_PHONE_NUMBER) {
    twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
}

const sendOtp = async (req, res) => {
    try {
        const { mobileNumber } = req.body;

        if (!mobileNumber) {
            return res.status(400).json({ error: 'Mobile number is required' });
        }

        const worker = await prisma.worker.findUnique({
            where: { mobileNumber }
        });

        if (!worker) {
            return res.status(404).json({ error: 'No ASHA worker registered with this number' });
        }

        // Generate a random 6-digit OTP
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();

        // Store the OTP in memory for verification later
        otpStore.set(mobileNumber, otpCode);

        // Send OTP via Twilio
        if (twilioClient) {
            // Indian numbers need +91 country code format for Twilio
            const formattedNumber = mobileNumber.startsWith('+') ? mobileNumber : `+91${mobileNumber}`;

            await twilioClient.messages.create({
                body: `Your ASHA Portal verification code is: ${otpCode}`,
                from: process.env.TWILIO_PHONE_NUMBER,
                to: formattedNumber
            });
            console.log(`Sent real SMS OTP to ${formattedNumber}. (The code is: ${otpCode})`);
        } else {
            // Fallback for local testing if Twilio isn't set up yet
            console.log(`[Twilio Not configured] Mock SMS: The OTP for ${mobileNumber} is ${otpCode}`);
        }

        res.json({ message: 'OTP sent successfully', mobileNumber });
    } catch (error) {
        console.error("sendOtp error", error);

        // Return clear error if Twilio complains about unverified numbers, etc.
        const errorMsg = error.message || 'Failed to send OTP';
        res.status(500).json({ error: errorMsg });
    }
};

const verifyOtp = async (req, res) => {
    try {
        const { mobileNumber, otp } = req.body;

        if (!mobileNumber || !otp) {
            return res.status(400).json({ error: 'Mobile number and OTP are required' });
        }

        // Check if the OTP matches the one we generated and stored
        const storedOtp = otpStore.get(mobileNumber);

        if (!storedOtp || storedOtp !== otp) {
            return res.status(401).json({ error: 'Invalid or expired OTP' });
        }

        // Clear the OTP so it can't be reused
        otpStore.delete(mobileNumber);

        const worker = await prisma.worker.findUnique({
            where: { mobileNumber },
            include: {
                _count: {
                    select: { patients: true, tasks: true }
                }
            }
        });

        if (!worker) {
            return res.status(404).json({ error: 'Worker not found' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { id: worker.id, employeeId: worker.employeeId, mobileNumber: worker.mobileNumber },
            process.env.JWT_SECRET || 'secretKey123',
            { expiresIn: '8h' }
        );

        res.json({
            message: 'Login successful',
            token,
            worker: {
                id: worker.id,
                name: worker.name,
                employeeId: worker.employeeId,
                village: worker.village,
                stats: {
                    patients: worker._count.patients,
                    tasks: worker._count.tasks,
                    totalVisits: worker.totalVisits
                }
            }
        });

    } catch (error) {
        console.error("verifyOtp error", error);
        res.status(500).json({ error: 'Failed to verify OTP' });
    }
}

module.exports = {
    sendOtp,
    verifyOtp
};
