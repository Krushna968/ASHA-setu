import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/area_map_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/household_detail_sheet.dart';
import 'add_household_screen.dart'; // New Import
import 'dart:math' as math;

// filterMode: 'all' = full household list | 'highRisk' = filtered high-risk list
class AreaTaskMapScreen extends StatefulWidget {
  final String filterMode; // 'all' or 'highRisk' or 'grid'
  const AreaTaskMapScreen({super.key, this.filterMode = 'all'});

  @override
  State<AreaTaskMapScreen> createState() => _AreaTaskMapScreenState();
}

class _AreaTaskMapScreenState extends State<AreaTaskMapScreen> {
  // We'll track the mode locally if we want to switch to 'grid' after adding
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.filterMode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AreaMapProvider>(context, listen: false).refreshArea();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AreaMapProvider>(
      builder: (context, provider, _) {
        final filteredHouseholds = _currentMode == 'highRisk'
            ? provider.households.where((h) => h.status == 'high-risk').toList()
            : provider.households;

        final title = _currentMode == 'highRisk' ? 'High Risk Houses' : 'All Households';
        final subtitle = _currentMode == 'highRisk'
            ? '${filteredHouseholds.length} high-risk homes'
            : '${provider.households.length} total homes';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: MyTheme.textDark,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: MyTheme.textLight)),
              ],
            ),
            actions: [
              if (_currentMode == 'all')
                IconButton(
                  icon: const Icon(Icons.grid_view_rounded), // Changed icon to match "Map/Grid" feel
                  tooltip: 'View Grid',
                  onPressed: () => setState(() => _currentMode = 'grid'),
                )
              else if (_currentMode == 'grid')
                IconButton(
                  icon: const Icon(Icons.list_alt_rounded),
                  tooltip: 'View List',
                  onPressed: () => setState(() => _currentMode = 'all'),
                ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => provider.refreshArea(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: provider.isLoading
              ? _buildLoadingState()
              : (provider.error != null && provider.households.isEmpty)
                  ? _buildErrorState(provider)
                  : _currentMode == 'grid'
                      ? _buildGridView(provider, context)
                      : _buildListView(filteredHouseholds, provider, _currentMode),
          floatingActionButton: _currentMode != 'highRisk' ? FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHouseholdScreen()),
              );
              if (result == true) {
                // If succeeded, switch to grid mode to show the "Houses Map"
                setState(() => _currentMode = 'grid');
              }
            },
            backgroundColor: MyTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_home_work_rounded),
            label: const Text('Add House', style: TextStyle(fontWeight: FontWeight.bold)),
          ) : null,
        );
      },
    );
  }

  Widget _buildListView(List<Household> households, AreaMapProvider provider, String filterMode) {
    if (households.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 64, color: MyTheme.successGreen.withAlpha(180)),
            const SizedBox(height: 16),
            Text(
              filterMode == 'highRisk' ? 'No high-risk households!' : 'No households found.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark),
            ),
            const SizedBox(height: 8),
            const Text('Great work keeping your area healthy.', style: TextStyle(color: MyTheme.textLight)),
          ],
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(provider, filterMode, households)),
        // ---- list items ----
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _HouseListCard(
                household: households[index],
                provider: provider,
              ),
              childCount: households.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(AreaMapProvider provider, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;
    final isSmallPhone = width < 360;
    final int areaGridCols = provider.area?.gridColumns ?? 0;
    int gridColumns = 4;
    if (isTablet) gridColumns = (areaGridCols > 0) ? areaGridCols : 6;
    else if (isSmallPhone) gridColumns = 3;
    final double childAspectRatio = isTablet ? 1.1 : 0.85;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(provider, 'grid', provider.households)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Household Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark)),
                _buildLegend(isSmallPhone),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= provider.households.length) return null;
                return _HouseTile(household: provider.households[index], provider: provider);
              },
              childCount: provider.households.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3, color: MyTheme.primaryBlue),
          SizedBox(height: 16),
          Text(
            'Loading area map...',
            style: TextStyle(color: MyTheme.textLight, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AreaMapProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MyTheme.criticalRed.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 40, color: MyTheme.criticalRed),
            ),
            const SizedBox(height: 20),
            const Text(
              "Couldn't load area map",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MyTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              provider.error ?? 'Unknown error occurred.',
              style: const TextStyle(color: MyTheme.textLight, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: provider.refreshArea,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AreaMapProvider provider, String filterMode, List<Household> displayedHouseholds) {
    final total = displayedHouseholds.length;
    final completed = displayedHouseholds.where((h) => h.status == 'completed').length;
    final pending = displayedHouseholds.where((h) => h.status == 'pending').length;
    final highRisk = displayedHouseholds.where((h) => h.status == 'high-risk').length;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    final title = filterMode == 'highRisk'
        ? '$highRisk High-Risk Houses'
        : '${provider.totalPending} pending tasks';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: filterMode == 'highRisk'
              ? [const Color(0xFFB71C1C), const Color(0xFFE53935)]
              : [const Color(0xFF0052D4), const Color(0xFF4364F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (filterMode == 'highRisk' ? const Color(0xFFB71C1C) : const Color(0xFF0052D4)).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filterMode == 'highRisk' ? 'HIGH RISK OVERVIEW' : 'AREA OVERVIEW',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                child: Icon(
                  filterMode == 'highRisk' ? Icons.warning_rounded : Icons.analytics_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini stat row
          Row(
            children: [
              _statChip('$pending Pending', Colors.white.withAlpha(50)),
              const SizedBox(width: 8),
              if (filterMode == 'highRisk')
                _statChip('$highRisk High Risk', Colors.white.withAlpha(50))
              else
                _statChip('$completed Done', Colors.white.withAlpha(50)),
              const SizedBox(width: 8),
              _statChip('$total Total', Colors.white.withAlpha(50)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Progress: $completed / $total', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildLegend(bool isSmallPhone) {
    if (isSmallPhone) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        _legendChip(MyTheme.criticalRed, 'Risk'),
        const SizedBox(width: 8),
        _legendChip(MyTheme.primaryBlue, 'Open'),
        const SizedBox(width: 8),
        _legendChip(Colors.grey[400]!, 'Done'),
        const SizedBox(width: 8),
        _legendChip(Colors.blueGrey[300]!, 'Closed'),
      ],
    );
  }

  Widget _legendChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HOUSE LIST CARD — used in 'all' and 'highRisk' list view
// ─────────────────────────────────────────────────────────
class _HouseListCard extends StatelessWidget {
  final Household household;
  final AreaMapProvider provider;

  const _HouseListCard({required this.household, required this.provider});

  @override
  Widget build(BuildContext context) {
    final h = household;
    final isHighRisk = h.status == 'high-risk';
    final isCompleted = h.status == 'completed';
    final isClosed = h.isClosed || h.status == 'closed';

    final Color statusColor = isClosed
        ? Colors.blueGrey
        : isHighRisk
            ? MyTheme.criticalRed
            : isCompleted
                ? MyTheme.successGreen
                : MyTheme.primaryBlue;

    final String statusLabel = isClosed
        ? 'CLOSED'
        : isHighRisk
            ? 'HIGH RISK'
            : isCompleted
                ? 'DONE'
                : 'PENDING';

    final IconData statusIcon = isClosed
        ? Icons.lock_rounded
        : isHighRisk
            ? Icons.warning_rounded
            : isCompleted
                ? Icons.check_circle_rounded
                : Icons.pending_rounded;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withAlpha(100),
          builder: (context) => HouseholdDetailSheet(household: h, provider: provider),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighRisk ? MyTheme.criticalRed.withAlpha(80) : Colors.grey.withAlpha(30),
            width: isHighRisk ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighRisk
                  ? MyTheme.criticalRed.withAlpha(20)
                  : Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Color accent bar
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            // House icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        h.displayId,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h.headName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: MyTheme.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    h.address,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Task badge + members
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (h.pendingTasksCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHighRisk ? MyTheme.criticalRed : MyTheme.warningOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${h.pendingTasksCount} tasks',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 6),
                if (h.memberCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 3),
                      Text('${h.memberCount}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HouseTile extends StatefulWidget {
  final Household household;
  final AreaMapProvider provider;

  const _HouseTile({required this.household, required this.provider});

  @override
  State<_HouseTile> createState() => _HouseTileState();
}

class _HouseTileState extends State<_HouseTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.household.status == 'high-risk') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.household;
    final isHighRisk = h.status == 'high-risk';
    final isCompleted = h.status == 'completed';
    final isClosed = h.status == 'closed' || h.isClosed == true;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withAlpha(100),
              builder: (context) => HouseholdDetailSheet(
                household: h,
                provider: widget.provider,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: isHighRisk
                  ? [
                      BoxShadow(
                        color: MyTheme.criticalRed.withAlpha(40),
                        blurRadius: _pulseAnimation.value,
                        spreadRadius: _pulseAnimation.value / 6,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight = constraints.maxHeight;
                final maxWidth = constraints.maxWidth;
                
                final iconSize = (maxHeight * 0.28).clamp(24.0, 40.0);
                final badgeSize = (math.min(maxWidth, maxHeight) * 0.2).clamp(16.0, 24.0);
                final roofHeight = (maxHeight * 0.1).clamp(8.0, 14.0);
                final fontSizeBig = (maxHeight * 0.08).clamp(10.0, 13.0);
                final fontSizeSmall = (maxHeight * 0.06).clamp(8.0, 10.0);

                // Closed house color scheme
                final Color roofColor = isClosed
                    ? Colors.blueGrey[300]!
                    : isHighRisk
                        ? MyTheme.criticalRed
                        : isCompleted
                            ? Colors.grey[400]!
                            : MyTheme.primaryBlue;

                final Color iconColor = isClosed
                    ? Colors.blueGrey[300]!
                    : isHighRisk
                        ? MyTheme.criticalRed
                        : isCompleted
                            ? Colors.grey[400]!
                            : MyTheme.primaryBlue;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Roof Accent
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: roofHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: roofColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                    ),
                    // Main House Body
                    Positioned.fill(
                      top: roofHeight * 0.8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.1, vertical: maxHeight * 0.05),
                        decoration: BoxDecoration(
                          color: isClosed
                              ? Colors.grey[100]
                              : isCompleted
                                  ? Colors.grey[100]
                                  : Colors.white,
                          gradient: (isHighRisk == true && isClosed == false)
                              ? LinearGradient(
                                  colors: [MyTheme.criticalRed.withAlpha(50), MyTheme.criticalRed.withAlpha(15)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : null,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          border: Border.all(
                            color: isClosed == true
                                ? Colors.blueGrey[200]!
                                : isHighRisk == true
                                    ? MyTheme.criticalRed.withAlpha(150)
                                    : isCompleted == true
                                        ? Colors.grey[300]!
                                        : MyTheme.primaryBlue.withAlpha(80),
                            width: (isHighRisk == true && isClosed == false) ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                h.displayId,
                                style: TextStyle(
                                  fontSize: fontSizeSmall,
                                  fontWeight: FontWeight.bold,
                                  color: isClosed
                                      ? Colors.blueGrey[300]
                                      : isHighRisk
                                          ? MyTheme.criticalRed
                                          : MyTheme.textLight,
                                ),
                              ),
                            ),
                            const Spacer(flex: 1),
                            Icon(
                              isClosed
                                  ? Icons.lock_rounded
                                  : isCompleted
                                      ? Icons.home_rounded
                                      : Icons.home_outlined,
                              size: iconSize,
                              color: iconColor,
                            ),
                            const Spacer(flex: 1),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                h.headName.split(' ')[0],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: fontSizeBig,
                                  fontWeight: FontWeight.w800,
                                  color: isClosed ? Colors.blueGrey[300] : isCompleted ? Colors.grey[500] : MyTheme.textDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isClosed == true)
                              Text(
                                'CLOSED',
                                style: TextStyle(fontSize: fontSizeSmall * 0.8, fontWeight: FontWeight.w900, color: Colors.blueGrey[300]),
                              ),
                            if (isCompleted == true && isClosed == false)
                              Icon(Icons.check_circle_rounded, size: fontSizeBig, color: MyTheme.successGreen),
                            if (isHighRisk == true && isCompleted == false && isClosed == false)
                              Text(
                                'HIGH RISK',
                                style: TextStyle(fontSize: fontSizeSmall * 0.8, fontWeight: FontWeight.w900, color: MyTheme.criticalRed),
                              ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ),
                    // Task Badge (hidden on closed/completed houses)
                    if (h.pendingTasksCount > 0 && isCompleted == false && isClosed == false)
                      Positioned(
                        top: roofHeight + 4,
                        right: 4,
                        child: Container(
                          width: badgeSize,
                          height: badgeSize,
                          decoration: const BoxDecoration(
                            color: MyTheme.warningOrange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Center(
                            child: FittedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  '${h.pendingTasksCount}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
