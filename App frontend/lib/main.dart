import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/visit_form_screen.dart';
import 'screens/messenger_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/patients_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/add_patient_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Explicitly activate Firebase App Check in Debug mode
  // This is required for Phone Authentication on Emulators which fail Play Integrity checks.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const AshaSetuApp());
}

class AshaSetuApp extends StatelessWidget {
  const AshaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASHA Setu',
      theme: MyTheme.lightTheme,
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a simple loading splash while checking token
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final isLoggedIn = snapshot.data ?? false;
          
          if (isLoggedIn) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/dashboard': (context) => const MainScreen(),
        '/visit-form': (context) => const VisitFormScreen(),
        '/patients': (context) => const PatientsScreen(),
        '/messenger': (context) => const MessengerScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/learning': (context) => const LearningScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/help': (context) => const HelpSupportScreen(),
        '/add-patient': (context) => const AddPatientScreen(),
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
