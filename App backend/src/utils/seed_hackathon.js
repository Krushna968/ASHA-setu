const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const firstNames = ['Rajesh', 'Sanjay', 'Amit', 'Vikram', 'Anil', 'Sunil', 'Vijay', 'Prakash', 'Deepak', 'Manoj', 'Anita', 'Vidya', 'Sunita', 'Priya', 'Sneha', 'Meena', 'Rani', 'Geeta', 'Lata', 'Nisha'];
const lastNames = ['Sharma', 'Patil', 'Singh', 'Deshmukh', 'Joshi', 'Kulkarni', 'Pawar', 'Yadav', 'Verma', 'Gupta'];
const categories = ['GENERAL', 'ANC', 'PNC', 'INFANT'];
const symptoms = ['Fever', 'Cough', 'Body Ache', 'Headache', 'Vomiting', 'Fatigue'];

async function main() {
    console.log('🚀 Starting Hackathon Seed...');

    // 1. Ensure Demo Worker exists
    const demoMobile = '9321609760';
    let worker = await prisma.worker.findUnique({
        where: { mobileNumber: demoMobile }
    });

    if (!worker) {
        worker = await prisma.worker.create({
            data: {
                mobileNumber: demoMobile,
                name: 'Swar Shinde',
                employeeId: 'ASHA-9321',
                village: 'Airoli',
                gender: 'Female'
            }
        });
        console.log('✅ Created Demo Worker');
    } else {
        console.log('ℹ️ Demo Worker already exists');
    }

    // 2. Clear existing demo data for this worker to avoid duplicates
    // We'll only delete households and patients linked to this worker
    // WARNING: This is destructive for this specific worker's data
    await prisma.visitHistory.deleteMany({ where: { workerId: worker.id } });
    await prisma.task.deleteMany({ where: { workerId: worker.id } });
    await prisma.patient.deleteMany({ where: { workerId: worker.id } });
    await prisma.household.deleteMany({ where: { workerId: worker.id } });

    console.log('🧹 Cleaned previous demo data');

    // 3. Generate Households H-12 to H-40 with varied statuses
    const statusDistribution = [
        'pending', 'pending', 'completed', 'high-risk', 'pending',
        'completed', 'closed', 'pending', 'high-risk', 'completed',
        'pending', 'completed', 'high-risk', 'closed', 'pending',
        'completed', 'pending', 'high-risk', 'closed', 'completed',
        'pending', 'completed', 'high-risk', 'closed', 'pending',
        'completed', 'pending', 'high-risk', 'closed'
    ];
    const taskTypes = ['BP Check', 'Vaccination', 'ANC Visit', 'PNC Visit', 'IFA Supplement', 'Weight Check', 'Health Education'];

    for (let i = 12; i <= 40; i++) {
        const houseNum = `H-${i}`;
        const familyLastName = lastNames[Math.floor(Math.random() * lastNames.length)];
        const headFirstName = firstNames[Math.floor(Math.random() * (firstNames.length / 2))]; // Male names for head
        const headName = `${headFirstName} ${familyLastName}`;
        const houseStatus = statusDistribution[i - 12];
        const isClosed = houseStatus === 'closed';

        const household = await prisma.household.create({
            data: {
                houseNumber: houseNum,
                headName: headName,
                address: `${houseNum}, Main Road, Airoli`,
                village: 'Airoli',
                status: houseStatus,
                isClosed: isClosed,
                workerId: worker.id
            }
        });

        // 4. Create Family Members (2-4)
        const memberCount = Math.floor(Math.random() * 3) + 2;
        for (let j = 0; j < memberCount; j++) {
            const isHead = j === 0;
            const fName = isHead ? headFirstName : firstNames[Math.floor(Math.random() * firstNames.length)];
            const age = isHead ? (Math.floor(Math.random() * 20) + 35) : Math.floor(Math.random() * 70);
            const category = age < 5 ? 'INFANT' : (Math.random() > 0.8 ? categories[Math.floor(Math.random() * 2) + 1] : 'GENERAL');

            const patient = await prisma.patient.create({
                data: {
                    name: `${fName} ${familyLastName}`,
                    age: age,
                    gender: (j === 1 || (j > 1 && Math.random() > 0.5)) ? 'Female' : 'Male',
                    category: category,
                    relation: isHead ? 'Head' : (j === 1 ? 'Spouse' : 'Child'),
                    workerId: worker.id,
                    householdId: household.id
                }
            });

            // 5. Add visits for completed houses
            if (houseStatus === 'completed' || Math.random() > 0.6) {
                await prisma.visitHistory.create({
                    data: {
                        workerId: worker.id,
                        patientId: patient.id,
                        outcome: 'Follow-up suggested',
                        visitType: 'Routine Checkup',
                        symptoms: symptoms[Math.floor(Math.random() * symptoms.length)],
                        notes: 'Family doing well.'
                    }
                });
            }
        }

        // 6. Create tasks for pending & high-risk houses
        if (houseStatus === 'pending' || houseStatus === 'high-risk') {
            const taskCount = houseStatus === 'high-risk' ? Math.floor(Math.random() * 2) + 2 : Math.floor(Math.random() * 2) + 1;
            for (let t = 0; t < taskCount; t++) {
                const dueDate = new Date();
                dueDate.setDate(dueDate.getDate() + Math.floor(Math.random() * 7));
                await prisma.task.create({
                    data: {
                        title: taskTypes[Math.floor(Math.random() * taskTypes.length)],
                        description: `Task for ${headName} at ${houseNum}`,
                        status: 'PENDING',
                        priority: houseStatus === 'high-risk' ? 'HIGH' : 'MEDIUM',
                        dueDate: dueDate,
                        workerId: worker.id,
                        householdId: household.id
                    }
                });
            }

            // Update pending tasks count
            await prisma.household.update({
                where: { id: household.id },
                data: { pendingTasksCount: taskCount }
            });
        }

        process.stdout.write(`.`);
    }

    console.log('\n✨ Seed complete! 29 Households and families created.');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
