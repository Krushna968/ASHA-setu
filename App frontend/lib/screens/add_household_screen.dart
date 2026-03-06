import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/area_map_provider.dart';
import '../theme/app_theme.dart';

class AddHouseholdScreen extends StatefulWidget {
  const AddHouseholdScreen({super.key});

  @override
  State<AddHouseholdScreen> createState() => _AddHouseholdScreenState();
}

class _AddHouseholdScreenState extends State<AddHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // House Controllers
  final _houseNumberController = TextEditingController();
  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Head Member Controllers
  final _headNameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedCategory = 'General';
  DateTime? _selectedEDD;
  bool _isSubmitting = false;

  final List<_CategoryOption> _categories = [
    _CategoryOption('General', Icons.person_rounded, Colors.teal, 'Regular health checkups'),
    _CategoryOption('ANC', Icons.pregnant_woman_rounded, Colors.purple, 'Antenatal Care'),
    _CategoryOption('PNC', Icons.child_friendly_rounded, Colors.pink, 'Postnatal Care'),
    _CategoryOption('Infants', Icons.child_care_rounded, Colors.orange, 'Child (0-5 years)'),
  ];

  @override
  void dispose() {
    _houseNumberController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _headNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == 'ANC' && _selectedEDD == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an Expected Date of Delivery (EDD)'),
          backgroundColor: MyTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final errorMessage = await Provider.of<AreaMapProvider>(context, listen: false).createHousehold(
      houseNumber: _houseNumberController.text.trim(),
      headName: _headNameController.text.trim(),
      address: _addressController.text.trim(),
      village: _villageController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      category: _selectedCategory,
      pregnancyEDD: (_selectedCategory == 'ANC' && _selectedEDD != null) ? _selectedEDD!.toIso8601String() : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Household registered successfully!'),
            backgroundColor: MyTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // After successful addition, go back to map (grid view) as requested
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage), // Display the exact error message
            backgroundColor: MyTheme.criticalRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Add New Household'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: MyTheme.textDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('House Information'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _houseNumberController,
                hint: 'House Number (e.g. H101)',
                icon: Icons.home_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _villageController,
                hint: 'Village Name',
                icon: Icons.location_city_rounded,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _addressController,
                hint: 'Full Address/Landmark',
                icon: Icons.map_rounded,
                maxLines: 2,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Head of Family Details'),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _headNameController,
                hint: 'Full Name of Head',
                icon: Icons.person_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _ageController,
                hint: 'Age',
                icon: Icons.cake_rounded,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Enter a number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              _buildLabel('Care Category'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              
              if (_selectedCategory == 'ANC') ...[
                _buildLabel('Expected Date of Delivery (EDD)'),
                const SizedBox(height: 12),
                _buildEDDPicker(),
                const SizedBox(height: 24),
              ],
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register Household', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.primaryBlue),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: MyTheme.textDark, fontSize: 14));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: MyTheme.primaryBlue, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5)),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat.name;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cat.color.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? cat.color : Colors.grey.shade200, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 16, color: isSelected ? cat.color : Colors.grey),
                const SizedBox(width: 8),
                Text(cat.name, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? cat.color : Colors.grey)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectEDD(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: MyTheme.textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MyTheme.primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedEDD) {
      setState(() {
        _selectedEDD = picked;
      });
    }
  }

  Widget _buildEDDPicker() {
    return GestureDetector(
      onTap: () => _selectEDD(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: MyTheme.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Text(
              _selectedEDD == null
                  ? 'Select EDD'
                  : '${_selectedEDD!.day.toString().padLeft(2, '0')}/${_selectedEDD!.month.toString().padLeft(2, '0')}/${_selectedEDD!.year}',
              style: TextStyle(
                fontSize: 14,
                color: _selectedEDD == null ? Colors.grey[400] : MyTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryOption {
  final String name;
  final IconData icon;
  final Color color;
  final String subtitle;
  _CategoryOption(this.name, this.icon, this.color, this.subtitle);
}
