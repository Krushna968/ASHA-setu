<p align="center">
  <img src="web/favicon.png" alt="SwasthyaSetu Logo" width="130"/>
</p>

<h1 align="center">SwasthyaSetu — मेरी आशा</h1>

<p align="center">
  <b>An ASHA Worker Digital Portal built with Flutter</b><br/>
  Empowering frontline health workers across rural India
</p>

<p align="center">
  <a href="https://github.com/Krushna968/SwasthyaSetu/releases/download/v1.0.0/SwasthyaSetu.apk">
    <img src="https://img.shields.io/badge/Download%20APK-SwasthyaSetu%20v1.0.0-blue?style=for-the-badge&logo=android" alt="Download APK"/>
  </a>
   
  <img src="https://img.shields.io/badge/Flutter-3.41.2-02569B?style=for-the-badge&logo=flutter"/>
   
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart"/>
   
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-green?style=for-the-badge"/>
</p>

---

## About the Project

**SwasthyaSetu** (स्वास्थ्य सेतु — "Health Bridge") is a comprehensive mobile application built for **ASHA (Accredited Social Health Activist) workers** in India. ASHA workers are the backbone of India's primary healthcare system, serving as the first point of contact for communities in rural and semi-urban areas.

This app digitalizes the entire ASHA workflow — household visits, patient tracking, medicine inventory, emergency response — replacing paper-based processes with a fast, offline-capable, multilingual digital portal.

---

## Download

