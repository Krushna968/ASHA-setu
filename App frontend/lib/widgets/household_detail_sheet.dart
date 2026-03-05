import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/area_map_provider.dart';

class HouseholdDetailSheet extends StatefulWidget {
  final Household household;
  final AreaMapProvider provider;

  const HouseholdDetailSheet({
    super.key,
    required this.household,
    required this.provider,
  });

  @override
  State<HouseholdDetailSheet> createState() => _HouseholdDetailSheetState();
}

class _HouseholdDetailSheetState extends State<HouseholdDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _completingTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Trigger lazy-load
    widget.provider.loadHouseholdDetails(widget.household.householdId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final detail =
            widget.provider.getCachedDetail(widget.household.householdId);
        final isLoading = widget.provider.isDetailLoading && detail == null;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Sticky Header
              _buildHeader(),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),


              // Custom Styled Tab Bar
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: MyTheme.textDark,
                  unselectedLabelColor: MyTheme.textLight,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Family'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'History'),
                    Tab(text: 'Notes'),
                  ],
                ),
              ),

              // Dynamic Height Tab Content
              Flexible(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: isLoading
                      ? _buildLoadingState()
                      : detail == null
                          ? _buildEmptyState(Icons.error_outline_rounded, 'Failed to load details')
                          : TabBarView(
                              physics: const BouncingScrollPhysics(),
                              controller: _tabController,
                              children: [
                                _buildMembersTab(detail),
                                _buildTasksTab(detail),
                                _buildVisitsTab(detail),
                                _buildNotesTab(detail),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: MyTheme.primaryBlue),
          SizedBox(height: 16),
          Text('Fetching records...', style: TextStyle(color: MyTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: MyTheme.textLight, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final h = widget.household;
    final isHighRisk = h.status == 'high-risk';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with Initial
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHighRisk
                    ? [MyTheme.criticalRed, const Color(0xFFFF5252)]
                    : [MyTheme.primaryBlue, const Color(0xFF448AFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isHighRisk ? MyTheme.criticalRed : MyTheme.primaryBlue).withAlpha(40),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                h.headName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        h.headName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    _statusBadge(h.status),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: MyTheme.textLight),
                    const SizedBox(width: 4),
                    Text(
                      '${h.displayId} • ${h.address}',
                      style: const TextStyle(fontSize: 14, color: MyTheme.textLight, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final isHighRisk = status == 'high-risk';
    final isCompleted = status == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighRisk
            ? MyTheme.criticalRed.withAlpha(25)
            : isCompleted
                ? MyTheme.successGreen.withAlpha(25)
                : MyTheme.primaryBlue.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isHighRisk
              ? MyTheme.criticalRed
              : isCompleted
                  ? MyTheme.successGreen
                  : MyTheme.primaryBlue).withAlpha(100),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHighRisk ? Icons.warning_amber_rounded : isCompleted ? Icons.check_circle_outline : Icons.pending_outlined,
            size: 12,
            color: isHighRisk ? MyTheme.criticalRed : isCompleted ? MyTheme.successGreen : MyTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            isHighRisk ? 'RISK' : isCompleted ? 'DONE' : 'OPEN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isHighRisk ? MyTheme.criticalRed : isCompleted ? MyTheme.successGreen : MyTheme.primaryBlue,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(HouseholdDetail detail) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: detail.members.length,
      itemBuilder: (context, i) {
        final m = detail.members[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: MyTheme.primaryBlue.withAlpha(15),
                child: Text(
                  m['relation']?.toString().split(' ').last.substring(0, 1) ?? 'M',
                  style: const TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['name'] ?? 'Family Member',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
                    ),
                    Text(
                      '${m['relation'] ?? 'Member'} • Age ${m['age'] ?? '—'}',
                      style: const TextStyle(fontSize: 13, color: MyTheme.textLight),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksTab(HouseholdDetail detail) {
    if (detail.pendingTasks.isEmpty) {
      return _buildEmptyState(Icons.task_alt_rounded, 'Great! No pending tasks.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: detail.pendingTasks.length,
      itemBuilder: (context, i) {
        final task = detail.pendingTasks[i];
        final taskId = task['taskId'] as String? ?? '$i';
        final isCompleting = _completingTasks.contains(taskId);
        final isHighPriority = widget.household.status == 'high-risk';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Priority Stripe
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: isHighPriority ? MyTheme.criticalRed : MyTheme.primaryBlue,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isHighPriority ? MyTheme.criticalRed : MyTheme.primaryBlue).withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _taskIcon(task['type'] ?? ''),
                                color: isHighPriority ? MyTheme.criticalRed : MyTheme.primaryBlue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['type'] ?? 'Service Task',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                                  ),
                                  Text(
                                    'Due by ${task['dueDate']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isHighPriority ? MyTheme.criticalRed.withAlpha(200) : MyTheme.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (task['notes'] != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            task['notes'],
                            style: const TextStyle(fontSize: 13, color: MyTheme.textDark, height: 1.5),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isCompleting ? null : () => _handleTaskComplete(taskId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyTheme.successGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: isCompleting
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('Complete Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              onPressed: () {},
                              icon: const Icon(Icons.info_outline_rounded, size: 20),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisitsTab(HouseholdDetail detail) {
    if (detail.latestVisits.isEmpty) {
      return _buildEmptyState(Icons.history_edu_rounded, 'No visit history recorded.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      itemCount: detail.latestVisits.length,
      itemBuilder: (context, i) {
        final v = detail.latestVisits[i];
        final isLast = i == detail.latestVisits.length - 1;

        return IntrinsicHeight(
          child: Row(
            children: [
              // Timeline vertical line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(color: MyTheme.primaryBlue, shape: BoxShape.circle),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: MyTheme.primaryBlue.withAlpha(50),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['type'] ?? 'Service Visit',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                    ),
                    Text(v['date'] ?? 'No date', style: const TextStyle(fontSize: 13, color: MyTheme.textLight)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Text(
                v['status']?.toUpperCase() ?? 'COMPLETED',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: MyTheme.successGreen, letterSpacing: 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesTab(HouseholdDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFCE8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFEF08A)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFEF08A).withAlpha(50),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note_rounded, color: Color(0xFFA16207), size: 24),
                SizedBox(width: 10),
                Text(
                  'HEALTH WORKER NOTES',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFA16207), letterSpacing: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              detail.notes.isEmpty ? 'No clinical notes for this household.' : detail.notes,
              style: const TextStyle(fontSize: 15, color: Color(0xFF713F12), height: 1.6, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTaskComplete(String taskId) async {
    setState(() => _completingTasks.add(taskId));
    final success = await widget.provider.completeTask(
      householdId: widget.household.householdId,
      taskId: taskId,
      context: context,
    );
    if (mounted) {
      setState(() => _completingTasks.remove(taskId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Task cleared successfully!' : 'Saved for offline sync'),
          backgroundColor: success ? MyTheme.successGreen : MyTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  IconData _taskIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('vaccination')) return Icons.vaccines_rounded;
    if (t.contains('anc') || t.contains('antenatal')) return Icons.pregnant_woman_rounded;
    if (t.contains('pnc') || t.contains('postnatal')) return Icons.child_care_rounded;
    if (t.contains('bp') || t.contains('blood pressure')) return Icons.monitor_heart_rounded;
    return Icons.medical_services_rounded;
  }
}
