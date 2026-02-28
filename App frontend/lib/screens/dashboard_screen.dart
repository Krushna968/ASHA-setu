import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _workerName = 'Loading...';
  String _employeeId = '....';
  String _village = 'Loading...';
  String _lastSyncTime = 'JUST NOW';
  String? _profileImageUrl;
  int _patientsCount = 0;
  int _tasksCount = 0;
  int _visitsCount = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AuthService.getWorkerName();
    if (mounted) {
      setState(() {
        _workerName = name ?? 'ASHA Worker';
      });
    }

    try {
      final stats = await ApiService.get('/worker/stats');
      if (mounted && !stats.containsKey('error')) {
        setState(() {
          _workerName = stats['name'] ?? _workerName;
          _village = stats['village'] ?? 'Local Village';
          _employeeId = stats['employeeId'] ?? 'Unknown ID';
          _patientsCount = stats['patients'] ?? 0;
          _tasksCount = stats['tasks'] ?? 0;
          _visitsCount = stats['totalVisits'] ?? 0;
          _profileImageUrl = stats['profileImage'];
          _lastSyncTime = DateFormat('hh:mm a').format(DateTime.now());
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              Text(
                'Daily Priority',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPriorityCards(context),
              const SizedBox(height: 24),
              _buildSyncButton(context),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildQuickActionPill(context, Icons.person_add, 'Add Household', '/visit-form'),
                    const SizedBox(width: 12),
                    _buildQuickActionPill(context, Icons.people, 'Patient Directory', '/patients'),
                    const SizedBox(width: 12),
                    _buildQuickActionPill(context, Icons.inventory_2, 'Inventory', '/inventory'),
                    const SizedBox(width: 12),
                    _buildQuickActionPill(context, Icons.book, 'Learning', '/learning'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                   const Icon(Icons.cloud_done, size: 16, color: MyTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'SYNCED: $_lastSyncTime',
                    style: const TextStyle(
                      color: MyTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 16),
             Row(
               children: [
                 Container(
                   width: 56,
                   height: 56,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     color: const Color(0xFF77B5D9),
                     border: Border.all(color: Colors.white, width: 2),
                   ),
                   child: Stack(
                     children: [
                       ClipOval(
                         child: _profileImageUrl != null
                             ? Image.network(_profileImageUrl!, fit: BoxFit.cover, width: 56, height: 56,
                                 errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 32, color: Colors.white))
                             : const Icon(Icons.person, size: 32, color: Colors.white),
                       ),
                       const Align(
                         alignment: Alignment.bottomRight,
                         child: CircleAvatar(
                           radius: 8,
                           backgroundColor: Colors.white,
                           child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _workerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ASHA ID: $_employeeId',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'AREA: ${_village.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
               ],
             )
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
          onPressed: _handleLogout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildPriorityCards(BuildContext context) {
    return Column(
      children: [
        _buildCard(
          icon: Icons.people,
          iconColor: MyTheme.primaryBlue,
          title: "Total Registered Patients",
          count: _isLoadingStats ? '-' : '$_patientsCount',
          progress: _patientsCount > 0 ? 1.0 : 0.0,
          progressLabel: 'Active',
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/messenger'),
          child: _buildCard(
            icon: Icons.assignment_turned_in,
            iconColor: MyTheme.successGreen,
            bgColor: Colors.green.shade50,
            title: "Open Tasks",
            subtitle: "Assigned follow-ups & duties",
            count: _isLoadingStats ? '-' : '$_tasksCount',
            isAlert: true,
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          icon: Icons.map,
          iconColor: Colors.orange,
          bgColor: Colors.orange.shade50,
          title: "Total Career Visits",
          count: _isLoadingStats ? '-' : '$_visitsCount',
          trailingLabel: "ALL TIME",
        ),
      ],
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? count,
    Color bgColor = Colors.white,
    double? progress,
    String? progressLabel,
    bool isAlert = false,
    String? trailingLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const Spacer(),
              if (isAlert && count != null)
                 Container(
                  padding: const EdgeInsets.all(8),
                   decoration: const BoxDecoration(
                     color: MyTheme.criticalRed,
                     shape: BoxShape.circle,
                   ),
                   child: Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 )
              else if (count != null && progress == null)
                Text(
                  count,
                   style: const TextStyle(
                     fontSize: 28,
                     fontWeight: FontWeight.bold,
                     color: MyTheme.textDark,
                   ),
                )
               else if (trailingLabel != null)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.orange.shade100,
                     borderRadius: BorderRadius.circular(4),
                   ),
                   child: Text(trailingLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                 )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MyTheme.textDark,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          if (progress != null) ...[
             const SizedBox(height: 8),
             Row(
               children: [
                 Expanded(
                   child: ClipRRect(
                     borderRadius: BorderRadius.circular(4),
                     child: LinearProgressIndicator(
                       value: progress,
                       minHeight: 6,
                       backgroundColor: Colors.grey.shade200,
                       color: MyTheme.successGreen,
                     ),
                   ),
                 ),
                 if (progressLabel != null) ...[
                   const SizedBox(width: 8),
                    Text(
                     progressLabel,
                     style: const TextStyle(
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       color: MyTheme.successGreen,
                     ),
                   ),
                 ]
               ],
             )
          ],
           if (count != null && progress != null)
             Align(
               alignment: Alignment.topRight,
               child: Text(
                 count,
                 style: const TextStyle(
                     fontSize: 28,
                     fontWeight: FontWeight.bold,
                     color: MyTheme.primaryBlue, // Special color for visits
                   ),
               ),
             ),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sync, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sync All Data',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
           const Text(
            'Manual push to server',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionPill(BuildContext context, IconData icon, String label, String? route) {
    return GestureDetector(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: MyTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30), // Pill Shape
          border: Border.all(color: MyTheme.primaryBlue.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: MyTheme.primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: MyTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
