# ASHA-Setu — Digital Health Assistant for ASHA Workers

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Node.js](https://img.shields.io/badge/Node.js-18.x-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

ASHA-Setu is a digital companion application built specifically to support and empower ASHA (Accredited Social Health Activist) workers across rural India. ASHA workers are the frontline of India's healthcare system, responsible for tracking pregnancies, infant health, immunizations, and general healthcare delivery to millions of citizens.

This platform solves the long-standing problem of manual, paper-based tracking by providing a comprehensive mobile solution that enables real-time data entry, direct communication with district supervisors, access to critical training resources, and automated patient tracking. By digitizing their workflow, ASHA workers can significantly reduce administrative overhead and focus more on delivering care.

The application features a fully responsive Flutter frontend designed with a robust dark theme, supported by a scalable Node.js and PostgreSQL backend. It utilizes AWS SNS for secure OTP-based authentication, ensuring ease of access even in low-resource environments.

## Features

- 📱 **OTP Authentication**: Secure phone login using AWS SNS for quick field access.
- 📊 **Interactive Dashboard**: Daily statistics, pending tasks, and priority alerts at a glance.
- 👩‍⚕️ **Patient Management**: Complete CRUD operations for ANC, PNC, Infant, and General patients.
- 📝 **Visit Tracking**: Detailed logging of health vitals (BP, weight, temperature, blood sugar).
- 📅 **Calendar**: Monthly view for scheduling and tracking upcoming patient visits.
- 📦 **Inventory Management**: Track and update medical supplies, medicines, and kits.
- 📚 **Learning Modules**: Continuous training through in-app educational videos and articles.
- 💬 **Messaging**: Direct chat interface for communication with district medical officers.
- 🚨 **Emergency Contacts**: Categorized quick-dial numbers for critical situations.
- ❓ **Help & Support**: Built-in FAQs and support contact information.
- 👤 **Worker Profile**: Personal profile management with total visit statistics.
- 🏠 **Household Registration**: Family tracking and demographic grouping.

## Tech Stack

| Component       | Technology                    |
|-----------------|-------------------------------|
| Mobile App      | Flutter 3.x (Dart)            |
| Backend API     | Node.js + Express.js          |
| Database        | PostgreSQL (Supabase)         |
| ORM             | Prisma                        |
| Authentication  | AWS SNS OTP + JWT             |
| Cloud Services  | AWS (SNS), Supabase           |
| Version Control | Git + GitHub                  |

## Project Structure

```text
ASHA-Setuapp/
├── App backend/              # Node.js REST API server
│   ├── src/
│   │   ├── controllers/      # Business logic (auth, patients, visits, etc.)
│   │   ├── routes/           # API endpoint definitions
│   │   └── middleware/       # JWT authentication middleware
│   ├── prisma/
│   │   └── schema.prisma     # Database schema (9 models)
│   ├── index.js              # Server entry point
│   └── package.json          # Node.js dependencies
├── App frontend/             # Flutter mobile application
│   └── lib/
│       ├── screens/          # All 14 app screens
│       ├── services/         # API calls & auth token management
│       ├── theme/            # Dark theme configuration
│       ├── widgets/          # Reusable UI components
│       └── main.dart         # App entry point & routing
├── README.md                 # This file
└── FEATURES.md               # Detailed feature documentation
```

## Getting Started

### Prerequisites
- [Flutter 3.x SDK](https://flutter.dev/docs/get-started/install)
- [Node.js 18+](https://nodejs.org/)
- PostgreSQL database (or Supabase account)

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd "App backend"
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file with the following variables:
   - `DATABASE_URL`
   - `JWT_SECRET`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `PORT`
4. Push the Prisma schema to the database:
   ```bash
   npx prisma db push
   ```
5. Start the server:
   ```bash
   node index.js
   ```

### Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd "App frontend"
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Database Schema

The system uses a relational PostgreSQL database with the following 9 core models:
- **Worker**: Details of the ASHA worker.
- **Patient**: Individual patient records.
- **Household**: Groupings of patients.
- **Task**: To-do items and scheduled follow-ups.
- **VisitHistory**: Logs of patient visits and recorded vitals.
- **InventoryItem**: Medical supplies and quantities.
- **LearningModule**: Educational content available for training.
- **LearningProgress**: Tracking a worker's training completion.
- **Message**: Chat messages between workers and officers.

## API Endpoints

A brief overview of the core REST endpoints:
- `POST /api/auth/login` — Send OTP to phone number
- `POST /api/auth/verify-otp` — Verify OTP & issue JWT token
- `GET/POST /api/patients` — Retrieve or create patient records
- `POST /api/visits` — Log a new patient visit
- `GET/POST/PUT/DELETE /api/inventory` — Manage medical inventory
- `GET/PUT /api/worker/profile` — Fetch or update worker profile details

## Team

| Name    | Role                          |
|---------|-------------------------------|
| Krushna | Lead Developer (80%)          |
| Rudra   | UI/UX Polish (10%)            |
| Raj     | Documentation & Messenger (10%)|

## License

MIT License. This project was developed as an academic project to support community health workers.
