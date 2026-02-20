<![CDATA[<p align="center">
  <img src="web/favicon.png" alt="SwasthyaSetu Logo" width="140"/>
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
  &nbsp;
  <img src="https://img.shields.io/badge/Flutter-3.41.2-02569B?style=for-the-badge&logo=flutter"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart"/>
  &nbsp;
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge"/>
</p>

---

## 📖 About the Project

**SwasthyaSetu** (स्वास्थ्य सेतु — "Health Bridge") is a comprehensive mobile application designed specifically for **ASHA (Accredited Social Health Activist) workers** in India. ASHA workers are the backbone of India's primary healthcare system, serving as the first point of contact for communities in rural and semi-urban areas.

This app digitalizes the entire workflow of an ASHA worker — from household visits and patient tracking to medicine inventory management and emergency response — replacing paper-based systems with a fast, offline-capable, multilingual digital portal.

---

## 📥 Download

| Platform | Link |
|----------|------|
| Android APK | [⬇ SwasthyaSetu.apk (v1.0.0)](https://github.com/Krushna968/SwasthyaSetu/releases/download/v1.0.0/SwasthyaSetu.apk) |

---

## ✨ Features at a Glance

| Feature | Description |
|---------|-------------|
| 🌐 Language Selection | Choose Hindi, English, Marathi, Tamil, Telugu on login |
| 🏠 Smart Dashboard | Priority visit cards, alerts, quick actions, daily stats |
| 📋 Household Visit Form | Multi-step visit form with member details & health checklist |
| 💬 Messenger | Team communication with read receipts and priority labels |
| 📅 Calendar | Follow-up tracker with color-coded appointment types |
| 🚨 Emergency SOS | One-tap emergency with live GPS, nearby hospital finder |
| 📦 Inventory Status | Medicine stock levels, refill requests, emergency refill |
| 📚 Learning Materials | Categorized health content with progress tracking |
| 👤 Worker Profile | Personal info, area of coverage, sync status, language settings |
| ❓ Help & Support | FAQ accordion, call supervisor, emergency helpline, live chat |

---

## 🏗️ Architecture

```
SwasthyaSetu/
├── lib/
│   ├── main.dart                   # App entry, MaterialApp, named routes
│   ├── theme/
│   │   └── app_theme.dart          # MyTheme — colors, text styles, ThemeData
│   └── screens/
│       ├── login_screen.dart       # Language picker + login
│       ├── dashboard_screen.dart   # Home dashboard with stats & quick actions
│       ├── visit_form_screen.dart  # Multi-step Stepper form (3 steps)
│       ├── messenger_screen.dart   # Chat / messaging UI
│       ├── calendar_screen.dart    # Follow-up calendar
│       ├── emergency_screen.dart   # SOS screen with map & emergency contacts
│       ├── inventory_screen.dart   # Medicine inventory with refill actions
│       ├── learning_screen.dart    # Learning materials with tab filter
│       ├── profile_screen.dart     # Worker profile & account settings
│       └── help_support_screen.dart# Help centre with FAQ, contact options
├── assets/
│   └── icons/
│       └── app_icon.png            # App launcher icon (Meri Asha character)
├── android/
│   └── app/
│       ├── build.gradle.kts        # R8 minification + ProGuard enabled
│       └── proguard-rules.pro      # Flutter-safe ProGuard rules
├── web/
│   └── favicon.png                 # Web favicon (same Meri Asha icon)
└── pubspec.yaml                    # Dependencies + flutter_launcher_icons config
```

### Design Pattern
- **Stateless + Stateful widgets** — screens use `StatefulWidget` only when local UI state (forms, tabs, accordions) is needed
- **Named Route Navigation** — all screen transitions go through `MaterialApp.routes`, keeping navigation declarative and centralized in `main.dart`
- **Centralized Theme** — `MyTheme` class in `app_theme.dart` exposes all colors and `ThemeData`, ensuring no hardcoded colors anywhere in the UI
- **Component-first layout** — each screen composes small private builder methods (`_buildCard`, `_buildQuickAction` etc.) rather than monolithic `build()` trees

---

## 🗺️ Navigation / Route Map

```
/ (LoginScreen)
│
└──▶ /dashboard (DashboardScreen)
       ├──▶ /visit-form    (VisitFormScreen)      — "Add New Household"
       ├──▶ /inventory     (InventoryScreen)       — "Inventory Status"
       ├──▶ /learning      (LearningScreen)        — "Learning Materials"
       ├──▶ /help          (HelpSupportScreen)     — "Help & Support" / 🔔 bell
       ├──▶ /messenger     (MessengerScreen)       — bottom nav: Messages
       ├──▶ /calendar      (CalendarScreen)        — bottom nav: Calendar
       ├──▶ /emergency     (EmergencyScreen)       — Emergency SOS card
       └──▶ /profile       (ProfileScreen)         — bottom nav: Profile
              └──▶ /  (LoginScreen)                — Logout clears stack
```

---

## 👤 User Flow

### 1. Onboarding — Language & Login
```
App Launch
    ↓
Language Selection (Hindi / English / Marathi / Tamil / Telugu)
    ↓
Enter Phone + OTP / PIN
    ↓
Dashboard
```

### 2. Daily Workflow
```
Dashboard
    ↓
View Priority Cards (Today's Visits, Pending Deliveries, Health Alerts)
    ↓
Tap "Add New Household" Quick Action
    ↓
Visit Form — Step 1: Household Info
           — Step 2: Member Details
           — Step 3: Health Checklist
    ↓
Submit → back to Dashboard
```

### 3. Inventory Management
```
Dashboard → "Inventory Status"
    ↓
View stock list (Good ✅ / Low ⚠️ / Out ❌)
    ↓
Tap "Request Refill" or "Request Emergency Refill"
    ↓
Snackbar confirmation
```

### 4. Learning
```
Dashboard → "Learning Materials"
    ↓
Filter by tab: All / Videos / Guides / Health Tips
    ↓
Browse cards (thumbnail, progress bar, offline badge)
    ↓
Open content
```

### 5. Emergency Response
```
Dashboard → Emergency SOS card  (or  Help & Support → "Emergency Helpline")
    ↓
EmergencyScreen:
    • SOS countdown button
    • Live GPS location sharing
    • Nearby hospitals list
    • Direct call to emergency contacts
```

### 6. Profile & Settings
```
Dashboard bottom nav → "Profile"
    ↓
View: Name, ASHA ID, Sync Status, Area of Coverage
    ↓
Account Settings: Language Change | Offline Settings
Support: Help & Support | About App
    ↓
Logout → Confirmation dialog → redirected to Login
```

---

## 🎨 Design System

All design tokens live in `lib/theme/app_theme.dart`:

| Token | Value | Usage |
|-------|-------|-------|
| `primaryBlue` | `#1565C0` | Primary actions, headers, active states |
| `successGreen` | `#4CAF50` | Good stock, sync badge, checkmarks |
| `warningAmber` | `#FF9800` | Low stock, pending alerts |
| `criticalRed` | `#E53935` | Out of stock, emergency, logout |
| `backgroundWhite` | `#FAFAFA` | Screen backgrounds |
| `textDark` | `#1A1A2E` | Body text |

**Typography:** System default with `FontWeight` variants. All font sizing done via `ThemeData.textTheme`.

**Iconography:** Material Icons throughout (`Icons.*`), supplemented with custom icon-in-container patterns (colored circular/rounded-square badges).

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41.2 |
| Language | Dart 3.x |
| State Management | Built-in `StatefulWidget` + `setState` |
| Navigation | Flutter Named Routes |
| Icons | Material Icons + `flutter_launcher_icons` |
| Internationalization | Ready for `intl` package |
| Build Optimization | R8 minification + ProGuard (Android) |
| Platforms | Android · iOS · Web |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0 ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android Studio / VS Code
- Android device or emulator

### Run Locally

```bash
# 1. Clone the repository
git clone https://github.com/Krushna968/SwasthyaSetu.git
cd SwasthyaSetu

# 2. Install dependencies
flutter pub get

# 3. Run on connected device / emulator
flutter run

# 4. Run on Chrome (web)
flutter run -d chrome
```

### Build APK

```bash
# Full release APK
flutter build apk

# Smaller per-architecture APKs (recommended for distribution)
flutter build apk --split-per-abi

# Android App Bundle (for Play Store)
flutter build appbundle
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Login | `/` | Language selector + auth |
| Dashboard | `/dashboard` | Stats, priority cards, quick actions |
| Visit Form | `/visit-form` | 3-step household visit |
| Messenger | `/messenger` | Team chat |
| Calendar | `/calendar` | Follow-up scheduling |
| Emergency SOS | `/emergency` | Emergency response hub |
| Inventory | `/inventory` | Medicine stock management |
| Learning | `/learning` | Health content library |
| Profile | `/profile` | Worker profile & settings |
| Help & Support | `/help` | FAQ, contact, escalation |

---

## 📂 Dependencies

```yaml
dependencies:
  flutter_svg: ^2.2.3      # SVG rendering for illustrations
  intl: ^0.20.2             # Internationalization & date formatting

dev_dependencies:
  flutter_lints: ^6.0.0    # Lint rules
  flutter_launcher_icons: ^0.14.4  # App icon generation
```

---

## 🔧 APK Optimization

The release build uses:
- **R8 code shrinking** — removes unused Dart/Java bytecode
- **Resource shrinking** — strips unused drawables/layouts
- **Tree-shaking** for Material Icons — only used icons are bundled (99.4% reduction in icon font size)
- **ProGuard rules** (`android/app/proguard-rules.pro`) — keeps all Flutter engine classes safe

---

## 🛣️ Roadmap

- [ ] Firebase Auth integration (OTP-based login)
- [ ] Cloud Firestore sync for patient records
- [ ] Offline-first with Hive / SQLite
- [ ] Push notifications for follow-up reminders
- [ ] Hindi / regional language full localization
- [ ] Government API integration (HMIS)
- [ ] PDF report generation for monthly surveys

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

```
1. Fork the repo
2. Create your branch: git checkout -b feature/your-feature
3. Commit changes: git commit -m 'feat: your feature'
4. Push: git push origin feature/your-feature
5. Open a Pull Request
```

---

## 📄 License

This project is for educational and social-good purposes. All rights reserved © 2026 SwasthyaSetu / Krushna968.

---

<p align="center">
  Made with ❤️ for India's frontline health warriors — the ASHA workers.
</p>
]]>