import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentNavIndex = 2;

  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I reset my password?',
      'a': 'Go to the Login screen and tap "Forgot Password". Enter your registered phone number to receive an OTP and reset your password.',
      'icon': Icons.lock_reset_outlined,
    },
    {
      'q': 'Where can I find my reports?',
      'a': 'Your reports are available in the Dashboard under "Daily Priority" cards. You can also view monthly summaries in the Calendar screen.',
      'icon': Icons.bar_chart_outlined,
    },
    {
      'q': 'How to update my contact info?',
      'a': 'Go to your Worker Profile (bottom nav → Profile), then tap the edit icon on the avatar section to update your details.',
      'icon': Icons.manage_accounts_outlined,
    },
    {
      'q': 'How do I sync data when offline?',
      'a': 'Tap "Sync All Data" on the Dashboard. Data is cached locally and will sync automatically when network is restored.',
      'icon': Icons.sync_outlined,
    },
    {
      'q': 'How to request medicine refill?',
      'a': 'Open the Inventory Status screen from the Dashboard quick actions and tap "Request Refill" next to any listed medicine.',
      'icon': Icons.medication_outlined,
    },
    {
      'q': 'How do I log an individual visit?',
      'a': 'Navigate to Individuals, tap the name, then tap "Log Visit". Fill in the vitals and notes, then save.',
      'icon': Icons.assignment_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) =>
      faq['q'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
      faq['a'].toString().toLowerCase().contains(_searchQuery.toLowerCase()),
    ).toList();
  }

  final Set<int> _expandedIndices = {};

  void _toggleFaq(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: MyTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 20),

            // ── Urgent Help ──────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 400),
              child: _buildSectionLabel('Need Urgent Help?'),
            ),
            const SizedBox(height: 12),

            FadeInLeft(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 400),
              child: _buildUrgentCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.headset_mic_outlined,
                title: 'Call Supervisor',
                subtitle: 'Available 24/7 for escalation',
                onTap: () => _showSnack('Calling supervisor…'),
              ),
            ),
            const SizedBox(height: 10),

            FadeInLeft(
              delay: const Duration(milliseconds: 220),
              duration: const Duration(milliseconds: 400),
              child: _buildUrgentCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDC3545), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.emergency_outlined,
                title: 'Emergency Helpline',
                subtitle: 'Immediate safety assistance',
                onTap: () => Navigator.pushNamed(context, '/emergency'),
              ),
            ),
            const SizedBox(height: 10),

            FadeInLeft(
              delay: const Duration(milliseconds: 290),
              duration: const Duration(milliseconds: 400),
              child: _buildTutorialCard(),
            ),
            const SizedBox(height: 24),

            // ── Browse Categories ─────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 350),
              duration: const Duration(milliseconds: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionLabel('Browse Categories'),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All', style: TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            FadeInUp(
              delay: const Duration(milliseconds: 400),
              duration: const Duration(milliseconds: 400),
              child: _buildCategoryRow(),
            ),
            const SizedBox(height: 24),

            // ── FAQs ──────────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 450),
              duration: const Duration(milliseconds: 400),
              child: _buildSectionLabel('Common Questions'),
            ),
            const SizedBox(height: 12),

            ..._buildFaqItems(),
            const SizedBox(height: 24),

            // ── Contact Support ───────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              duration: const Duration(milliseconds: 500),
              child: _buildContactCard(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MyTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
          setState(() => _currentNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: MyTheme.primaryBlue,
              child: Icon(Icons.help, color: Colors.white, size: 18),
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  // ─────────────────────────── Search Bar ───────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Search FAQs and help topics…',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: MyTheme.primaryBlue),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  // ─────────────────────────── Section Label ────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: MyTheme.textDark),
    );
  }

  // ─────────────────────────── Urgent Cards ────────────────────────────────
  Widget _buildUrgentCard({
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── Tutorial Card ────────────────────────────────
  Widget _buildTutorialCard() {
    return GestureDetector(
      onTap: () => _showSnack('Opening tutorial…'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF0F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_fill, color: MyTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Watch App Tutorial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark)),
                  Text('Learn how to use all features', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── Category Row ────────────────────────────────
  Widget _buildCategoryRow() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.person_outline, 'label': 'Account', 'bg': const Color(0xFFEEF2FF), 'color': MyTheme.primaryBlue},
      {'icon': Icons.receipt_long_outlined, 'label': 'Reports', 'bg': const Color(0xFFFFF3E0), 'color': Colors.orange},
      {'icon': Icons.shield_outlined, 'label': 'Security', 'bg': const Color(0xFFE8F5E9), 'color': Colors.green},
      {'icon': Icons.build_outlined, 'label': 'Technical', 'bg': const Color(0xFFF3E5F5), 'color': Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => _showSnack('Opening ${cat['label']} help…'),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cat['bg'] as Color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            Text(cat['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: MyTheme.textDark)),
          ],
        );
      }).toList(),
    );
  }

  // ─────────────────────────── FAQ Items ───────────────────────────────────
  List<Widget> _buildFaqItems() {
    final faqs = _filteredFaqs;
    if (faqs.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No results found for "$_searchQuery"',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              ],
            ),
          ),
        ),
      ];
    }

    return faqs.asMap().entries.map((entry) {
      final index = entry.key;
      final faq = entry.value;
      final bool expanded = _expandedIndices.contains(index);

      return FadeInUp(
        delay: Duration(milliseconds: 500 + index * 80),
        duration: const Duration(milliseconds: 400),
        child: GestureDetector(
          onTap: () => _toggleFaq(index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: expanded
                    ? [const Color(0xFFEEF2FF), const Color(0xFFE8EFFE)]
                    : [Colors.white, const Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: expanded ? MyTheme.primaryBlue.withValues(alpha: 0.35) : Colors.grey.shade200,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: expanded ? MyTheme.primaryBlue.withValues(alpha: 0.12) : const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          faq['icon'] as IconData,
                          color: expanded ? MyTheme.primaryBlue : Colors.grey.shade500,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Question
                      Expanded(
                        child: Text(
                          faq['q'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: expanded ? MyTheme.primaryBlue : MyTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Arrow with rotation animation
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: expanded ? MyTheme.primaryBlue : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                // Answer (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: MyTheme.primaryBlue.withValues(alpha: 0.15), height: 1),
                        const SizedBox(height: 12),
                        Text(
                          faq['a'] as String,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ─────────────────────────── Contact Card ────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0056D2), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: MyTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Still need help?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'Our support team is available 24/7',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Phone Number
          Text(
            '1800-XXX-XXXX',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Free helpline — Toll Free',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
          const SizedBox(height: 20),
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSnack('Calling support…'),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: MyTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSnack('Opening email client…'),
                  icon: const Icon(Icons.email_outlined, size: 18, color: Colors.white),
                  label: const Text('Email Us', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
