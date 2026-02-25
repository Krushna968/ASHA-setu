import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedLanguage = 'English';
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.sendOtp(phone);

    setState(() {
      _isLoading = false;
    });

    if (result.containsKey('error')) {
      setState(() => _errorMessage = result['error']);
    } else {
      // Navigate to OTP Screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(mobileNumber: phone),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // Logo Placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade100, // Placeholder color matching logo bg
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.health_and_safety, // Placeholder icon
                  size: 64,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'NATIONAL HEALTH MISSION',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF0056D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ASHA Digital Portal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              
              // Language Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, size: 20, color: MyTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'SELECT LANGUAGE / भाषा चुनें',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    _buildLanguageOption('English'),
                    _buildLanguageOption('हिंदी'), // Hindi
                    _buildLanguageOption('Regional'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Mobile Number Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mobile Number / मोबाइल नंबर',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: MyTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.grey),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('+91', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark)),
                  ),
                  hintText: '0 0 0 0 0 0 0 0 0 0',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  suffixIcon: const Icon(Icons.phone_android, color: Colors.grey),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 32),

              // Get OTP Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Get OTP / ओटीपी प्राप्त करें', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: 64),
              // Footer Support
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   _buildFooterItem(Icons.help_outline, 'SUPPORT'),
                   const SizedBox(width: 40),
                   _buildFooterItem(Icons.info_outline, 'GUIDE'),
                ],
              ),
              const SizedBox(height: 24),
               Text(
                'By logging in, you agree to the Digital Healthcare\nTerms & Conditions and Privacy Policy of the National\nHealth Mission.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label) {
    bool isSelected = _selectedLanguage == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLanguage = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? MyTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : MyTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: MyTheme.primaryBlue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
