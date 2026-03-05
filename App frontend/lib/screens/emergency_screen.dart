import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Emergency contact data grouped by category
  final List<Map<String, dynamic>> _categories = [
    {
      'header': '🚑  Ambulance',
      'contacts': [
        {'name': 'National Ambulance', 'number': '108', 'icon': Icons.local_hospital_rounded},
        {'name': 'ASHA Emergency Van', 'number': '102', 'icon': Icons.airport_shuttle_rounded},
      ],
    },
    {
      'header': '🏥  Hospital',
      'contacts': [
        {'name': 'District Hospital', 'number': '02227750000', 'icon': Icons.local_hospital_outlined},
        {'name': 'Apollo Helpline', 'number': '18605005959', 'icon': Icons.medical_services_outlined},
        {'name': 'PHC Contact', 'number': '02228550000', 'icon': Icons.home_outlined},
      ],
    },
    {
      'header': '☎️  Helpline',
      'contacts': [
        {'name': 'NHM Helpline', 'number': '18001801104', 'icon': Icons.support_agent_rounded},
        {'name': 'Childline India', 'number': '1098', 'icon': Icons.child_friendly_rounded},
        {'name': 'Women Helpline', 'number': '1091', 'icon': Icons.diversity_3_rounded},
      ],
    },
    {
      'header': '🏛️  Government',
      'contacts': [
        {'name': 'Police', 'number': '100', 'icon': Icons.local_police_rounded},
        {'name': 'Fire Brigade', 'number': '101', 'icon': Icons.local_fire_department_rounded},
        {'name': 'Disaster Mgmt', 'number': '1078', 'icon': Icons.warning_rounded},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not dial $number. Please call manually.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0505),
              Color(0xFF2D0A0A),
              Color(0xFF1A0505),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────
              _buildHeader(),

              // ── Primary SOS Button ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: FadeIn(
                  duration: const Duration(milliseconds: 600),
                  child: _buildPrimarySOSButton(),
                ),
              ),

              // ── Contacts List ─────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _categories.length,
                  itemBuilder: (context, catIndex) {
                    final cat = _categories[catIndex];
                    final contacts = cat['contacts'] as List<Map<String, dynamic>>;
                    return FadeInUp(
                      delay: Duration(milliseconds: 300 + catIndex * 120),
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                            child: Text(
                              cat['header'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          ...contacts.asMap().entries.map((e) {
                            return FadeInLeft(
                              delay: Duration(milliseconds: 350 + catIndex * 120 + e.key * 60),
                              duration: const Duration(milliseconds: 350),
                              child: _buildContactCard(e.value),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── Header ──────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              const Expanded(
                child: Text(
                  'EMERGENCY CONTACTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any number to call immediately',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Primary SOS Pulsing Button ──────────────────────────
  Widget _buildPrimarySOSButton() {
    return Column(
      children: [
        // Outer pulsing ring + button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _callNumber('112'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                Container(
                  width: 178,
                  height: 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.25),
                  ),
                ),
                // Middle ring
                Container(
                  width: 158,
                  height: 158,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.40),
                  ),
                ),
                // Core button
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                      center: Alignment(-0.3, -0.3),
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0xAAE53935), blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.phone_rounded, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text(
                        '112',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // TAP TO CALL label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            'TAP TO CALL — AMBULANCE / EMERGENCY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────── Contact Card ────────────────────────────────────
  Widget _buildContactCard(Map<String, dynamic> contact) {
    return GestureDetector(
      onTap: () => _callNumber(contact['number'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F1C1C), Color(0xFFB71C1C)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.red.withValues(alpha: 0.20), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Phone icon with circle background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(contact['icon'] as IconData, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            // Contact info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact['number'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // Call icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
