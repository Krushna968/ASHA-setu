import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../services/auth_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _languages = [
    {'name': 'हिंदी', 'code': 'hi', 'symbol': 'ह'},
    {'name': 'தமிழ்', 'code': 'ta', 'symbol': 'த'},
    {'name': 'తెలుగు', 'code': 'te', 'symbol': 'తె'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn', 'symbol': 'ಕ'},
    {'name': 'English', 'code': 'en', 'symbol': 'A'},
    {'name': 'मराठी', 'code': 'mr', 'symbol': 'म'},
    {'name': 'বাংলা', 'code': 'bn', 'symbol': 'ব'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Which language do you want to see ASHA-Setu in?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: MyTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _languages.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      return _buildLanguageCard(lang);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: MyTheme.primaryBlue,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      child: Column(
        children: [
          const Text(
            'ASHA-Setu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32, // Increased font size
              fontWeight: FontWeight.w900, // Extra bold
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          // Stepper UI
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(1, 'Language', true),
              _buildStepConnector(false),
              _buildStepIndicator(2, 'Login', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? MyTheme.primaryBlue : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4),
      color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.3),
    );
  }

  Widget _buildLanguageCard(Map<String, String> lang) {
    return GestureDetector(
      onTap: () async {
        context.read<AppStateProvider>().setLocale(Locale(lang['code']!));
        await AuthService.setLanguageSelected();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  lang['symbol']!,
                  style: TextStyle(
                    color: MyTheme.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              lang['name']!,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: MyTheme.textDark,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
