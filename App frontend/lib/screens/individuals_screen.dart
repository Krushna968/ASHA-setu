import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'add_individual_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../l10n/app_localizations.dart';

class IndividualsScreen extends StatefulWidget {
  const IndividualsScreen({super.key});

  @override
  State<IndividualsScreen> createState() => _IndividualsScreenState();
}

class _IndividualsScreenState extends State<IndividualsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<CategoryTab> _getLocalizedCategories() {
    final l10n = AppLocalizations.of(context)!;
    return [
      CategoryTab('All', Icons.people_rounded, MyTheme.primaryBlue, label: l10n.categoryAll),
      CategoryTab('ANC', Icons.pregnant_woman_rounded, Colors.purple),
      CategoryTab('PNC', Icons.child_friendly_rounded, Colors.pink),
      CategoryTab('Infants', Icons.child_care_rounded, Colors.orange),
      CategoryTab('General', Icons.person_rounded, Colors.teal, label: l10n.categoryGeneral),
    ];
  }

  @override
  void initState() {
    super.initState();
    // Categories depend on context for localization, so we don't init them here
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).fetchIndividuals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchIndividuals() async {
    await Provider.of<AppStateProvider>(context, listen: false).fetchIndividuals();
  }

  List<dynamic> _filterIndividuals(String category, List<dynamic> allIndividuals) {
    List<dynamic> filtered =
        category == 'All' ? allIndividuals : allIndividuals.where((p) => p['category'] == category).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final address = (p['address'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || address.contains(query);
      }).toList();
    }

    return filtered;
  }

  Map<String, int> _getCategoryCounts(List<dynamic> allIndividuals) {
    final counts = <String, int>{'All': allIndividuals.length};
    for (final p in allIndividuals) {
      final cat = p['category'] ?? 'General';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final _allIndividuals = provider.individuals;
    final _isLoading = provider.isLoading;
    final _errorMsg = provider.error;

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(_isLoading, _allIndividuals.length),
            _buildSearchBar(),
            _buildCategoryTabs(_allIndividuals, _isLoading),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: MyTheme.primaryBlue),
                    )
                  : _errorMsg != null
                      ? _buildErrorState(_errorMsg)
                      : TabBarView(
                          controller: _tabController,
                          children: _getLocalizedCategories().map((cat) {
                            return _buildIndividualList(_filterIndividuals(cat.name, _allIndividuals));
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MyTheme.primaryBlue,
        elevation: 6,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.addIndividual,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddIndividualScreen()),
          );
          if (result == true) {
            _fetchIndividuals();
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(bool isLoading, int totalIndividuals) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.directoryTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MyTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLoading
                    ? AppLocalizations.of(context)!.loading
                    : AppLocalizations.of(context)!.registeredCount(totalIndividuals),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh button
          Container(
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.sync_rounded, color: MyTheme.primaryBlue, size: 22),
              onPressed: _fetchIndividuals,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.searchHint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CATEGORY TABS
  // ─────────────────────────────────────────────────────────
  Widget _buildCategoryTabs(List<dynamic> allIndividuals, bool isLoading) {
    final counts = _getCategoryCounts(allIndividuals);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: MyTheme.primaryBlue,
        unselectedLabelColor: Colors.grey[500],
        indicatorColor: MyTheme.primaryBlue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: _getLocalizedCategories().map((cat) {
          final count = counts[cat.name] ?? 0;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 16),
                const SizedBox(width: 6),
                Text(cat.label ?? cat.name),
                if (!isLoading) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────────────────
  Widget _buildErrorState(String errorMsg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MyTheme.criticalRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: MyTheme.criticalRed),
            ),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchIndividuals,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // INDIVIDUAL LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildIndividualList(List<dynamic> individuals) {
    if (individuals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? AppLocalizations.of(context)!.noMatch(_searchQuery)
                  : AppLocalizations.of(context)!.noIndividualsInCategory,
              style: TextStyle(color: Colors.grey[400], fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchIndividuals,
      color: MyTheme.primaryBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        itemCount: individuals.length,
        itemBuilder: (context, index) {
          final individual = individuals[index];
          return _buildIndividualCard(individual, index);
        },
      ),
    );
  }

  Widget _buildIndividualCard(Map<String, dynamic> individual, int index) {
    final String name = individual['name'] ?? AppLocalizations.of(context)!.unknown;
    final int age = individual['age'] ?? 0;
    final String address = individual['address'] ?? AppLocalizations.of(context)!.unknownAddress;
    final String category = individual['category'] ?? AppLocalizations.of(context)!.categoryGeneral;
    final List visits = individual['visitHistory'] ?? [];
    final String? lastVisit = visits.isNotEmpty ? visits[0]['visitDate'] : null;

    // Generate initials
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final catColor = _getCategoryColor(category);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.detailsComingSoon)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: MyTheme.textDark,
                                ),
                              ),
                            ),
                            // Category badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: catColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cake_rounded, size: 13, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.ageLabel(age),
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on_rounded, size: 13, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ),
                          ],
                        ),
                        if (lastVisit != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: MyTheme.successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                               Text(
                                AppLocalizations.of(context)!.lastVisit(_formatDate(lastVisit)),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      final l10n = AppLocalizations.of(context)!;

      if (diff.inDays == 0) return l10n.today;
      if (diff.inDays == 1) return l10n.yesterday;
      if (diff.inDays < 7) return '${diff.inDays} ${l10n.daysAgo}';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─────────────────────────────────────────────────────────
// HELPER DATA CLASS
// ─────────────────────────────────────────────────────────
class CategoryTab {
  final String name;
  final IconData icon;
  final Color color;
  final String? label;

  CategoryTab(this.name, this.icon, this.color, {this.label});
}
