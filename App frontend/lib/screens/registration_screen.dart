import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(text: '9321609760');
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // At least 18 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MyTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: MyTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String _formatAadhaar(String value) {
    value = value.replaceAll(' ', '');
    if (value.length > 12) value = value.substring(0, 12);
    
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if ((i + 1) % 4 == 0 && i != value.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Mocking submission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              const Text('Application Sent'),
            ],
          ),
          content: const Text(
            'Your registration details have been submitted successfully. Our team will verify your ASHA credentials and notify you.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Back to login
              },
              child: Text('OK', style: TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: MyTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Registration',
          style: TextStyle(color: MyTheme.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.how_to_reg_rounded,
                      size: 64,
                      color: MyTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to ASHA-Setu',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: MyTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A digital platform for all ASHA workers. We are onboarding all workers to this new platform.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form Fields
                _buildField(
                  label: 'ASHA Unique ID',
                  controller: _idController,
                  icon: Icons.badge_outlined,
                  hint: 'Enter your Unique ID',
                  validator: (v) => v!.isEmpty ? 'ID is required' : null,
                  delay: 300,
                ),
                _buildField(
                  label: 'Full Name',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                  hint: 'Enter your full name',
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                  delay: 400,
                ),
                _buildField(
                  label: 'Full Address',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  hint: 'Enter your residential address',
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Address is required' : null,
                  delay: 500,
                ),
                _buildField(
                  label: 'Mobile Number',
                  controller: _mobileController,
                  icon: Icons.phone_iphone_rounded,
                  hint: '00000 00000',
                  prefixText: '+91 ',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) => v!.length < 10 ? 'Enter valid mobile number' : null,
                  delay: 600,
                ),
                _buildField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  icon: Icons.calendar_today_rounded,
                  hint: 'DD/MM/YYYY',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (v) => v!.isEmpty ? 'DOB is required' : null,
                  delay: 700,
                ),
                _buildField(
                  label: 'Aadhaar Card Number',
                  controller: _aadhaarController,
                  icon: Icons.fingerprint_rounded,
                  hint: '0000 0000 0000',
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final formatted = _formatAadhaar(v);
                    if (formatted != v) {
                      _aadhaarController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                  validator: (v) => v!.replaceAll(' ', '').length < 12 ? 'Enter 12-digit Aadhaar' : null,
                  delay: 800,
                ),
                
                const SizedBox(height: 48),
                
                // Submit Button
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 900),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: MyTheme.primaryBlue.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Submit Registration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int? maxLines,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int delay = 0,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: MyTheme.textDark.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller,
              maxLines: maxLines ?? 1,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              validator: validator,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: MyTheme.textDark,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: hint,
                prefixIcon: Icon(icon, color: MyTheme.primaryBlue),
                prefixText: prefixText,
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textDark,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: MyTheme.primaryBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
