const { PrismaClient } = require('@prisma/client');
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');

const prisma = new PrismaClient();

const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const snsClient = new SNSClient({
    region: process.env.AWS_REGION || "ap-south-1",
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    },
});

const loginWorker = async (req, res) => {
    try {
        let { mobileNumber } = req.body;
        if (!mobileNumber) {
            return res.status(400).json({ error: 'Mobile number is required' });
        }

        // Ensure it has +91 for SNS but store it without +91 in our DB
        const fullNumber = mobileNumber.startsWith('+91') ? mobileNumber : '+91' + mobileNumber;
        const dbNumber = fullNumber.substring(3);

        const worker = await prisma.worker.findUnique({
            where: { mobileNumber: dbNumber }
        });

        if (!worker) {
            return res.status(403).json({ error: 'Unauthorized: No ASHA worker registered with this number' });
        }

        // Generate OTP
        const otp = Math.floor(100000 + Math.random() * 900000).toString();
        const otpExpiry = new Date(Date.now() + 10 * 60000); // 10 minutes

        await prisma.worker.update({
            where: { id: worker.id },
            data: { otp, otpExpiry }
        });

        // Send OTP via AWS SNS
        console.log(`Sending OTP to ${fullNumber}`);
        const params = {
            Message: `Your ASHA-Setu login OTP is: ${otp}`,
            PhoneNumber: fullNumber
        };
        const snsResponse = await snsClient.send(new PublishCommand(params));
        console.log("SNS Response:", snsResponse);

        res.json({ message: 'OTP sent successfully' });
    } catch (error) {
        console.error("loginWorker error", error);
        res.status(500).json({ error: 'Failed to send OTP' });
    }
};

const verifyOtp = async (req, res) => {
    try {
        let { mobileNumber, otp } = req.body;
        if (!mobileNumber || !otp) {
            return res.status(400).json({ error: 'Mobile number and OTP are required' });
        }

        const dbNumber = mobileNumber.startsWith('+91') ? mobileNumber.substring(3) : mobileNumber;

        const worker = await prisma.worker.findUnique({
            where: { mobileNumber: dbNumber },
            include: {
                _count: {
                    select: { patients: true, tasks: true }
                }
            }
        });

        if (!worker) {
            return res.status(403).json({ error: 'Unauthorized: Worker not found' });
        }

        if (worker.otp !== otp || new Date() > worker.otpExpiry) {
            return res.status(401).json({ error: 'Invalid or expired OTP' });
        }

        // Clear OTP upon successful login
        await prisma.worker.update({
            where: { id: worker.id },
            data: { otp: null, otpExpiry: null }
        });

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
        res.status(500).json({ error: 'Verification failed' });
    }
};

module.exports = { loginWorker, verifyOtp };
