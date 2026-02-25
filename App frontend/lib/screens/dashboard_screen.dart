import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _workerName = 'Loading...';

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
              _buildQuickAction(context, Icons.person_add, 'Add New Household', '/visit-form'),
              _buildQuickAction(context, Icons.inventory, 'Inventory Status', '/inventory'),
              _buildQuickAction(context, Icons.book, 'Learning Materials', '/learning'),
              _buildQuickAction(context, Icons.help_outline, 'Help & Support', '/help'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MyTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/messenger');
          if (index == 2) Navigator.pushNamed(context, '/calendar');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
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
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, size: 16, color: MyTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    'OFFLINE MODE',
                    style: TextStyle(
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
                 const CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Placeholder
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
                    ),
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
                      'ASHA ID: 98765-432',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'LAST SYNCED: 2H AGO',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
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
          icon: Icons.home_work,
          iconColor: MyTheme.primaryBlue,
          title: "Today's Visits",
          count: '12',
          progress: 0.6,
          progressLabel: '8/12 DONE',
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/emergency'),
          child: _buildCard(
            icon: Icons.warning_amber_rounded, // Use warning icon for emergency
            iconColor: Colors.red,
            bgColor: Colors.red.shade50,
            title: "Emergency Alerts",
            subtitle: "Immediate attention required",
            count: '3', // Badge count
            isAlert: true,
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          icon: Icons.calendar_today,
          iconColor: Colors.orange,
          bgColor: Colors.orange.shade50,
          title: "Follow-ups",
          count: '04',
          trailingLabel: "PENDING",
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

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, String? route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (route != null) Navigator.pushNamed(context, route);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
             border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade50,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Icon(icon, color: MyTheme.primaryBlue),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: MyTheme.textDark,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
