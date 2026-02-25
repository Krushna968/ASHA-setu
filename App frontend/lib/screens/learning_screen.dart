import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _selectedTab = 'All';
  int _currentNavIndex = 1;

  final List<String> _tabs = ['All', 'Videos', 'Guides', 'Health Tips'];

  final List<Map<String, dynamic>> _materials = [
    {
      'title': 'Maternal Health Videos',
      'subtitle': 'Essential wellness tips for expectant and new...',
      'badge': 'Video Series',
      'badgeColor': Color(0xFF0056D2),
      'type': 'Videos',
      'progress': 0.85,
      'isOffline': true,
      'icon': Icons.pregnant_woman,
      'gradientColors': [Color(0xFFFFB347), Color(0xFFFF6B81)],
      'overlayIcon': Icons.play_circle_fill,
      'overlayColor': Colors.white,
    },
    {
      'title': 'Infant Care Guides',
      'subtitle': '12 comprehensive modules',
      'badge': null,
      'type': 'Guides',
      'progress': null,
      'isOffline': false,
      'icon': Icons.child_care,
      'gradientColors': [Color(0xFF43CEA2), Color(0xFF185A9D)],
      'overlayIcon': Icons.menu_book,
      'overlayColor': Colors.white,
    },
    {
      'title': 'COVID-19 Awareness',
      'subtitle': 'Latest safety protocols',
      'badge': null,
      'type': 'Health Tips',
      'progress': null,
      'isOffline': false,
      'icon': Icons.health_and_safety,
      'gradientColors': [Color(0xFF606C88), Color(0xFF3F4C6B)],
      'overlayIcon': Icons.info_outline,
      'overlayColor': Colors.white,
    },
    {
      'title': 'Healthy Nutrition',
      'subtitle': 'Meal plans & vitamins',
      'badge': null,
      'type': 'Health Tips',
      'progress': null,
      'isOffline': false,
      'icon': Icons.restaurant,
      'gradientColors': [Color(0xFF96D9A0), Color(0xFF6BAE75)],
      'overlayIcon': Icons.restaurant_menu,
      'overlayColor': Colors.white,
    },
    {
      'title': 'First Aid Basics',
      'subtitle': 'Quick action guide',
      'badge': null,
      'type': 'Guides',
      'progress': null,
      'isOffline': false,
      'icon': Icons.medical_services,
      'gradientColors': [Color(0xFFDA4453), Color(0xFF89216B)],
      'overlayIcon': Icons.add_circle_outline,
      'overlayColor': Colors.white,
    },
    {
      'title': 'Immunization Schedule',
      'subtitle': 'Vaccine timeline for children',
      'badge': 'New',
      'badgeColor': Color(0xFF28A745),
      'type': 'Guides',
      'progress': null,
      'isOffline': false,
      'icon': Icons.vaccines,
      'gradientColors': [Color(0xFF4776E6), Color(0xFF8E54E9)],
      'overlayIcon': Icons.calendar_month,
      'overlayColor': Colors.white,
    },
    {
      'title': 'Breastfeeding Tips',
      'subtitle': 'Support for new mothers',
      'badge': null,
      'type': 'Videos',
      'progress': null,
      'isOffline': false,
      'icon': Icons.child_friendly,
      'gradientColors': [Color(0xFFFFE1A8), Color(0xFFFFB347)],
      'overlayIcon': Icons.play_arrow,
      'overlayColor': Color(0xFF0056D2),
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 'All') return _materials;
    return _materials.where((m) => m['type'] == _selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Learning Materials',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: MyTheme.textDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: MyTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _buildCard(_filtered[i]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final bool selected = _selectedTab == tab;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? MyTheme.primaryBlue : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tab,
                  style: TextStyle(
                    color: selected ? Colors.white : MyTheme.textDark,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final List<Color> gradients = item['gradientColors'] as List<Color>;
    final bool hasProgress = item['progress'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Stack(
            children: [
              Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradients,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    item['icon'] as IconData,
                    size: 72,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              // Offline badge
              if (item['isOffline'] == true)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download_done, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('OFFLINE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              // Media type icon bottom-right
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['overlayIcon'] as IconData,
                    color: item['overlayColor'] as Color,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Info area
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: MyTheme.textDark,
                        ),
                      ),
                    ),
                    if (item['badge'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (item['badgeColor'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['badge'],
                          style: TextStyle(
                            color: item['badgeColor'] as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['subtitle'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (hasProgress) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item['progress'] as double,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: const AlwaysStoppedAnimation<Color>(MyTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${((item['progress'] as double) * 100).round()}%',
                      style: TextStyle(fontSize: 11, color: MyTheme.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: MyTheme.primaryBlue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: _currentNavIndex,
      onTap: (index) {
        if (index == 0) Navigator.pop(context);
        setState(() => _currentNavIndex = index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Learning'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Resources'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
