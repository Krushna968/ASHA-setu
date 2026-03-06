const Groq = require('groq-sdk');
const prisma = require('../lib/prisma');

async function calculatePatientRisk(patientId) {
    if (!process.env.GROQ_API_KEY) {
        throw new Error('GROQ_API_KEY is not set');
    }
    const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

    // Fetch patient data and recent visits
    const patient = await prisma.patient.findUnique({
        where: { id: patientId },
        include: {
            visitHistory: {
                orderBy: { visitDate: 'desc' },
                take: 3
            }
        }
    });

    if (!patient) throw new Error('Patient not found');

    const prompt = `You are an expert AI clinical assistant for the ASHA (Accredited Social Health Activist) program in India.
Your job is to analyze the following patient data and assign a strict "Risk Score" from 1 to 10.
1 = Very Low Risk, 10 = Extremely High Risk (Needs immediate attention).

Consider:
- Category (ANC/PNC are higher baseline risk than GENERAL).
- Age and Pregnancy EDD (Estimated Date of Delivery). Closer to EDD = higher risk.
- Recent Visit History (high blood pressure, high weight gain, bad symptoms = higher risk).

Patient Data:
${JSON.stringify({
        name: patient.name,
        age: patient.age,
        category: patient.category,
        edd: patient.pregnancyEDD,
        recentVisits: patient.visitHistory.map(v => ({
            date: v.visitDate,
            outcome: v.outcome,
            symptoms: v.symptoms,
            bp: v.bloodPressure,
            weight: v.weight,
            notes: v.notes
        }))
    }, null, 2)}

You must return ONLY a JSON object. No markdown formatting, no conversational text.
Format exactly like this:
{
  "score": <int 1-10>,
  "reason": "<one short sentence explaining why>"
}`;

    const response = await groq.chat.completions.create({
        model: 'llama-3.3-70b-versatile',
        messages: [{ role: 'user', content: prompt }],
        response_format: { type: 'json_object' },
        temperature: 0.2
    });

    try {
        const result = JSON.parse(response.choices[0].message.content);

        // Update database
        await prisma.patient.update({
            where: { id: patientId },
            data: { aiRiskScore: result.score }
        });

        return result;
    } catch (e) {
        console.error("Failed to parse AI risk score", e);
        throw e;
    }
}

async function generateDailyItinerary(workerId) {
    if (!process.env.GROQ_API_KEY) {
        throw new Error('GROQ_API_KEY is not set');
    }
    const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

    // 1. Get today's explicit tasks
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const pendingTasks = await prisma.task.findMany({
        where: {
            workerId,
            status: 'PENDING',
            dueDate: { lte: tomorrow } // due today or overdue
        }
    });

    // 2. Get high-risk patients who haven't been visited recently
    const patients = await prisma.patient.findMany({
        where: { workerId },
        select: {
            id: true, name: true, category: true, aiRiskScore: true, pregnancyEDD: true,
            household: { select: { houseNumber: true, address: true } }
        }
    });

    // Filter patients to those needing attention (e.g. score >= 7)
    const highRiskPatients = patients.filter(p => p.aiRiskScore >= 7);

    // 3. Get yesterday's failed visits (locked houses)
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    const lockedVisits = await prisma.visitHistory.findMany({
        where: {
            workerId,
            isHouseClosed: true,
            visitDate: { gte: yesterday, lt: tomorrow }
        },
        include: { patient: { select: { name: true, aiRiskScore: true } } }
    });

    try {
        const itinerary = [];

        // Priority 1: High Risk Locked Houses (score >= 7)
        lockedVisits.forEach(v => {
            if (v.patient.aiRiskScore >= 7) {
                itinerary.push({
                    type: "FOLLOW_UP_LOCKED",
                    referenceId: v.patientId,
                    displayName: v.patient.name,
                    reasoning: "High-risk patient missed yesterday (House Locked)."
                });
            }
        });

        // Priority 2: Extremely High Risk Patients (9-10)
        highRiskPatients.forEach(p => {
            // Avoid duplicates if they were in locked house
            if (p.aiRiskScore >= 9 && !itinerary.find(i => i.referenceId === p.id)) {
                itinerary.push({
                    type: "PATIENT_VISIT",
                    referenceId: p.id,
                    displayName: p.name,
                    reasoning: `Critical risk score (${p.aiRiskScore}/10). Immediate check-in required.`
                });
            }
        });

        // Priority 3: Pending Tasks
        pendingTasks.forEach(t => {
            if (!itinerary.find(i => i.referenceId === t.id)) {
                itinerary.push({
                    type: "TASK",
                    referenceId: t.id,
                    displayName: t.title,
                    reasoning: "Pending or overdue task scheduled for today."
                });
            }
        });

        // Priority 4: Other High Risk Patients (7-8)
        highRiskPatients.forEach(p => {
            if (p.aiRiskScore >= 7 && p.aiRiskScore < 9 && !itinerary.find(i => i.referenceId === p.id)) {
                itinerary.push({
                    type: "PATIENT_VISIT",
                    referenceId: p.id,
                    displayName: p.name,
                    reasoning: `High risk patient (Score: ${p.aiRiskScore}/10). Needs attention.`
                });
            }
        });

        // Save to Database
        await prisma.aiDailyPlan.create({
            data: {
                workerId,
                priorityQueue: itinerary,
                reasoning: "Generated instantly by optimized backend rules"
            }
        });

        return itinerary;
    } catch (e) {
        console.error("Failed to generate AI daily itinerary", e);
        throw e;
    }
}

module.exports = { calculatePatientRisk, generateDailyItinerary };
