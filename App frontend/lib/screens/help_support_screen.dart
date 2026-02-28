import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<String> _expandedQuestions = [];
  int _currentNavIndex = 2;

  final List<Map<String, String>> _faqs = [
    {'q': 'How do I reset my password?', 'a': 'Go to the Login screen and tap "Forgot Password". Enter your registered phone number to receive an OTP and reset your password.'},
    {'q': 'Where can I find my reports?', 'a': 'Your reports are available in the Dashboard under "Daily Priority" cards. You can also view monthly summaries in the Calendar screen.'},
    {'q': 'How to update my contact info?', 'a': 'Go to your Worker Profile (bottom nav → Profile), then tap the edit icon on the avatar section to update your details.'},
    {'q': 'How do I sync data when offline?', 'a': 'Tap "Sync All Data" on the Dashboard. Data is cached locally and will sync automatically when network is restored.'},
    {'q': 'How to request medicine refill?', 'a': 'Open the Inventory Status screen from the Dashboard quick actions and tap "Request Refill" next to any listed medicine.'},
  ];

  void _toggleQuestion(String q) {
    setState(() {
      if (_expandedQuestions.contains(q)) {
        _expandedQuestions.remove(q);
      } else {
        _expandedQuestions.add(q);
      }
    });
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionLabel('Need Urgent Help?'),
            const SizedBox(height: 12),
            _buildUrgentCard(
              color: MyTheme.primaryBlue,
              icon: Icons.headset_mic_outlined,
              title: 'Call Supervisor',
              subtitle: 'Available 24/7 for escalation',
              onTap: () => _showSnack('Calling supervisor…'),
            ),
            const SizedBox(height: 10),
            _buildUrgentCard(
              color: MyTheme.criticalRed,
              icon: Icons.add,
              title: 'Emergency Helpline',
              subtitle: 'Immediate safety assistance',
              onTap: () => Navigator.pushNamed(context, '/emergency'),
            ),
            const SizedBox(height: 10),
            _buildTutorialCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel('Browse Categories'),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCategoryRow(),
            const SizedBox(height: 24),
            _buildSectionLabel('Common Questions'),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _buildFaqItem(faq)),
            const SizedBox(height: 24),
            _buildContactCard(),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: MyTheme.textDark),
    );
  }

  Widget _buildUrgentCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
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

  Widget _buildTutorialCard() {
    return GestureDetector(
      onTap: () => _showSnack('Opening tutorial…'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_circle_fill, color: MyTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Watch App Tutorial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark)),
                  Text('Learn how to use features', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: Colors.grey.shade500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.person_outline, 'label': 'Account', 'bg': const Color(0xFFEEF2FF), 'color': MyTheme.primaryBlue},
      {'icon': Icons.receipt_long_outlined, 'label': 'Billing', 'bg': const Color(0xFFFFF3E0), 'color': Colors.orange},
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
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: cat['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
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

  Widget _buildFaqItem(Map<String, String> faq) {
    final bool expanded = _expandedQuestions.contains(faq['q']);
    return GestureDetector(
      onTap: () => _toggleQuestion(faq['q']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: expanded ? MyTheme.primaryBlue.withValues(alpha: 0.3) : Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['q']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: expanded ? MyTheme.primaryBlue : MyTheme.textDark,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(faq['a']!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Text('Still need help with something else?', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.email_outlined,
                  label: 'Email Us',
                  onTap: () => _showSnack('Opening email client…'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Live Chat',
                  onTap: () => _showSnack('Starting live chat…'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
