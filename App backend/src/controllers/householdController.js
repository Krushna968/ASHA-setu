const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Create a new household
const createHousehold = async (req, res) => {
    try {
        const { houseNumber, headName, address, village } = req.body;
        const workerId = req.user.id;

        if (!houseNumber || !headName || !address) {
            return res.status(400).json({ error: 'House number, head name, and address are required' });
        }

        // Check for duplicate house number for this worker
        const existing = await prisma.household.findFirst({
            where: { workerId, houseNumber: houseNumber.toUpperCase() }
        });
        if (existing) {
            return res.status(409).json({ error: `House ${houseNumber} already exists` });
        }

        const household = await prisma.household.create({
            data: {
                houseNumber: houseNumber.toUpperCase(),
                headName,
                address,
                village: village || null,
                workerId,
                status: 'pending',
                pendingTasksCount: 0,
                isClosed: false,
            }
        });

        res.status(201).json({ message: 'Household created', household });
    } catch (error) {
        console.error("createHousehold error", error);
        res.status(500).json({ error: 'Failed to create household' });
    }
};

// Get all households for the logged-in worker (Map View)
const getWorkerHouseholds = async (req, res) => {
    try {
        const workerId = req.user.id;

        const households = await prisma.household.findMany({
            where: { workerId },
            include: {
                familyMembers: {
                    select: { id: true, name: true, age: true, category: true, relation: true }
                },
                _count: {
                    select: { familyMembers: true }
                }
            },
            orderBy: { houseNumber: 'asc' }
        });

        // Recalculate pending tasks count from Task table for accuracy
        const enriched = [];
        for (const h of households) {
            const pendingTasks = await prisma.task.count({
                where: {
                    householdId: h.id,
                    status: { not: 'COMPLETED' }
                }
            });

            // Auto-calculate status
            let status = h.status;
            if (h.isClosed) {
                status = 'closed';
            } else if (pendingTasks === 0 && h.familyMembers.length > 0) {
                // Check if there are any high-risk patients
                const hasHighRisk = h.familyMembers.some(m => m.category === 'ANC' || m.category === 'PNC');
                if (hasHighRisk && pendingTasks > 0) {
                    status = 'high-risk';
                } else {
                    status = 'completed';
                }
            } else if (pendingTasks > 0) {
                // Check for high-risk categories
                const hasHighRisk = h.familyMembers.some(m => m.category === 'ANC' || m.category === 'PNC');
                status = hasHighRisk ? 'high-risk' : 'pending';
            }

            // Update DB if status changed
            if (status !== h.status || pendingTasks !== h.pendingTasksCount) {
                await prisma.household.update({
                    where: { id: h.id },
                    data: { status, pendingTasksCount: pendingTasks }
                });
            }

            enriched.push({
                householdId: h.id,
                displayId: h.houseNumber,
                headName: h.headName,
                address: h.address,
                village: h.village,
                status: status,
                pendingTasksCount: pendingTasks,
                isClosed: h.isClosed,
                memberCount: h._count.familyMembers,
                badges: _getBadges(h.familyMembers),
            });
        }

        res.json({ households: enriched });
    } catch (error) {
        console.error("getWorkerHouseholds error", error);
        res.status(500).json({ error: 'Failed to fetch households' });
    }
};

// Helper: generate badge tags from member categories
function _getBadges(members) {
    const badges = [];
    if (members.some(m => m.category === 'ANC')) badges.push('antenatal');
    if (members.some(m => m.category === 'PNC')) badges.push('postnatal');
    if (members.some(m => m.category === 'Infants')) badges.push('vaccination');
    return badges;
}

// Get detail for a specific household
const getHouseholdDetail = async (req, res) => {
    try {
        const { id } = req.params;
        const workerId = req.user.id;

        const household = await prisma.household.findFirst({
            where: { id, workerId },
            include: {
                familyMembers: {
                    include: {
                        visitHistory: {
                            orderBy: { visitDate: 'desc' },
                            take: 3
                        }
                    }
                }
            }
        });

        if (!household) {
            return res.status(404).json({ error: 'Household not found' });
        }

        // Get pending tasks for this household
        const pendingTasks = await prisma.task.findMany({
            where: {
                householdId: household.id,
                status: { not: 'COMPLETED' }
            },
            orderBy: { dueDate: 'asc' }
        });

        // Fetch latest visits across all members
        const memberIds = household.familyMembers.map(m => m.id);
        const latestVisits = await prisma.visitHistory.findMany({
            where: { patientId: { in: memberIds } },
            orderBy: { visitDate: 'desc' },
            take: 10,
            include: {
                patient: { select: { name: true } }
            }
        });

        res.json({
            householdId: household.id,
            houseNumber: household.houseNumber,
            headName: household.headName,
            address: household.address,
            status: household.status,
            isClosed: household.isClosed,
            members: household.familyMembers.map(m => ({
                id: m.id,
                name: m.name,
                age: m.age,
                relation: m.relation || 'Member',
                category: m.category,
            })),
            latestVisits: latestVisits.map(v => ({
                type: v.visitType || v.outcome,
                date: v.visitDate.toISOString().split('T')[0],
                status: 'done',
                patientName: v.patient?.name,
                symptoms: v.symptoms,
            })),
            pendingTasks: pendingTasks.map(t => ({
                taskId: t.id,
                type: t.title,
                dueDate: t.dueDate.toISOString().split('T')[0],
                notes: t.description || '',
                priority: t.priority,
            })),
            notes: '',
        });
    } catch (error) {
        console.error("getHouseholdDetail error", error);
        res.status(500).json({ error: 'Failed to fetch household details' });
    }
};

// Close a household
const closeHousehold = async (req, res) => {
    try {
        const { id } = req.params;
        const workerId = req.user.id;

        const household = await prisma.household.findFirst({ where: { id, workerId } });
        if (!household) {
            return res.status(404).json({ error: 'Household not found' });
        }

        const updated = await prisma.household.update({
            where: { id },
            data: { isClosed: true, status: 'closed' }
        });

        res.json({ message: 'Household closed', household: updated });
    } catch (error) {
        console.error("closeHousehold error", error);
        res.status(500).json({ error: 'Failed to close household' });
    }
};

// Update household status (recalculate)
const updateHouseholdStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        const workerId = req.user.id;

        const household = await prisma.household.findFirst({ where: { id, workerId } });
        if (!household) {
            return res.status(404).json({ error: 'Household not found' });
        }

        const updated = await prisma.household.update({
            where: { id },
            data: { status: status || household.status }
        });

        res.json({ message: 'Status updated', household: updated });
    } catch (error) {
        console.error("updateHouseholdStatus error", error);
        res.status(500).json({ error: 'Failed to update status' });
    }
};

module.exports = { createHousehold, getWorkerHouseholds, getHouseholdDetail, closeHousehold, updateHouseholdStatus };
