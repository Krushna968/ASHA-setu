import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../providers/area_map_provider.dart';
import '../theme/app_theme.dart';

class HighRiskScreen extends StatefulWidget {
  const HighRiskScreen({super.key});

  @override
  State<HighRiskScreen> createState() => _HighRiskScreenState();
}

class _HighRiskScreenState extends State<HighRiskScreen> {
  String _activeFilter = 'All'; // All, Critical, Needs Attention, Monitored

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AreaMapProvider>().refreshArea();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: Consumer<AreaMapProvider>(
        builder: (context, provider, child) {
          final highRiskHouseholds = provider.households
              .where((h) => h.status == 'high-risk')
              .toList();

          // Filtering logic based on instructions derivation
          // Critical = high-risk AND pendingTasksCount > 0 AND has overdue tasks (using hasOverdue as proxy if available)
          // Needs Attention = high-risk AND pendingTasksCount > 0
          // Monitored = high-risk AND pendingTasksCount == 0
          
          final criticalList = highRiskHouseholds.where((h) => h.pendingTasksCount > 0 && provider.hasOverdue).toList();
          final needsAttentionList = highRiskHouseholds.where((h) => h.pendingTasksCount > 0 && !criticalList.contains(h)).toList();
          final monitoredList = highRiskHouseholds.where((h) => h.pendingTasksCount == 0).toList();

          List<Household> filteredList;
          if (_activeFilter == 'Critical') {
            filteredList = criticalList;
          } else if (_activeFilter == 'Needs Attention') {
            filteredList = needsAttentionList;
          } else if (_activeFilter == 'Monitored') {
            filteredList = monitoredList;
          } else {
            filteredList = highRiskHouseholds;
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshArea(),
            color: MyTheme.criticalRed,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(provider.highRiskCount),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildRiskSummary(
                      critical: criticalList.length,
                      needsAttention: needsAttentionList.length,
                      monitored: monitoredList.length,
                    ),
                  ),
                ),
                if (provider.isLoading && highRiskHouseholds.isEmpty)
                  _buildLoadingState()
                else if (provider.error != null && highRiskHouseholds.isEmpty)
                  _buildErrorState(provider.error!, provider)
                else if (highRiskHouseholds.isEmpty)
                  _buildEmptyState()
                else
                  _buildPatientList(filteredList, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(int count) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: MyTheme.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'High Risk Registry',
        style: TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Row(
            children: [
              Pulse(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MyTheme.criticalRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, color: MyTheme.criticalRed, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total High Risk Cases',
                    style: TextStyle(color: MyTheme.textLight, fontSize: 13),
                  ),
                  Text(
                    '$count Patients',
                    style: const TextStyle(
                      color: MyTheme.criticalRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskSummary({required int critical, required int needsAttention, required int monitored}) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSummaryCard(
            'Critical', 
            critical, 
            MyTheme.criticalRed, 
            const Color(0xFF8B0000),
            Icons.notification_important_rounded,
          ),
          _buildSummaryCard(
            'Needs Attention', 
            needsAttention, 
            MyTheme.warningOrange, 
            const Color(0xFFFF5722),
            Icons.pending_actions_rounded,
          ),
          _buildSummaryCard(
            'Monitored', 
            monitored, 
            MyTheme.successGreen, 
            const Color(0xFF1B5E20),
            Icons.verified_user_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, int value, Color color, Color accentColor, IconData icon) {
    bool isSelected = _activeFilter == label;
    return FadeInRight(
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = isSelected ? 'All' : label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? color : Colors.black).withOpacity(isSelected ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : MyTheme.textDark,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white.withOpacity(0.9) : MyTheme.textLight,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientList(List<Household> households, AreaMapProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final h = households[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 50),
              child: _PatientCard(household: h, provider: provider),
            );
          },
          childCount: households.length,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: List.generate(4, (index) => 
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, AreaMapProvider provider) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: MyTheme.criticalRed, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load patients',
              style: MyTheme.lightTheme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: MyTheme.lightTheme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.refreshArea(),
              style: ElevatedButton.styleFrom(backgroundColor: MyTheme.criticalRed),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: MyTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.health_and_safety_rounded, color: MyTheme.successGreen, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: Column(
                children: [
                  const Text(
                    'No high-risk cases right now! 💚',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: MyTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All patients are in stable condition.',
                    style: TextStyle(color: MyTheme.textLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Household household;
  final AreaMapProvider provider;

  const _PatientCard({required this.household, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Left border color logic
    Color urgencyColor = MyTheme.successGreen;
    if (provider.hasOverdue && household.pendingTasksCount > 0) {
      urgencyColor = MyTheme.criticalRed;
    } else if (household.pendingTasksCount > 0) {
      urgencyColor = MyTheme.warningOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: urgencyColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            household.headName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: MyTheme.secondaryBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            household.displayId,
                            style: const TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      household.address,
                      style: TextStyle(color: MyTheme.textLight, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    
                    // Risk Reason Placeholder (we can lazy load details when tapped or show a snippet if we had it)
                    // For now, use the badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: household.badges.map((b) => _buildBadge(b)).toList(),
                    ),
                    
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.assignment_late_rounded, size: 16, color: urgencyColor),
                        const SizedBox(width: 6),
                        Text(
                          '${household.pendingTasksCount} Pending Tasks',
                          style: TextStyle(color: urgencyColor, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () => _showDetails(context),
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('View History'),
                            style: TextButton.styleFrom(
                              foregroundColor: MyTheme.textLight,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/visit-form', arguments: household.householdId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyTheme.criticalRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Log Visit', style: TextStyle(fontSize: 13)),
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
  }

  Widget _buildBadge(String type) {
    Color bColor = Colors.grey;
    IconData icon = Icons.info_outline;
    
    switch (type.toLowerCase()) {
      case 'antenatal':
        bColor = Colors.purple;
        icon = Icons.pregnant_woman_rounded;
        break;
      case 'bp-check':
        bColor = MyTheme.criticalRed;
        icon = Icons.favorite_rounded;
        break;
      case 'vaccination':
        bColor = Colors.blue;
        icon = Icons.vaccines_rounded;
        break;
      case 'postnatal':
        bColor = Colors.pink;
        icon = Icons.child_care_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: bColor),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: TextStyle(color: bColor, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HouseholdDetailsSheet(
        householdId: household.householdId,
        provider: provider,
        headName: household.headName,
      ),
    );
  }
}

class _HouseholdDetailsSheet extends StatefulWidget {
  final String householdId;
  final AreaMapProvider provider;
  final String headName;

  const _HouseholdDetailsSheet({
    required this.householdId, 
    required this.provider,
    required this.headName,
  });

  @override
  State<_HouseholdDetailsSheet> createState() => _HouseholdDetailsSheetState();
}

class _HouseholdDetailsSheetState extends State<_HouseholdDetailsSheet> {
  @override
  void initState() {
    super.initState();
    widget.provider.loadHouseholdDetails(widget.householdId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<AreaMapProvider>(
        builder: (context, provider, _) {
          final detail = provider.getCachedDetail(widget.householdId);
          
          if (provider.isDetailLoading && detail == null) {
            return const Center(child: CircularProgressIndicator(color: MyTheme.criticalRed));
          }

          if (detail == null) {
            return const Center(child: Text('Could not load details'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: MyTheme.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.headName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          if (detail.notes.isNotEmpty)
                            Text(
                              detail.notes,
                              style: const TextStyle(color: MyTheme.criticalRed, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionTitle('Family Members'),
                    ...detail.members.map((m) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: MyTheme.secondaryBlue,
                        child: Text(m['name'][0], style: const TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${m['relation']} • ${m['age']} yrs'),
                    )),
                    
                    const SizedBox(height: 20),
                    _buildSectionTitle('Pending Tasks'),
                    if (detail.pendingTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('No pending tasks', style: TextStyle(color: MyTheme.textLight)),
                      )
                    else
                      ...detail.pendingTasks.map((t) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event_note_rounded, size: 16, color: MyTheme.warningOrange),
                                  const SizedBox(width: 8),
                                  Text(
                                    t['type'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Due: ${t['dueDate']}',
                                    style: const TextStyle(fontSize: 12, color: MyTheme.textLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(t['notes'] ?? '', style: TextStyle(fontSize: 13, color: MyTheme.textLight)),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => provider.completeTask(
                                    householdId: widget.householdId,
                                    taskId: t['taskId'],
                                    context: context,
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor: MyTheme.successGreen.withOpacity(0.1),
                                    foregroundColor: MyTheme.successGreen,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Mark Visited', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      
                    const SizedBox(height: 20),
                    _buildSectionTitle('Last Visits'),
                    ...detail.latestVisits.map((v) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_rounded, color: Colors.grey),
                      title: Text(v['type']),
                      subtitle: Text(v['date']),
                      trailing: const Icon(Icons.check_circle, color: MyTheme.successGreen, size: 20),
                    )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: MyTheme.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