| Platform | Link |
|----------|------|
| Android APK | [SwasthyaSetu v1.0.0](https://github.com/Krushna968/SwasthyaSetu/releases/download/v1.0.0/SwasthyaSetu.apk) |

---

## Features

| Feature | Description |
|---------|-------------|
| Language Selection | Choose Hindi, English, Marathi, Tamil, Telugu on login |
| Smart Dashboard | Priority visit cards, alerts, quick actions, daily stats |
| Household Visit Form | Multi-step form with member details and health checklist |
| Messenger | Team communication with read receipts and priority labels |
| Calendar | Follow-up tracker with color-coded appointment types |
| Emergency SOS | One-tap SOS with GPS location, nearby hospital finder |
| Inventory Status | Medicine stock levels, refill requests, emergency refill |
| Learning Materials | Categorized health content with progress tracking |
| Worker Profile | Personal info, area of coverage, sync status, settings |
| Help and Support | FAQ accordion, call supervisor, emergency helpline, live chat |

---

## Project Structure

```
SwasthyaSetu/
├── lib/
│   ├── main.dart                    # App entry, MaterialApp, named routes
│   ├── theme/
│   │   └── app_theme.dart           # MyTheme — colors, text styles, ThemeData
│   └── screens/
│       ├── login_screen.dart        # Language picker + login
│       ├── dashboard_screen.dart    # Home with stats and quick actions
│       ├── visit_form_screen.dart   # Multi-step Stepper form (3 steps)
│       ├── messenger_screen.dart    # Chat / messaging UI
│       ├── calendar_screen.dart     # Follow-up calendar
│       ├── emergency_screen.dart    # SOS screen with map and contacts
│       ├── inventory_screen.dart    # Medicine stock with refill actions
│       ├── learning_screen.dart     # Learning materials with tab filter
│       ├── profile_screen.dart      # Worker profile and account settings
│       └── help_support_screen.dart # Help centre with FAQ and contact
├── assets/
│   └── icons/app_icon.png           # Meri Asha app launcher icon
├── android/
│   └── app/
│       ├── build.gradle.kts         # R8 minification + ProGuard enabled
│       └── proguard-rules.pro       # Flutter-safe ProGuard rules
└── pubspec.yaml                     # Dependencies + launcher icons config
```

### Architecture & Design Decisions

- **Stateless + Stateful widgets** — screens use `StatefulWidget` only when local UI state (forms, tabs, accordions) is needed
- **Named Route Navigation** — all transitions go through `MaterialApp.routes`, centralised in `main.dart`
- **Centralised Theme** — `MyTheme` in `app_theme.dart` provides all colours and `ThemeData`, no hardcoded colours in screens
- **Component-first layout** — each screen composes small private builder methods (`_buildCard`, `_buildQuickAction`, etc.) for clarity

---

## Navigation Map

```
/ (LoginScreen)
│
└──> /dashboard (DashboardScreen)
       ├──> /visit-form   (VisitFormScreen)       — Add New Household
       ├──> /inventory    (InventoryScreen)        — Inventory Status
       ├──> /learning     (LearningScreen)         — Learning Materials
       ├──> /help         (HelpSupportScreen)      — Help & Support / bell icon
       ├──> /messenger    (MessengerScreen)        — bottom nav: Messages
       ├──> /calendar     (CalendarScreen)         — bottom nav: Calendar
       ├──> /emergency    (EmergencyScreen)        — Emergency SOS card
       └──> /profile      (ProfileScreen)          — bottom nav: Profile
              └──> /  (LoginScreen)                — Logout clears stack
```

---

## User Flow

### 1. Onboarding

```
App Launch
    ↓
Language Selection (Hindi / English / Marathi / Tamil / Telugu)
    ↓
Enter Phone + PIN
    ↓
Dashboard
```

### 2. Daily Household Visit

```
Dashboard
    ↓
View Priority Cards (Today's Visits / Pending Deliveries / Health Alerts)
    ↓
Tap "Add New Household"
    ↓
Visit Form Step 1: Household Info
             Step 2: Member Details
             Step 3: Health Checklist
    ↓
Submit -> Dashboard
```

### 3. Inventory Management

```
Dashboard -> "Inventory Status"
    ↓
View stock (Good / Low / Out of Stock)
    ↓
Tap "Request Refill" or "Request Emergency Refill"
    ↓
Confirmation snackbar
```

### 4. Emergency Response

```
Dashboard -> Emergency SOS card
    ↓
SOS countdown button
Live GPS location sharing
Nearby hospitals list
Direct call to emergency contacts
```

### 5. Profile and Settings

```
Dashboard bottom nav -> Profile
    ↓
Name, ASHA ID, sync status, area of coverage
Account Settings: Language | Offline Settings
    ↓
Logout -> confirmation dialog -> Login screen
```

---

## Design System

All tokens are in `lib/theme/app_theme.dart`:

| Token | Hex | Usage |
|-------|-----|-------|
| `primaryBlue` | `#1565C0` | Actions, headers, active states |
| `successGreen` | `#4CAF50` | Good stock, sync badge |
| `warningAmber` | `#FF9800` | Low stock, pending alerts |
| `criticalRed` | `#E53935` | Out of stock, emergency, logout |
| `backgroundWhite` | `#FAFAFA` | Screen backgrounds |
| `textDark` | `#1A1A2E` | Body text |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.2 |
| Language | Dart 3.x |
| State Management | StatefulWidget + setState |
| Navigation | Flutter Named Routes |
| Icons | Material Icons + flutter_launcher_icons |
| Build Optimization | R8 + ProGuard (Android) |
| Platforms | Android, iOS, Web |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0+ — [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code
- Android device or emulator

### Run Locally

```bash
git clone https://github.com/Krushna968/SwasthyaSetu.git
cd SwasthyaSetu
flutter pub get
flutter run
```

### Build APK

```bash
# Single APK
flutter build apk

# Smaller per-architecture APKs
flutter build apk --split-per-abi

# App Bundle for Play Store
flutter build appbundle
```

---

## Screens Reference

| Screen | Route | Description |
|--------|-------|-------------|
| Login | `/` | Language selector + auth |
| Dashboard | `/dashboard` | Stats, cards, quick actions |
| Visit Form | `/visit-form` | 3-step household visit |
| Messenger | `/messenger` | Team chat |
| Calendar | `/calendar` | Follow-up scheduling |
| Emergency SOS | `/emergency` | Emergency response hub |
| Inventory | `/inventory` | Medicine stock management |
| Learning | `/learning` | Health content library |
| Profile | `/profile` | Worker profile and settings |
| Help and Support | `/help` | FAQ, contact, escalation |

---

## APK Optimization

- R8 code shrinking removes unused bytecode
- Resource shrinking strips unused drawables and layouts
- Material Icons tree-shaking: 99.4% reduction in icon font size
- ProGuard rules keep Flutter engine classes intact

---

## Roadmap

- [ ] Firebase Auth (OTP login)
- [ ] Cloud Firestore patient data sync
- [ ] Offline-first with Hive or SQLite
- [ ] Push notifications for follow-up reminders
- [ ] Full Hindi and regional language localisation
- [ ] Government HMIS API integration
- [ ] PDF monthly report generation

---

## Contributing

```
1. Fork the repo
2. git checkout -b feature/your-feature
3. git commit -m "feat: description"
4. git push origin feature/your-feature
5. Open a Pull Request
```

---

## License

Educational and social-good project. All rights reserved © 2026 SwasthyaSetu / Krushna968.

---

<p align="center">Made with love for India's frontline health warriors — the ASHA workers.</p>