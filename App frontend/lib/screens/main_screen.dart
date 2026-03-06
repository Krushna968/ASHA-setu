import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'messenger_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'sakhi_chat_screen.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).fetchAllData();
    });
  }

  final List<Widget> _pages = [
    const DashboardScreen(),
    const MessengerScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final currentIndex = appState.currentIndex;
        return PopScope(
          canPop: currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (currentIndex != 0) {
              appState.setCurrentIndex(0);
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: currentIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: MyTheme.primaryBlue,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              currentIndex: currentIndex,
              onTap: (index) {
                appState.setCurrentIndex(index);
              },
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: AppLocalizations.of(context)!.home),
                BottomNavigationBarItem(icon: Icon(currentIndex == 1 ? Icons.notifications : Icons.notifications_none_rounded), label: AppLocalizations.of(context)!.notifications),
                BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: AppLocalizations.of(context)!.calendar),
                BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: AppLocalizations.of(context)!.profile),
              ],
            ),
            floatingActionButton: Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SakhiChatScreen()));
                },
                backgroundColor: Colors.white,
                elevation: 0,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/SakhiAI.png',
                    fit: BoxFit.cover,
                    width: 65,
                    height: 65,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
