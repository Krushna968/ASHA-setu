import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/area_map_provider.dart';

class VisitFormScreen extends StatefulWidget {
  const VisitFormScreen({super.key});

  @override
  State<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends State<VisitFormScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 0 — House Selection
  String? _selectedHouseholdId;
  String _selectedHouseLabel = '';
  List<Map<String, dynamic>> _households = [];
  bool _isLoadingHouseholds = true;

  // Step 1 — Individual Selection (filtered by house)
  String? _selectedIndividualId;
  String _selectedIndividualName = '';
  List<dynamic> _householdIndividuals = [];
  bool _isLoadingIndividuals = false;
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

  // Step 3 — Symptoms, Notes & House Close
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
  bool _markHouseClosed = false;

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
        _households = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .where((h) => h['isClosed'] != true) // Hide closed houses
            .toList();
        _isLoadingHouseholds = false;
      });
    } catch (e) {
      setState(() => _isLoadingHouseholds = false);
    }
  }

  Future<void> _loadIndividualsForHousehold(String householdId) async {
    setState(() => _isLoadingIndividuals = true);
    try {
      // Get all individuals and filter by householdId
      final provider = Provider.of<AppStateProvider>(context, listen: false);
      await provider.fetchIndividuals();
      setState(() {
        _householdIndividuals = provider.individuals
            .where((p) => p['householdId'] == householdId)
            .toList();
        _isLoadingIndividuals = false;
      });
    } catch (e) {
      setState(() => _isLoadingIndividuals = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitVisit() async {
    if (_selectedIndividualId == null) return;

    setState(() => _isSubmitting = true);

    final String outcome = [
      'Type: $_visitType',
      if (_selectedSymptoms.isNotEmpty) 'Symptoms: ${_selectedSymptoms.join(', ')}',
      if (_notesController.text.trim().isNotEmpty) 'Notes: ${_notesController.text.trim()}',
      if (_selectedSymptoms.isEmpty) 'No symptoms reported',
      if (_markHouseClosed) '⚠ HOUSE MARKED AS CLOSED',
    ].join(' | ');

    try {
      final provider = Provider.of<AppStateProvider>(context, listen: false);
        if (!mounted) return;
        final mapProvider = Provider.of<AreaMapProvider>(context, listen: false);
        bool synced = await provider.logVisitOfflineSupport({
        'patientId': _selectedIndividualId,
        'visitDate': _visitDate.toIso8601String(),
        'outcome': outcome,
        'visitType': _visitType,
        'symptoms': _selectedSymptoms.join(', '),
        'notes': _notesController.text.trim(),
        'isHouseClosed': _markHouseClosed,
      });

        // Update Map Provider if house is closed or task completed
        if (_markHouseClosed) {
          mapProvider.closeHousehold(_selectedHouseholdId!);
        }
        
        // Also refresh the whole area and dashboard stats
        mapProvider.refreshArea();
        
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    synced
                        ? (_markHouseClosed
                            ? 'Visit logged & house marked as closed!'
                            : 'Visit logged successfully!')
                        : 'Visit saved offline (will sync later)',
                  ),
                ),
              ],
            ),
            backgroundColor: synced ? MyTheme.successGreen : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
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
    final steps = ['House', 'Individual', 'Details', 'Symptoms'];

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: MyTheme.textDark,
        title: const Text('Log Visit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          _buildProgressIndicator(steps),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentStep == 0
                  ? _buildStep0HouseSelect()
                    : _currentStep == 1
                        ? _buildStep1IndividualSelect()
                      : _currentStep == 2
                          ? _buildStep2Details()
                          : _buildStep3SymptomsAndClose(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ─── Progress Indicator ─────────────────────────────────────────
  Widget _buildProgressIndicator(List<String> steps) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
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
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    steps[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? MyTheme.primaryBlue : Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: isCompleted ? MyTheme.successGreen : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── STEP 0 — Select House ──────────────────────────────────────
  Widget _buildStep0HouseSelect() {
    return Column(
      key: const ValueKey('step0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text('Select a household', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: _isLoadingHouseholds
              ? const Center(child: CircularProgressIndicator(color: MyTheme.primaryBlue))
              : _households.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No households found', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: _households.length,
                      itemBuilder: (context, i) {
                        final h = _households[i];
                        final houseId = h['householdId'] ?? h['id'] ?? '';
                        final houseNum = h['displayId'] ?? h['houseNumber'] ?? '';
                        final headName = h['headName'] ?? '';
                        final members = h['memberCount'] ?? 0;
                        final status = h['status'] ?? 'pending';
                        final isSelected = houseId == _selectedHouseholdId;

                        Color statusColor;
                        switch (status) {
                          case 'high-risk':
                            statusColor = MyTheme.criticalRed;
                            break;
                          case 'completed':
                            statusColor = MyTheme.successGreen;
                            break;
                          default:
                            statusColor = MyTheme.primaryBlue;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedHouseholdId = houseId;
                              _selectedHouseLabel = '$houseNum – $headName';
                              _selectedIndividualId = null;
                              _selectedIndividualName = '';
                            });
                            _loadIndividualsForHousehold(houseId);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? MyTheme.primaryBlue.withAlpha(15) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? MyTheme.primaryBlue : Colors.grey.shade200,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      houseNum,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(headName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('$members members • $status', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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

  // ─── STEP 1 — Select Individual (filtered by house) ───────────────
  Widget _buildStep1IndividualSelect() {
    final filtered = _searchQuery.isEmpty
        ? _householdIndividuals
        : _householdIndividuals.where((p) {
            final name = (p['name'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // House label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home_rounded, size: 14, color: MyTheme.primaryBlue),
                const SizedBox(width: 6),
                Text(_selectedHouseLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MyTheme.primaryBlue)),
              ],
            ),
          ),
        ),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search individual by name...',
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
          child: Text('${filtered.length} individuals in this house', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ),
        Expanded(
          child: _isLoadingIndividuals
              ? const Center(child: CircularProgressIndicator(color: MyTheme.primaryBlue))
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('No individuals in this house', style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(height: 4),
                          Text('Register an individual to this house first', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final p = filtered[i];
                        final isSelected = p['id'] == _selectedIndividualId;
                        final name = p['name'] ?? 'Unknown';
                        final category = p['category'] ?? 'General';
                        final age = p['age'] ?? 0;
                        final relation = p['relation'] ?? '';
                        final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndividualId = p['id'];
                              _selectedIndividualName = name;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? MyTheme.primaryBlue.withAlpha(15) : Colors.white,
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
                                    color: MyTheme.primaryBlue.withAlpha(25),
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
                                      Text(
                                        'Age $age • $category${relation.isNotEmpty ? ' • $relation' : ''}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
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

  // ─── STEP 2 — Visit Details ─────────────────────────────────────
  Widget _buildStep2Details() {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MyTheme.primaryBlue.withAlpha(40)),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_rounded, color: MyTheme.primaryBlue, size: 16),
                const SizedBox(width: 6),
                Flexible(child: Text(_selectedHouseLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MyTheme.primaryBlue))),
                const SizedBox(width: 12),
                const Icon(Icons.person_rounded, color: MyTheme.primaryBlue, size: 16),
                const SizedBox(width: 4),
                Flexible(child: Text(_selectedIndividualName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MyTheme.primaryBlue))),
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
                  const Icon(Icons.calendar_today_rounded, color: MyTheme.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Text('${_visitDate.day}/${_visitDate.month}/${_visitDate.year}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                    border: Border.all(color: isSelected ? MyTheme.primaryBlue : Colors.grey.shade200),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[600]),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── STEP 3 — Symptoms, Notes & House Close Toggle ──────────────
  Widget _buildStep3SymptomsAndClose() {
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
                  color: isSelected ? s.color.withAlpha(20) : Colors.white,
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
                        color: (isSelected ? s.color : Colors.grey[400])!.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, color: isSelected ? s.color : Colors.grey[400], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.name,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? s.color : Colors.grey[700]),
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
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── House Closed Toggle ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _markHouseClosed ? MyTheme.criticalRed.withAlpha(15) : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _markHouseClosed ? MyTheme.criticalRed : Colors.grey.shade200,
                width: _markHouseClosed ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (_markHouseClosed ? MyTheme.criticalRed : Colors.grey[400])!.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _markHouseClosed ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: _markHouseClosed ? MyTheme.criticalRed : Colors.grey[400],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark House as Closed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _markHouseClosed ? MyTheme.criticalRed : MyTheme.textDark,
                        ),
                      ),
                      Text(
                        'This will grey out the house on the map',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _markHouseClosed,
                  onChanged: (val) => setState(() => _markHouseClosed = val),
                  activeThumbColor: MyTheme.criticalRed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 3;
    bool canProceed;
    switch (_currentStep) {
      case 0:
        canProceed = _selectedHouseholdId != null;
        break;
      case 1:
        canProceed = _selectedIndividualId != null;
        break;
      default:
        canProceed = true;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -3))],
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
                backgroundColor: isLastStep
                    ? (_markHouseClosed ? MyTheme.criticalRed : MyTheme.successGreen)
                    : MyTheme.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep
                              ? (_markHouseClosed ? 'Submit & Close House' : 'Submit Visit')
                              : 'Continue',
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

class _SymptomOption {
  final String name;
  final IconData icon;
  final Color color;
  _SymptomOption(this.name, this.icon, this.color);
}
