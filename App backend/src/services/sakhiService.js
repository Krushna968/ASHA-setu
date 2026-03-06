const Groq = require('groq-sdk');
const prisma = require('../lib/prisma');
const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// ─── Tool Definitions (what the AI can "call") ───────────────────────
const TOOL_DEFINITIONS = [
    {
        type: 'function',
        function: {
            name: 'get_district_overview',
            description: 'Get overall district statistics: total workers, patients, households, visits, tasks, and high-risk count.',
            parameters: { type: 'object', properties: {}, required: [] }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_worker_stats',
            description: 'Get statistics for a specific ASHA worker by their ID: patient count, task count, visit count, household count.',
            parameters: {
                type: 'object',
                properties: {
                    workerId: { type: 'string', description: 'The worker ID to look up.' }
                },
                required: ['workerId']
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_high_risk_patients',
            description: 'Get list of high-risk patients (ANC/PNC category) with their expected delivery dates and assigned worker.',
            parameters: {
                type: 'object',
                properties: {
                    limit: { type: 'number', description: 'Max number of results. Default 10.' }
                },
                required: []
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_task_summary',
            description: 'Get task summary: counts of pending, in-progress, and completed tasks. Optionally filter by a specific worker ID.',
            parameters: {
                type: 'object',
                properties: {
                    workerId: { type: 'string', description: 'Optional worker ID to filter tasks.' }
                },
                required: []
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_recent_visits',
            description: 'Get the most recent patient visits with details like patient name, visit type, outcome, and date. Optionally filter by worker ID.',
            parameters: {
                type: 'object',
                properties: {
                    workerId: { type: 'string', description: 'Optional worker ID to filter visits.' },
                    limit: { type: 'number', description: 'Max results to return. Default 5.' }
                },
                required: []
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_inventory_status',
            description: 'Get the current inventory status across all workers or for a specific worker. Shows item name, quantity, and unit.',
            parameters: {
                type: 'object',
                properties: {
                    workerId: { type: 'string', description: 'Optional worker ID to filter inventory.' }
                },
                required: []
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'search_patients',
            description: 'Search for patients by name or category (ANC, PNC, INFANT, GENERAL). Returns patient details including household, worker, and EDD.',
            parameters: {
                type: 'object',
                properties: {
                    query: { type: 'string', description: 'Name or category to search for.' },
                    limit: { type: 'number', description: 'Max results. Default 10.' }
                },
                required: ['query']
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_household_info',
            description: 'Get household details including family members and their health status. Search by house number or village name.',
            parameters: {
                type: 'object',
                properties: {
                    query: { type: 'string', description: 'House number (e.g. H001) or village name to search.' }
                },
                required: ['query']
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'send_to_supervisor',
            description: 'Send a message, report, or data to the Admin/Supervisor dashboard.',
            parameters: {
                type: 'object',
                properties: {
                    content: { type: 'string', description: 'The detailed message or data summary to send to the admin.' },
                    workerId: { type: 'string', description: 'The ID of the ASHA worker sending the message.' },
                    reportId: { type: 'string', description: 'Optional ID of a specific report to link (e.g. for forwarding a daily/monthly report).' }
                },
                required: ['content', 'workerId']
            }
        }
    },
    {
        type: 'function',
        function: {
            name: 'get_worker_reports',
            description: 'Get a list of reports submitted by a worker. Useful for finding a report ID to forward to a supervisor.',
            parameters: {
                type: 'object',
                properties: {
                    workerId: { type: 'string', description: 'The ID of the ASHA worker.' },
                    limit: { type: 'number', description: 'Max number of reports to return. Default 5.' }
                },
                required: ['workerId']
            }
        }
    }
];

// ─── Tool Implementations (actual DB queries) ────────────────────────
async function executeToolCall(functionName, args) {
    try {
        switch (functionName) {
            case 'get_district_overview': {
                const [workers, patients, households, visits, tasks, highRisk] = await Promise.all([
                    prisma.worker.count(),
                    prisma.patient.count(),
                    prisma.household.count(),
                    prisma.visitHistory.count(),
                    prisma.task.count(),
                    prisma.patient.count({ where: { category: { in: ['ANC', 'PNC'] } } })
                ]);
                return { workers, patients, households, visits, tasks, highRiskPatients: highRisk };
            }

            case 'get_worker_stats': {
                const worker = await prisma.worker.findUnique({
                    where: { id: args.workerId },
                    include: {
                        _count: { select: { patients: true, tasks: true, visitHistory: true, households: true } }
                    }
                });
                if (!worker) return { error: 'Worker not found' };
                return {
                    name: worker.name,
                    village: worker.village,
                    employeeId: worker.employeeId,
                    patients: worker._count.patients,
                    tasks: worker._count.tasks,
                    visits: worker._count.visitHistory,
                    households: worker._count.households
                };
            }

            case 'get_high_risk_patients': {
                const limit = args.limit || 10;
                const patients = await prisma.patient.findMany({
                    where: { category: { in: ['ANC', 'PNC'] } },
                    include: { worker: { select: { name: true, village: true } }, household: { select: { houseNumber: true } } },
                    take: limit,
                    orderBy: { pregnancyEDD: 'asc' }
                });
                return patients.map(p => ({
                    name: p.name,
                    category: p.category,
                    edd: p.pregnancyEDD ? new Date(p.pregnancyEDD).toLocaleDateString() : 'Not set',
                    age: p.age,
                    worker: p.worker.name,
                    village: p.worker.village,
                    household: p.household?.houseNumber || 'N/A'
                }));
            }

            case 'get_task_summary': {
                const where = args.workerId ? { workerId: args.workerId } : {};
                const [pending, inProgress, completed] = await Promise.all([
                    prisma.task.count({ where: { ...where, status: 'PENDING' } }),
                    prisma.task.count({ where: { ...where, status: 'IN_PROGRESS' } }),
                    prisma.task.count({ where: { ...where, status: 'COMPLETED' } })
                ]);
                return { pending, inProgress, completed, total: pending + inProgress + completed };
            }

            case 'get_recent_visits': {
                const limit = args.limit || 5;
                const where = args.workerId ? { workerId: args.workerId } : {};
                const visits = await prisma.visitHistory.findMany({
                    where,
                    include: {
                        patient: { select: { name: true, category: true } },
                        worker: { select: { name: true } }
                    },
                    orderBy: { visitDate: 'desc' },
                    take: limit
                });
                return visits.map(v => ({
                    patient: v.patient.name,
                    category: v.patient.category,
                    visitType: v.visitType || 'General',
                    outcome: v.outcome,
                    date: new Date(v.visitDate).toLocaleDateString(),
                    worker: v.worker.name,
                    bp: v.bloodPressure,
                    weight: v.weight,
                    notes: v.notes
                }));
            }

            case 'get_inventory_status': {
                const where = args.workerId ? { workerId: args.workerId } : {};
                const items = await prisma.inventoryItem.findMany({
                    where,
                    include: { worker: { select: { name: true, village: true } } }
                });
                return items.map(i => ({
                    item: i.name,
                    quantity: i.quantity,
                    unit: i.unit,
                    worker: i.worker.name,
                    village: i.worker.village
                }));
            }

            case 'search_patients': {
                const { query, limit = 10 } = args;
                const categorySearch = ['ANC', 'PNC', 'INFANT', 'GENERAL'].includes(query.toUpperCase());
                const patients = await prisma.patient.findMany({
                    where: categorySearch
                        ? { category: query.toUpperCase() }
                        : { name: { contains: query, mode: 'insensitive' } },
                    include: {
                        worker: { select: { name: true, village: true } },
                        household: { select: { houseNumber: true, address: true } }
                    },
                    take: limit
                });
                return patients.map(p => ({
                    name: p.name,
                    age: p.age,
                    category: p.category,
                    edd: p.pregnancyEDD ? new Date(p.pregnancyEDD).toLocaleDateString() : null,
                    worker: p.worker.name,
                    village: p.worker.village,
                    household: p.household?.houseNumber || 'N/A'
                }));
            }

            case 'get_household_info': {
                const { query } = args;
                const households = await prisma.household.findMany({
                    where: {
                        OR: [
                            { houseNumber: { contains: query, mode: 'insensitive' } },
                            { village: { contains: query, mode: 'insensitive' } },
                            { address: { contains: query, mode: 'insensitive' } }
                        ]
                    },
                    include: {
                        familyMembers: { select: { name: true, age: true, category: true, pregnancyEDD: true } },
                        worker: { select: { name: true } }
                    },
                    take: 5
                });
                return households.map(h => ({
                    houseNumber: h.houseNumber,
                    head: h.headName,
                    address: h.address,
                    status: h.status,
                    worker: h.worker.name,
                    members: h.familyMembers.map(m => ({
                        name: m.name, age: m.age, category: m.category,
                        edd: m.pregnancyEDD ? new Date(m.pregnancyEDD).toLocaleDateString() : null
                    }))
                }));
            }

            case 'send_to_supervisor': {
                const { content, workerId } = args;
                if (!workerId || !content) return { error: 'Missing workerId or content' };

                try {
                    // Using receiverId 'ADMIN' for the global admin dashboard
                    await prisma.message.create({
                        data: {
                            content: content.startsWith('[SakhiAI') ? content : `[SakhiAI Automated Forward]\n${content}`,
                            senderId: workerId,
                            receiverId: 'ADMIN',
                            senderType: 'WORKER',
                            receiverType: 'ADMIN',
                            reportId: args.reportId || null
                        }
                    });
                    return { success: true, message: 'Data successfully sent to the supervisor dashboard.' };
                } catch (e) {
                    console.error('Failed to save message:', e);
                    return { error: 'Failed to send message to supervisor.' };
                }
            }

            case 'get_worker_reports': {
                const { workerId, limit = 5 } = args;
                const reports = await prisma.report.findMany({
                    where: { workerId },
                    orderBy: { date: 'desc' },
                    take: limit
                });
                return reports.map(r => ({
                    id: r.id,
                    date: new Date(r.date).toLocaleDateString(),
                    summary: r.content.summary || 'Daily Report',
                    patientCount: r.content.stats?.patientsVisited || 0
                }));
            }
        }
    } catch (err) {
        console.error(`Tool ${functionName} error:`, err.message);
        return { error: `Failed to execute ${functionName}: ${err.message}` };
    }
}

// ─── System Prompt ───────────────────────────────────────────────────
function buildSystemPrompt(role, workerName, workerVillage, workerId) {
    const base = `You are SakhiAI (सखी AI), a friendly, knowledgeable healthcare assistant for the ASHA-Setu platform.
You help ASHA (Accredited Social Health Activist) workers and district health administrators in India.

Your personality:
- Warm, supportive, and encouraging — like a knowledgeable friend
- You use simple language, avoiding medical jargon when possible
- You can respond in Hindi or English depending on what the user writes in
- You use emojis sparingly but effectively 🩺
- Keep responses concise but thorough

You have access to LIVE DATABASE tools that let you look up real patient data, task summaries, visit histories, inventory levels, and more. ALWAYS use these tools when asked about data — never guess or make up numbers.

When presenting data, format it nicely with bullet points or numbered lists. If the data is large, summarize the key insights first.`;

    if (role === 'worker') {
        return `${base}

CURRENT USER CONTEXT:
- Role: ASHA Worker (field health worker)
- Name: ${workerName}
- Village/Area: ${workerVillage}
- Worker ID: ${workerId}

When the worker asks about "my patients", "my tasks", "my visits", etc., use their worker ID (${workerId}) to filter data.
If the worker asks you to "send this to my supervisor" or "report this data", use the send_to_supervisor tool.

Help them with daily fieldwork: patient care, task management, health education, and reporting.`;
    } else {
        return `${base}

CURRENT USER CONTEXT:
- Role: District Health Administrator
- Access Level: Full district-wide data access

This user can see ALL workers, patients, and tasks across the entire district.
Help them with performance monitoring, trend analysis, resource allocation, and high-risk case oversight.`;
    }
}

// ─── Main Chat Function ──────────────────────────────────────────────
async function chat(message, conversationHistory = [], role = 'worker', workerName = 'ASHA Worker', workerVillage = '', workerId = '') {
    const systemPrompt = buildSystemPrompt(role, workerName, workerVillage, workerId);

    const messages = [
        { role: 'system', content: systemPrompt },
        ...conversationHistory,
        { role: 'user', content: message }
    ];

    try {
        // First call — may include tool calls
        let response = await groq.chat.completions.create({
            model: 'llama-3.3-70b-versatile',
            messages,
            tools: TOOL_DEFINITIONS,
            tool_choice: 'auto',
            max_tokens: 2048,
            temperature: 0.6
        });

        let assistantMessage = response.choices[0].message;

        // Handle tool calls (iterative — the AI might chain multiple tools)
        let iterations = 0;
        while (assistantMessage.tool_calls && assistantMessage.tool_calls.length > 0 && iterations < 5) {
            iterations++;
            messages.push(assistantMessage);

            // Execute each tool call
            for (const toolCall of assistantMessage.tool_calls) {
                const funcName = toolCall.function.name;
                let funcArgs = {};

                try {
                    funcArgs = JSON.parse(toolCall.function.arguments || '{}');
                } catch (parseErr) {
                    console.error(`❌ tool_call_id: ${toolCall.id} - Invalid JSON arguments:`, toolCall.function.arguments);
                    funcArgs = { error: 'Invalid JSON arguments provided by model' };
                }

                console.log(`🔧 SakhiAI calling tool: ${funcName}(${JSON.stringify(funcArgs)})`);
                const result = await executeToolCall(funcName, funcArgs);

                messages.push({
                    role: 'tool',
                    tool_call_id: toolCall.id,
                    content: typeof result === 'string' ? result : JSON.stringify(result)
                });
            }

            // Second (or further) call with tool results
            response = await groq.chat.completions.create({
                model: 'llama-3.3-70b-versatile',
                messages,
                tools: TOOL_DEFINITIONS,
                tool_choice: 'auto',
                max_tokens: 2048,
                temperature: 0.6
            });

            assistantMessage = response.choices[0].message;
        }

        return {
            reply: assistantMessage.content || 'I wasn\'t able to generate a response. Please try again.',
            toolsUsed: iterations > 0
        };
    } catch (err) {
        console.error('SakhiAI Error:', err.message);
        if (err.message.includes('rate_limit')) {
            return { reply: 'I\'m receiving too many requests right now. Please try again in a moment. 🙏', toolsUsed: false };
        }
        return { reply: `I encountered an error: ${err.message}. Please try again.`, toolsUsed: false };
    }
}

module.exports = { chat };
