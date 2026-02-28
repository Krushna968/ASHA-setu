import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String _selectedTab = 'All Topics';
  String _searchQuery = '';
  
  final List<String> _tabs = ['All Topics', 'Videos', 'Guides', 'Quizzes', 'Health Tips'];

  final List<Map<String, dynamic>> _materials = [
    {
      'title': 'Infant Nutrition',
      'duration': '10 mins',
      'type': 'Videos',
      'image': 'https://images.unsplash.com/photo-1555232333-37b1f42ddef1?q=80&w=400', // Placeholder
      'icon': Icons.play_circle_fill,
    },
    {
      'title': 'First Aid Basics',
      'duration': '15 mins',
      'type': 'Guides',
      'image': 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?q=80&w=400',
      'icon': Icons.medical_services_rounded,
    },
    {
      'title': 'Hygiene Practices',
      'duration': '8 mins',
      'type': 'Health Tips',
      'image': 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400',
      'icon': Icons.clean_hands_rounded,
    },
    {
      'title': 'Vaccination 101',
      'duration': '12 mins',
      'type': 'Guides',
      'image': 'https://images.unsplash.com/photo-1632833232230-0197940733d9?q=80&w=400',
      'icon': Icons.vaccines_rounded,
    },
    {
      'title': 'Pre-natal Yoga',
      'duration': '20 mins',
      'type': 'Videos',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=400',
      'icon': Icons.spa_rounded,
    },
    {
      'title': 'Safe Water Tips',
      'duration': '5 mins',
      'type': 'Health Tips',
      'image': 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?q=80&w=400',
      'icon': Icons.water_drop_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _materials.where((m) {
      final matchesTab = _selectedTab == 'All Topics' || m['type'] == _selectedTab;
      final matchesSearch = m['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildTabBar(),
                _buildFeaturedCard(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    'Learning Modules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyTheme.textDark),
                  ),
                ),
              ],
            ),
          ),
          _filtered.isEmpty 
            ? SliverFillRemaining(child: _buildEmptyState())
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildResourceCard(_filtered[index]),
                    childCount: _filtered.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: MyTheme.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Learning Resources', style: TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark)),
      centerTitle: false,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search topics...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: MyTheme.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MyTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.tune_rounded, color: MyTheme.primaryBlue, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final bool isSelected = _selectedTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedTab = tab);
              },
              backgroundColor: Colors.white,
              selectedColor: MyTheme.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : MyTheme.textLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? MyTheme.primaryBlue : Colors.grey.shade200),
              ),
              showCheckmark: false,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1584362917165-426da84123b1?q=80&w=800'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
          ),
          boxShadow: [
            BoxShadow(
              color: MyTheme.primaryBlue.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Maternal Care Essentials',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Start Learning', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> item) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    item['image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                      child: Center(child: Icon(item['icon'], color: MyTheme.primaryBlue, size: 40)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.file_download_outlined, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'].toString().toUpperCase(),
                  style: const TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MyTheme.textDark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item['duration'],
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text(
            "No resources found",
            style: TextStyle(color: MyTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Try a different topic or search term.", style: TextStyle(color: MyTheme.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}
