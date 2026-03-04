import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/area_map_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/household_detail_sheet.dart';
import 'dart:math' as math;

class AreaTaskMapScreen extends StatefulWidget {
  const AreaTaskMapScreen({super.key});

  @override
  State<AreaTaskMapScreen> createState() => _AreaTaskMapScreenState();
}

class _AreaTaskMapScreenState extends State<AreaTaskMapScreen> {
  @override
  void initState() {
    super.initState();
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
        final width = MediaQuery.of(context).size.width;
        final isTablet = width > 600;
        final isSmallPhone = width < 360;
        
        // Use provider area grid columns if available, else default
        final int areaGridCols = provider.area?.gridColumns ?? 0;
        int gridColumns = 4;
        if (isTablet) {
          gridColumns = (areaGridCols > 0) ? areaGridCols : 6;
        } else if (isSmallPhone) {
          gridColumns = 3;
        }

        final double childAspectRatio = isTablet ? 1.1 : 0.85;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: MyTheme.textDark,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Area Household Map',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (provider.isDemoMode)
                  const Text(
                    'Viewing Demo Data',
                    style: TextStyle(
                      fontSize: 10, 
                      color: MyTheme.warningOrange, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
              ],
            ),
            actions: [
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
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildSummaryCard(provider),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Household Map',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    color: MyTheme.textDark
                                  ),
                                ),
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
                                return _HouseTile(
                                  household: provider.households[index],
                                  provider: provider,
                                );
                              },
                              childCount: provider.households.length,
                            ),
                          ),
                        ),
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

  Widget _buildSummaryCard(AreaMapProvider provider) {
    final pendingCount = provider.totalPending;
    final progress = provider.progressValue;
    final total = provider.households.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052D4).withAlpha(60),
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
                    const Text(
                      'AREA PERFORMANCE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        pendingCount == 0
                            ? 'All tasks complete!'
                            : '$pendingCount pending tasks',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Progress: ${provider.totalCompleted} / $total',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Fix Part 3: Global Pill style progress bar
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
