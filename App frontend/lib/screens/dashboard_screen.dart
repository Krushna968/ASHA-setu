import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../providers/app_state_provider.dart';
import '../providers/area_map_provider.dart';
import 'area_task_map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String _workerName = 'ASHA Worker';
  String _employeeId = 'A010';
  String _village = 'Airoli';
  String _lastSyncTime = 'JUST NOW';
  String? _profileImageUrl;
  int _individualsCount = 0;
  int _tasksCount = 0;
  int _visitsCount = 0;
  bool _isLoadingStats = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Refresh area data to get latest dashboard stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use the global provider to refresh data
        context.read<AreaMapProvider>().refreshArea();
      }
    });

    _loadUserData();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
          _village = stats['village'] ?? 'Airoli';
          _employeeId = stats['employeeId'] ?? 'A010';
          _individualsCount = stats['patients'] ?? 0;
          _tasksCount = stats['tasks'] ?? 0;
          _visitsCount = stats['totalVisits'] ?? 0;
          _profileImageUrl = stats['profileImage'];
          _lastSyncTime = DateFormat('hh:mm a').format(DateTime.now());
          _isLoadingStats = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: MyTheme.criticalRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _loadUserData,
            color: MyTheme.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildCircularCenterpiece(),
                  const SizedBox(height: 16),
                  _buildLiveStatsRow(),
                  const SizedBox(height: 20),
                  _buildCondensedStatsRow(),
                  const SizedBox(height: 24),
                  _buildActionRequiredCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Quick Actions'),
                  const SizedBox(height: 14),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Activity', showViewAll: true),
                  const SizedBox(height: 14),
                  _buildRecentActivity(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CENTERPIECE — Google Fit-style circular progress
  // ─────────────────────────────────────────────────────────
  Widget _buildCircularCenterpiece() {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, child) {
        final int completed = provider.totalCompleted;
        final int target = provider.households.length > 0 ? provider.households.length : 1;
        final double progress = (completed / target).clamp(0.0, 1.0);
        final bool isTargetMet = completed >= target;
        
        final Color progressColor = isTargetMet ? MyTheme.successGreen : MyTheme.primaryBlue;

        return Center(
          child: Column(
            children: [
              SizedBox(
                height: 240,
                width: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Glow/Shadow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: progressColor.withValues(alpha: 0.1),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    
                    // The Gauge
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return CustomPaint(
                          size: const Size(220, 220),
                          painter: _DailyProgressPainter(
                            progress: value,
                            color: progressColor,
                            trackColor: progressColor.withValues(alpha: 0.1),
                          ),
                        );
                      },
                    ),
                    
                    // Inner Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$completed',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: MyTheme.textDark,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'HOUSES DONE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: progressColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Total: $target Houses',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: progressColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isTargetMet)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars_rounded, color: MyTheme.successGreen, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Daily Target Achieved!',
                        style: TextStyle(
                          color: MyTheme.successGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // LIVE STATS ROW — Patients, Tasks, Visits
  // ─────────────────────────────────────────────────────────
  Widget _buildLiveStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleStat(
            label: 'Individuals',
            value: _isLoadingStats ? '—' : '$_individualsCount',
            icon: Icons.people_rounded,
            color: MyTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleStat(
            label: 'Tasks',
            value: _isLoadingStats ? '—' : '$_tasksCount',
            icon: Icons.assignment_turned_in_rounded,
            color: MyTheme.successGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleStat(
            label: 'Visits',
            value: _isLoadingStats ? '—' : '$_visitsCount',
            icon: Icons.directions_walk_rounded,
            color: MyTheme.warningOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MyTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CONDENSED STATS ROW
  // ─────────────────────────────────────────────────────────
  Widget _buildCondensedStatsRow() {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/high-risk'),
                child: _buildSmallStatCard(
                  icon: Icons.warning_rounded,
                  label: 'High Risk',
                  value: '${provider.highRiskCount}',
                  color: provider.highRiskCount > 0 ? MyTheme.criticalRed : MyTheme.successGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.pending_actions_rounded,
                label: 'Due Today',
                value: '${provider.dueTodayCount}',
                color: provider.hasOverdue ? MyTheme.criticalRed : MyTheme.primaryBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textDark,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Keep existing action cards but optimize spacing if needed...


  // ─────────────────────────────────────────────────────────
  // HEADER — Greeting + Avatar + Sync Badge
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _workerName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ASHA ID: $_employeeId  •  ${_village.toUpperCase()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              // Sync badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: MyTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done_rounded, size: 14, color: MyTheme.successGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Synced: $_lastSyncTime',
                      style: TextStyle(
                        color: MyTheme.successGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Profile Avatar
        GestureDetector(
          onTap: () {
            context.read<AppStateProvider>().setCurrentIndex(3);
          },
          child: Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      MyTheme.primaryBlue.withValues(alpha: 0.8),
                      MyTheme.primaryBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: MyTheme.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileImageUrl != null
                      ? Image.network(
                          _profileImageUrl!,
                          fit: BoxFit.cover,
                          width: 52,
                          height: 52,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                ),
              ),
              // Online dot
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: MyTheme.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  // ─────────────────────────────────────────────────────────
  // ACTION REQUIRED — Pending follow-ups card
  // ─────────────────────────────────────────────────────────

  Widget _buildActionRequiredCard() {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, child) {
        final pendingHouses = provider.households.where((h) => h.status == 'pending' || h.status == 'high-risk').length;
        final completedHouses = provider.totalCompleted;
        final totalHouses = provider.households.length;
        final progress = totalHouses > 0 ? (completedHouses / totalHouses).clamp(0.0, 1.0) : 1.0;

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
              )),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AreaTaskMapScreen(filterMode: 'all'),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MyTheme.primaryBlue.withAlpha(75),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TODAY\'S TASKS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pendingHouses > 0 ? '$pendingHouses Pending Houses' : 'All houses visited! 🎉',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        Row(
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999), 
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withAlpha(50),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pendingHouses > 0
                              ? '• Tap to view your task calendar.'
                              : '• Great job staying on top of your work.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: MyTheme.primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: MyTheme.textDark,
          ),
        ),
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/individuals'),
            child: Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MyTheme.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // QUICK ACTIONS — 2×3 Grid
  // ─────────────────────────────────────────────────────────
  Widget _buildQuickActionsGrid() {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, child) {
        final hasHighRisk = provider.highRiskCount > 0;
        
        final defaultActions = [
          QuickAction(Icons.assignment_rounded, 'Log Visit', const Color(0xFFE53935), '/visit-form'),
          QuickAction(Icons.map_rounded, 'Household Map', const Color(0xFF00897B), '/map_action'),
          QuickAction(Icons.rule_rounded, 'Today\'s Tasks', const Color(0xFFF57C00), '/calendar_action'),
          QuickAction(Icons.person_add_rounded, 'Register Individual', const Color(0xFF0056D2), '/add-individual'),
          QuickAction(Icons.warning_rounded, 'High Risk', MyTheme.criticalRed, '/high-risk'),
          QuickAction(Icons.school_rounded, 'Learning', const Color(0xFF7B1FA2), '/learning'),
        ];

        List<QuickAction> actions = List.from(defaultActions);
        
        // Intelligent sorting: move High Risk to front if there's high risk cases
        if (hasHighRisk) {
          final highRiskAction = actions.removeAt(4);
          actions.insert(0, highRiskAction);
        }

        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
              )),
              child: child,
            );
          },
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildQuickActionCard(action);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return GestureDetector(
      onTap: () {
        if (action.route == '/map_action') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AreaTaskMapScreen()),
          );
        } else if (action.route == '/calendar_action') {
          // Navigate to the Calendar tab
          final appState = Provider.of<AppStateProvider>(context, listen: false);
          appState.setCurrentIndex(1);
        } else if (action.route == '/high-risk') {
          Navigator.pushNamed(context, '/high-risk');
        } else if (action.route != null) {
          Navigator.pushNamed(context, action.route!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // RECENT ACTIVITY — Latest patient interactions
  // ─────────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    final appProvider = Provider.of<AppStateProvider>(context);
    final visits = appProvider.visits;
    
    // Convert visits to RecentItems
    final recentItems = visits.take(3).map((v) {
      final String name = v['patientName'] ?? v['headName'] ?? 'Unknown';
      final String type = v['visitType'] ?? v['outcome'] ?? 'Visit';
      final String timeAgo = _formatVisitTime(v['visitDate'] ?? v['createdAt']);
      
      // Determine color based on type
      Color color = MyTheme.primaryBlue;
      if (type.toLowerCase().contains('prenatal') || type.toLowerCase().contains('anc')) {
        color = MyTheme.successGreen;
      } else if (type.toLowerCase().contains('urgent') || type.toLowerCase().contains('risk')) {
        color = MyTheme.warningOrange;
      }
      
      return RecentItem(name, type, timeAgo, color);
    }).toList();

    if (recentItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No recent activity', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          )),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: List.generate(recentItems.length, (index) {
            final item = recentItems[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Avatar circle with initials
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.dotColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item.name.split(' ').map((e) => e[0]).take(2).join(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: item.dotColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: MyTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.type,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.dotColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.dotColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < recentItems.length - 1)
                  Divider(height: 1, color: Colors.grey.shade100, indent: 68),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _formatVisitTime(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM').format(dt);
    } catch (e) {
      return 'Recent';
    }
  }
}

// ─────────────────────────────────────────────────────────
// HELPER DATA CLASSES
// ─────────────────────────────────────────────────────────
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  QuickAction(this.icon, this.label, this.color, [this.route]);
}

class RecentItem {
  final String name;
  final String type;
  final String timeAgo;
  final Color dotColor;

  RecentItem(this.name, this.type, this.timeAgo, this.dotColor);
}

// ─────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────

class _DailyProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _DailyProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12; // Leave space for stroke width
    const strokeWidth = 24.0;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw Progress Arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Draw the arc starting from top (-pi/2)
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708, // -90 degrees in radians
        6.28319 * progress, // 2*pi * progress
        false,
        progressPaint,
      );
      
      // Add a subtle inner shadow/stroke for depth
      final detailPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
        
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + (strokeWidth / 2) - 2),
        -1.5708,
        6.28319 * progress,
        false,
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DailyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.color != color || 
           oldDelegate.trackColor != trackColor;
  }
}

