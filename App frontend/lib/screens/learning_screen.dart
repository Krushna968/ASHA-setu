import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Nutrition',
    'Maternal Health',
    'Infant Care',
    'Immunization',
    'General',
  ];

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Infant Nutrition',
      'description': 'Essential nutrients for healthy baby growth in the first year of life.',
      'category': 'Nutrition',
      'duration': '10 min',
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFFFF7043),
      'status': 'inProgress',
      'progress': 0.60,
    },
    {
      'title': 'Antenatal Care Guide',
      'description': 'Step-by-step guidance for monitoring maternal health during pregnancy.',
      'category': 'Maternal Health',
      'duration': '18 min',
      'icon': Icons.pregnant_woman_rounded,
      'color': const Color(0xFF7C4DFF),
      'status': 'completed',
      'progress': 1.0,
    },
    {
      'title': 'Safe Breastfeeding',
      'description': 'Best practices for breastfeeding and infant nutrition support.',
      'category': 'Infant Care',
      'duration': '12 min',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFE91E8C),
      'status': 'notStarted',
      'progress': 0.0,
    },
    {
      'title': 'Immunization Schedule',
      'description': 'Complete vaccination calendar for children aged 0–5 years.',
      'category': 'Immunization',
      'duration': '15 min',
      'icon': Icons.vaccines_rounded,
      'color': const Color(0xFF00BCD4),
      'status': 'inProgress',
      'progress': 0.35,
    },
    {
      'title': 'Maternal Diet & Wellness',
      'description': 'Nutrition recommendations and wellness tips for expectant mothers.',
      'category': 'Nutrition',
      'duration': '14 min',
      'icon': Icons.restaurant_menu_rounded,
      'color': const Color(0xFF4CAF50),
      'status': 'notStarted',
      'progress': 0.0,
    },
    {
      'title': 'Postpartum Care',
      'description': 'How to support mothers during the recovery period after delivery.',
      'category': 'Maternal Health',
      'duration': '20 min',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFFFF9800),
      'status': 'notStarted',
      'progress': 0.0,
    },
    {
      'title': 'First Aid Basics',
      'description': 'Emergency first aid techniques every ASHA worker should know.',
      'category': 'General',
      'duration': '16 min',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFF44336),
      'status': 'completed',
      'progress': 1.0,
    },
    {
      'title': 'Hygiene & Sanitation',
      'description': 'Promoting cleanliness and safe water practices in rural communities.',
      'category': 'General',
      'duration': '8 min',
      'icon': Icons.clean_hands_rounded,
      'color': const Color(0xFF2196F3),
      'status': 'notStarted',
      'progress': 0.0,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _modules.where((m) {
      final matchesCategory = _selectedCategory == 'All' || m['category'] == _selectedCategory;
      final matchesSearch = m['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Map<String, dynamic>? get _continueModule {
    try {
      return _modules.firstWhere((m) => m['status'] == 'inProgress');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final continueMod = _continueModule;

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: MyTheme.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Learning Hub',
              style: TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark, fontSize: 20),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  icon: const Icon(Icons.emoji_events_outlined, color: MyTheme.primaryBlue),
                  onPressed: () {},
                  tooltip: 'My Progress',
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──────────────────────────────
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search modules…',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: MyTheme.primaryBlue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Category Chips ──────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 80),
                  duration: const Duration(milliseconds: 400),
                  child: SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      itemCount: _categories.length,
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final bool sel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: sel,
                            onSelected: (v) { if (v) setState(() => _selectedCategory = cat); },
                            backgroundColor: Colors.white,
                            selectedColor: MyTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: sel ? Colors.white : MyTheme.textLight,
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: sel ? MyTheme.primaryBlue : Colors.grey.shade200),
                            ),
                            showCheckmark: false,
                            elevation: sel ? 2 : 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Continue Learning Card ──────────────────
                if (continueMod != null)
                  FadeInDown(
                    delay: const Duration(milliseconds: 160),
                    duration: const Duration(milliseconds: 450),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _buildContinueLearningCard(continueMod),
                    ),
                  ),

                // ── Section Title ────────────────────────────
                FadeInDown(
                  delay: const Duration(milliseconds: 240),
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategory == 'All' ? 'All Modules' : '$_selectedCategory Modules',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark),
                        ),
                        Text('${filtered.length} available',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Module List ────────────────────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => FadeInUp(
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 400),
                        child: _buildModuleCard(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ─────────────────── Continue Learning Card ───────────────────────────────
  Widget _buildContinueLearningCard(Map<String, dynamic> mod) {
    final double progress = (mod['progress'] as double);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MyTheme.primaryBlue, const Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: MyTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('CONTINUE LEARNING',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(mod['icon'] as IconData, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mod['title'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text('${mod['category']} • ${mod['duration']}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MyTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue'),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Module Card ─────────────────────────────────
  Widget _buildModuleCard(Map<String, dynamic> mod) {
    final String status = mod['status'] as String;
    final double progress = (mod['progress'] as double);
    final Color iconColor = mod['color'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail area
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(mod['icon'] as IconData, color: iconColor, size: 32),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                Text(
                  (mod['category'] as String).toUpperCase(),
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  mod['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  mod['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 8),
                // Duration + Progress indicator row
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(mod['duration'] as String,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    const Spacer(),
                    _buildStatusBadge(status, progress, iconColor),
                  ],
                ),
                // Progress bar (for inProgress modules)
                if (status == 'inProgress') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, double progress, Color color) {
    if (status == 'completed') {
      return Row(
        children: const [
          Icon(Icons.check_circle_rounded, color: Color(0xFF28A745), size: 16),
          SizedBox(width: 4),
          Text('Done', style: TextStyle(color: Color(0xFF28A745), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      );
    } else if (status == 'inProgress') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('In Progress', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Text('Start', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }
  }

  // ─────────────────────────── Empty State ─────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text('No modules found', style: TextStyle(color: MyTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Try a different category or search term.', style: TextStyle(color: MyTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}
