import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/visit_form_screen.dart';
import 'screens/messenger_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/help_support_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/visit-form': (context) => const VisitFormScreen(),
        '/messenger': (context) => const MessengerScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/learning': (context) => const LearningScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/help': (context) => const HelpSupportScreen(),
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
