import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/area_map_provider.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedCategory = 'General';
  String? _selectedHouseholdId;
  String _selectedRelation = 'Member';

  final List<_CategoryOption> _categories = [
    _CategoryOption('General', Icons.person_rounded, Colors.teal, 'Regular health checkups'),
    _CategoryOption('ANC', Icons.pregnant_woman_rounded, Colors.purple, 'Antenatal Care (Pregnancy)'),
    _CategoryOption('PNC', Icons.child_friendly_rounded, Colors.pink, 'Postnatal Care'),
    _CategoryOption('Infants', Icons.child_care_rounded, Colors.orange, 'Child (0-5 years)'),
  ];

  final List<String> _relations = [
    'Head (Mother)',
    'Husband',
    'Wife',
    'Son',
    'Daughter',
    'Mother-in-law',
    'Father-in-law',
    'Newborn',
    'Child',
    'Member',
  ];

  bool _isSubmitting = false;
  bool _isLoadingHouseholds = true;
  List<Map<String, dynamic>> _households = [];

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  Future<void> _loadHouseholds() async {
    try {
      final response = await ApiService.get('/households');
      final list = response['households'] as List<dynamic>? ?? [];
      setState(() {
        _households = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoadingHouseholds = false;
      });
    } catch (e) {
      setState(() => _isLoadingHouseholds = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHouseholdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a house number'),
          backgroundColor: MyTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.post('/patients', {
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'category': _selectedCategory,
        'householdId': _selectedHouseholdId,
        'relation': _selectedRelation,
      });

      if (!response.containsKey('error')) {
        if (mounted) {
          // Refresh map to update task counts if necessary
          Provider.of<AreaMapProvider>(context, listen: false).refreshArea();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('Patient registered & linked to house!')),
                ],
              ),
              backgroundColor: MyTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: ${e.toString()}'),
            backgroundColor: MyTheme.criticalRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Register Patient'),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: MyTheme.textDark,
        titleTextStyle: const TextStyle(
          color: MyTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: MyTheme.primaryBlue.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyTheme.primaryBlue.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: MyTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Select the house number first, then fill in patient details.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── House Number Dropdown ──
              _buildLabel('House Number', true),
              const SizedBox(height: 8),
              _buildHouseDropdown(),
              const SizedBox(height: 20),

              // Full Name
              _buildLabel('Full Name', true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter patient\'s full name',
                icon: Icons.person_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 20),

              // Age
              _buildLabel('Age (Years)', true),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageController,
                hint: 'Enter age',
                icon: Icons.cake_rounded,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter age';
                  if (int.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category
              _buildLabel('Care Category', true),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 20),

              // Relation
              _buildLabel('Relation in Family', false),
              const SizedBox(height: 8),
              _buildRelationDropdown(),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Register Patient',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── House Dropdown ─────────────────────────────────────────────
  Widget _buildHouseDropdown() {
    if (_isLoadingHouseholds) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: MyTheme.primaryBlue)),
            SizedBox(width: 12),
            Text('Loading households...', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedHouseholdId != null ? MyTheme.primaryBlue : Colors.grey.shade200,
          width: _selectedHouseholdId != null ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedHouseholdId,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.home_rounded, color: MyTheme.primaryBlue, size: 20),
          hintText: 'Select house (e.g. H001)',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        isExpanded: true,
        items: _households.map((h) {
          final hn = h['displayId'] ?? h['houseNumber'] ?? '';
          final head = h['headName'] ?? '';
          final isClosed = h['isClosed'] == true;
          return DropdownMenuItem<String>(
            value: h['householdId'] ?? h['id'] ?? '',
            enabled: !isClosed,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed ? Colors.grey[200] : MyTheme.primaryBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hn,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isClosed ? Colors.grey : MyTheme.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    head,
                    style: TextStyle(
                      fontSize: 13,
                      color: isClosed ? Colors.grey : MyTheme.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isClosed)
                  Icon(Icons.lock_rounded, size: 14, color: Colors.grey[400]),
              ],
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedHouseholdId = val;

          });
        },
      ),
    );
  }

  // ─── Relation Dropdown ──────────────────────────────────────────
  Widget _buildRelationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRelation,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.people_rounded, color: MyTheme.primaryBlue, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        isExpanded: true,
        items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
        onChanged: (val) => setState(() => _selectedRelation = val ?? 'Member'),
      ),
    );
  }

  // ─── Label ──────────────────────────────────────────────────────
  Widget _buildLabel(String text, bool required) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: MyTheme.textDark, fontSize: 14)),
        if (required)
          const Text(' *', style: TextStyle(color: MyTheme.criticalRed, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ─── Text Field ─────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: MyTheme.primaryBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyTheme.criticalRed)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Category Selector ──────────────────────────────────────────
  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat.name;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? cat.color.withAlpha(25) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cat.color : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 18, color: isSelected ? cat.color : Colors.grey[400]),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? cat.color : Colors.grey[600])),
                    Text(cat.subtitle, style: TextStyle(fontSize: 10, color: isSelected ? cat.color.withAlpha(180) : Colors.grey[400])),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle_rounded, size: 16, color: cat.color),
                ],
              ],
            ),
          ),
        );
      }).toList(),
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
