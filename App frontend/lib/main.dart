import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/visit_form_screen.dart';
import 'screens/messenger_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/individuals_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/add_individual_screen.dart';
import 'screens/high_risk_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/language_selection_screen.dart';
import 'services/auth_service.dart';
import 'providers/app_state_provider.dart';
import 'services/notification_service.dart';
import 'providers/area_map_provider.dart';
import 'l10n/app_localizations.dart';
import 'widgets/loading_transition_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await Hive.initFlutter();
  await Hive.openBox('appData');
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..loadLocalData()),
        ChangeNotifierProvider(create: (_) => AreaMapProvider()),
      ],
      child: const AshaSetuApp(),
    ),
  );
}

class AshaSetuApp extends StatelessWidget {
  const AshaSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'ASHA Setu',
          locale: appState.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: MyTheme.lightTheme,
          home: FutureBuilder<List<bool>>(
            future: Future.wait([
              AuthService.isLoggedIn(),
              AuthService.isLanguageSelected(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              final isLoggedIn = snapshot.data?[0] ?? false;
              final isLanguageSelected = snapshot.data?[1] ?? false;
              
              if (isLoggedIn) {
                return const MainScreen(); // Direct to dashboard
              } else if (isLanguageSelected) {
                return const LoginScreen(); // Skip language, go to login
              } else {
                return const LanguageSelectionScreen(); // Show language first
              }
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/dashboard': (context) => const MainScreen(),
            '/visit-form': (context) => const VisitFormScreen(),
            '/individuals': (context) => const IndividualsScreen(),
            '/messenger': (context) => const MessengerScreen(),
            '/emergency': (context) => const EmergencyScreen(),
            '/calendar': (context) => const CalendarScreen(),
            '/inventory': (context) => const InventoryScreen(),
            '/learning': (context) => const LearningScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/help': (context) => const HelpSupportScreen(),
            '/add-individual': (context) => const AddIndividualScreen(),
            '/high-risk': (context) => const HighRiskScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/language': (context) => const LanguageSelectionScreen(),
          },
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    if (appState.isTransitioning) {
                      return const LoadingTransitionScreen(message: 'Loading ASHA-Setu...');
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
