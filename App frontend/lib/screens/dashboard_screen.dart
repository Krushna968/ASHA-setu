import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
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
  String _employeeId = '....';
  String _village = 'Loading...';
  String _lastSyncTime = 'JUST NOW';
  String? _profileImageUrl;
  int _patientsCount = 0;
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
          _village = stats['village'] ?? 'Local Village';
          _employeeId = stats['employeeId'] ?? 'Unknown ID';
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
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
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
          onTap: _handleLogout,
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
  // STATS ROW — Redesigned with action-oriented metrics
  // ─────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Consumer<AreaMapProvider>(
      builder: (context, AreaMapProvider provider, child) {
        return AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
              )),
              child: child,
            );
          },
          child: Row(
            children: [
              // 1. Today's Target
              Expanded(
                child: _buildTargetCard(
                  completed: provider.completedToday,
                  target: provider.targetToday,
                ),
              ),
              const SizedBox(width: 8),
              // 2. High Risk Cases
              Expanded(
                child: _buildHighRiskCard(
                  count: provider.highRiskCount,
                ),
              ),
              const SizedBox(width: 8),
              // 3. Due Today
              Expanded(
                child: _buildDueTodayCard(
                  count: provider.dueTodayCount,
                  hasOverdue: provider.hasOverdue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetCard({required int completed, required int target}) {
    final bool isComplete = completed >= target && target > 0;
    final double progress = (completed / (target > 0 ? target : 1)).clamp(0.0, 1.0);
    
    // Determine color based on status
    Color cardColor = progress >= 0.5 ? MyTheme.primaryBlue : MyTheme.primaryBlue.withValues(alpha: 0.7);
    if (isComplete) cardColor = MyTheme.successGreen;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isComplete ? MyTheme.successGreen.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isComplete ? Border.all(color: MyTheme.successGreen.withValues(alpha: 0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: cardColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                ),
              ),
              Icon(
                isComplete ? Icons.task_alt_rounded : Icons.track_changes_rounded,
                size: 20,
                color: cardColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$completed / $target',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isComplete ? MyTheme.successGreen : MyTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Today's Visits",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isComplete ? MyTheme.successGreen.withValues(alpha: 0.8) : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isComplete)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Target Achieved 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: MyTheme.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else 
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "Target Progress",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHighRiskCard({required int count}) {
    final bool hasHighRisk = count > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: hasHighRisk ? const Color(0xFFFFF1F1) : MyTheme.successGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: hasHighRisk 
            ? Border.all(color: MyTheme.criticalRed.withValues(alpha: 0.3)) 
            : Border.all(color: MyTheme.successGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: hasHighRisk ? MyTheme.criticalRed.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasHighRisk 
                  ? MyTheme.criticalRed.withValues(alpha: 0.1) 
                  : MyTheme.successGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasHighRisk ? Icons.warning_rounded : Icons.health_and_safety_rounded, 
              color: hasHighRisk ? MyTheme.criticalRed : MyTheme.successGreen, 
              size: 20
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasHighRisk ? '$count' : '0',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: hasHighRisk ? MyTheme.criticalRed : MyTheme.successGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasHighRisk ? "High Risk" : "No High Risk",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: hasHighRisk ? MyTheme.criticalRed.withValues(alpha: 0.7) : MyTheme.successGreen.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueTodayCard({required int count, bool hasOverdue = false}) {
    final bool isAllClear = count == 0;
    final Color mainColor = isAllClear 
        ? MyTheme.successGreen 
        : (hasOverdue ? MyTheme.criticalRed : MyTheme.primaryBlue);
        
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAllClear ? Icons.check_circle_rounded : Icons.pending_actions_rounded, 
              color: mainColor, 
              size: 20
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isAllClear ? 'All Clear' : '$count',
            style: TextStyle(
              fontSize: isAllClear ? 14 : 22,
              fontWeight: FontWeight.bold,
              color: mainColor,
            ),
          ),
          if (!isAllClear) const SizedBox(height: 2),
          if (!isAllClear)
            Text(
              "Due Today",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (isAllClear) const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ACTION REQUIRED — Pending follow-ups card
  // ─────────────────────────────────────────────────────────
  Widget _buildActionRequiredCard() {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, child) {
        final pendingTasks = provider.dueTodayCount;
        final completed = provider.completedToday;
        final totalToday = pendingTasks + completed;
        final progress = totalToday > 0 ? (completed / totalToday).clamp(0.0, 1.0) : 1.0;

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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AreaTaskMapScreen()),
            ),
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
                          pendingTasks > 0 ? '$pendingTasks Due Today' : 'All clear today! 🎉',
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
                          pendingTasks > 0
                              ? '• Keep going! Tap to view tasks on map.'
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
            onTap: () => Navigator.pushNamed(context, '/patients'),
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
          QuickAction(Icons.rule_rounded, 'Today\'s Tasks', const Color(0xFFF57C00), '/map_action'),
          QuickAction(Icons.person_add_rounded, 'Add Patient', const Color(0xFF0056D2), '/add-patient'),
          QuickAction(Icons.warning_rounded, 'High Risk', MyTheme.criticalRed, '/map_action'),
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
    // Placeholder recent activity data
    final recentItems = [
      RecentItem('Priya Sharma', 'Prenatal Checkup', '2h ago', MyTheme.successGreen),
      RecentItem('Rahul Kumar', 'Vaccination', '4h ago', MyTheme.primaryBlue),
      RecentItem('Anjali Singh', 'Iron Supplements Delivered', 'Yesterday', MyTheme.warningOrange),
    ];

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
