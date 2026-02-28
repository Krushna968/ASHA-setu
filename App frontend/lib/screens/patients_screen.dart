import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'add_patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allPatients = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchPatients();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final response = await ApiService.get('/patients');
      if (response != null && response['patients'] != null) {
        setState(() {
          _allPatients = response['patients'];
          _isLoading = false;
        });
      } else if (response != null && response['error'] != null) {
        setState(() {
          _errorMsg = response['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Failed to load patients. Check your connection.";
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _filterPatients(String category) {
    if (category == 'All') return _allPatients;
    return _allPatients.where((p) => p['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Patient Directory',
          style: TextStyle(color: MyTheme.textDark, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: MyTheme.primaryBlue),
            onPressed: _fetchPatients,
            tooltip: 'Refresh List',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: MyTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: MyTheme.primaryBlue,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'ANC (Pregnancy)'),
            Tab(text: 'PNC (Post-Natal)'),
            Tab(text: 'Infants'),
            Tab(text: 'General'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(child: Text(_errorMsg!, style: const TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPatientList(_filterPatients('All')),
                    _buildPatientList(_filterPatients('ANC')),
                    _buildPatientList(_filterPatients('PNC')),
                    _buildPatientList(_filterPatients('Infants')),
                    _buildPatientList(_filterPatients('General')),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Patient', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );
          if (result == true) {
            _fetchPatients();
          }
        },
      ),
    );
  }

  Widget _buildPatientList(List<dynamic> patients) {
    if (patients.isEmpty) {
      return const Center(
        child: Text(
          'No patients found in this category.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final String name = patient['name'] ?? 'Unknown';
        final int age = patient['age'] ?? 0;
        final String address = patient['address'] ?? 'Unknown Address';
        final String category = patient['category'] ?? 'General';
        
        // Simple avatar logic based on name initials
        final String initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: MyTheme.primaryBlue.withOpacity(0.1),
              foregroundColor: MyTheme.primaryBlue,
              radius: 24,
              child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Age: $age • $address', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: _getCategoryColor(category),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO: Navigate to patient details screen mapping (Phase 2 future item)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient Details coming soon!')));
            },
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ANC':
        return Colors.purple;
      case 'PNC':
        return Colors.pink;
      case 'Infants':
        return Colors.orange;
      case 'General':
        return Colors.teal;
      default:
        return MyTheme.primaryBlue;
    }
  }
}
