import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/visit_form_screen.dart';
import 'screens/messenger_screen.dart';

void main() {
  runApp(const SwasthyaSetuApp());
}

class SwasthyaSetuApp extends StatelessWidget {
  const SwasthyaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swasthya Setu',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/visit-form': (context) => const VisitFormScreen(),
        '/messenger': (context) => const MessengerScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
