import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    final formattedPhone = phone.startsWith('+91') ? phone : '+91$phone';

    try {
      final result = await ApiService.sendOtp(formattedPhone);
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      if (result.containsKey('error')) {
         setState(() => _errorMessage = result['error']);
      } else {
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => OtpScreen(
               mobileNumber: formattedPhone,
             ),
           ),
         );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24), // Reduced from 48
              // Logo Placeholder
              Container(
                width: 100, // Reduced size
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite, // ASHA-like heart/care icon
                  size: 56,
                  color: MyTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16), // Reduced
              Text(
                'Meri Asha',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: MyTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ASHA Digital App',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24), // Reduced to shift language selection up
              
              // Language Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, size: 20, color: MyTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLanguage == 'हिंदी' ? 'भाषा चुनें' : 'SELECT LANGUAGE',
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
                    _buildLanguageOption('हिंदी'),
                    _buildLanguageOption('Regional'),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Reduced to shift mobile number up

              // Mobile Number Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedLanguage == 'हिंदी' ? 'मोबाइल नंबर' : 'Mobile Number',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: MyTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: const TextStyle(fontSize: 18, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.grey),
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('+91', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark)),
                  ),
                  hintText: '0000000000',
                  hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 2),
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
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_selectedLanguage == 'हिंदी' ? 'ओटीपी प्राप्त करें' : 'Get OTP', style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: 32), // Reduced from 64
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
                _selectedLanguage == 'हिंदी' 
                  ? 'लॉग इन करके, आप आशा सेवा शर्तों से सहमत होते हैं।'
                  : 'By logging in, you agree to the ASHA App\nTerms & Conditions and Privacy Policy.',
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
