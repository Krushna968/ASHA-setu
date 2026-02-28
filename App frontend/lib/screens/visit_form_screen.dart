import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key});

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1 — Patient Selection
  List<dynamic> _patients = [];
  bool _loadingPatients = true;
  String? _selectedPatientId;
  String _selectedPatientName = '';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Step 2 — Visit Details
  DateTime _visitDate = DateTime.now();
  String _visitType = 'Routine Checkup';
  final List<String> _visitTypes = [
    'Routine Checkup',
    'ANC Follow-up',
    'PNC Follow-up',
    'Immunization',
    'Emergency',
    'Medicine Delivery',
    'Health Education',
  ];

  // Step 3 — Symptoms & Outcome
  final Set<String> _selectedSymptoms = {};
  final List<_SymptomOption> _symptoms = [
    _SymptomOption('Fever / High Temperature', Icons.thermostat_rounded, Colors.red),
    _SymptomOption('Persistent Cough', Icons.air_rounded, Colors.orange),
    _SymptomOption('Breathing Difficulty', Icons.coronavirus_rounded, Colors.deepOrange),
    _SymptomOption('Diarrhea / Stomach Pain', Icons.sick_rounded, Colors.amber),
    _SymptomOption('Body Pain / Weakness', Icons.accessibility_new_rounded, Colors.purple),
    _SymptomOption('Skin Rash / Allergy', Icons.healing_rounded, Colors.pink),
  ];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    try {
      final response = await ApiService.get('/patients');
      if (response != null && response['patients'] != null) {
        setState(() {
          _patients = response['patients'];
          _loadingPatients = false;
        });
      }
    } catch (e) {
      setState(() => _loadingPatients = false);
    }
  }

  Future<void> _submitVisit() async {
    if (_selectedPatientId == null) return;

    setState(() => _isSubmitting = true);

    final String outcome = [
      'Type: $_visitType',
      if (_selectedSymptoms.isNotEmpty) 'Symptoms: ${_selectedSymptoms.join(', ')}',
      if (_notesController.text.trim().isNotEmpty) 'Notes: ${_notesController.text.trim()}',
      if (_selectedSymptoms.isEmpty) 'No symptoms reported',
    ].join(' | ');

    try {
      final response = await ApiService.post('/visits', {
        'patientId': _selectedPatientId,
        'visitDate': _visitDate.toIso8601String(),
        'outcome': outcome,
      });

      if (mounted) {
        if (!response.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Visit logged successfully!'),
                ],
              ),
              backgroundColor: MyTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(response['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
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
    final steps = ['Patient', 'Details', 'Symptoms'];

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: MyTheme.textDark,
        title: const Text(
          'Log Visit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(steps),
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 0
                  ? _buildStep1()
                  : _currentStep == 1
                      ? _buildStep2()
                      : _buildStep3(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─────────────────────────────────────────────────────────
  // PROGRESS INDICATOR
  // ─────────────────────────────────────────────────────────
  Widget _buildProgressIndicator(List<String> steps) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps.length, (i) {
              final isCompleted = i < _currentStep;
              final isActive = i == _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? MyTheme.successGreen
                            : isActive
                                ? MyTheme.primaryBlue
                                : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? MyTheme.primaryBlue : Colors.grey[500],
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: isCompleted ? MyTheme.successGreen : Colors.grey[200],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 1 — Select Patient
  // ─────────────────────────────────────────────────────────
  Widget _buildStep1() {
    final filtered = _searchQuery.isEmpty
        ? _patients
        : _patients.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search patient by name...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text(
            'Select a patient (${filtered.length} found)',
            style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
        ),
        // Patient list
        Expanded(
          child: _loadingPatients
              ? const Center(child: CircularProgressIndicator(color: MyTheme.primaryBlue))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    final isSelected = p['id'] == _selectedPatientId;
                    final name = p['name'] ?? 'Unknown';
                    final category = p['category'] ?? 'General';
                    final age = p['age'] ?? 0;
                    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPatientId = p['id'];
                          _selectedPatientName = name;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? MyTheme.primaryBlue.withValues(alpha: 0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? MyTheme.primaryBlue : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: MyTheme.primaryBlue)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  Text('Age $age • $category', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded, color: MyTheme.primaryBlue, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 2 — Visit Details
  // ─────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected patient chip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MyTheme.primaryBlue.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: MyTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  _selectedPatientName,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: MyTheme.primaryBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Visit Date
          const Text('Visit Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MyTheme.textDark)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _visitDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _visitDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: MyTheme.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '${_visitDate.day}/${_visitDate.month}/${_visitDate.year}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_calendar_rounded, color: Colors.grey[400], size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Visit Type
          const Text('Visit Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MyTheme.textDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _visitTypes.map((type) {
              final isSelected = _visitType == type;
              return GestureDetector(
                onTap: () => setState(() => _visitType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? MyTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? MyTheme.primaryBlue : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STEP 3 — Symptoms & Notes
  // ─────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Symptoms Observed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MyTheme.textDark)),
          const SizedBox(height: 4),
          Text('Tap all that apply', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 14),

          ...List.generate(_symptoms.length, (i) {
            final s = _symptoms[i];
            final isSelected = _selectedSymptoms.contains(s.name);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(s.name);
                  } else {
                    _selectedSymptoms.add(s.name);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? s.color.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? s.color : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isSelected ? s.color : Colors.grey[400])!.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, color: isSelected ? s.color : Colors.grey[400], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? s.color : Colors.grey[700],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: s.color, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          const Text('Notes / Observations', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: MyTheme.textDark)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Any additional observations...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 2;
    final canProceed = _currentStep == 0 ? _selectedPatientId != null : true;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (isLastStep) {
                        _submitVisit();
                      } else {
                        setState(() => _currentStep++);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLastStep ? MyTheme.successGreen : MyTheme.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Submit Visit' : 'Continue',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Icon(isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HELPER DATA CLASS
// ─────────────────────────────────────────────────────────
class _SymptomOption {
  final String name;
  final IconData icon;
  final Color color;

  _SymptomOption(this.name, this.icon, this.color);
}
