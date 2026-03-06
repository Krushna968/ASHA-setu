import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({
    super.key, 
    required this.mobileNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = [
    TextEditingController(text: '0'),
    TextEditingController(text: '5'),
    TextEditingController(text: '0'),
    TextEditingController(text: '2'),
    TextEditingController(text: '2'),
    TextEditingController(text: '8'),
  ];
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    String otpString = _otpControllers.map((c) => c.text).join();

    if (otpString != '050228') {
      setState(() => _errorMessage = 'Invalid OTP. For testing, use 050228.');
      return;
    }

    if (otpString.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Bypass for hardcoded testing credentials
    if (widget.mobileNumber.contains('9321609760') && otpString == '050228') {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      
      final mockWorker = {
        '_id': 'mock_worker_id',
        'name': 'Krushna Rasal',
        'mobileNumber': '9321609760',
        'ashaId': 'ASHA12345',
        'area': 'Sector 4',
      };
      
      await AuthService.saveAuthData('mock_token', mockWorker);
      // await NotificationService.sendCurrentToken(); // Might fail without actual backend
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
      return;
    }

    try {
      // Send OTP to backend for verification
      final result = await ApiService.verifyOtp(widget.mobileNumber, otpString);

      if (!mounted) return;

      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      } else if (result.containsKey('token') && result.containsKey('worker')) {
        // Save auth data locally (our custom Node.js JWT)
        await AuthService.saveAuthData(result['token'], result['worker']);
        
        // Send FCM token now that user is logged in
        await NotificationService.sendCurrentToken();
        
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: MyTheme.primaryBlue),
      ),
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
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: MyTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: MyTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent a 6-digit code to\n+91 ${widget.mobileNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        counterText: '',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: MyTheme.primaryBlue, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 48),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Verify & Login', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
