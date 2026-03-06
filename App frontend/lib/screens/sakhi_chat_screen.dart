import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class SakhiChatScreen extends StatefulWidget {
  const SakhiChatScreen({super.key});

  @override
  State<SakhiChatScreen> createState() => _SakhiChatScreenState();
}

class _SakhiChatScreenState extends State<SakhiChatScreen> {
  bool _isLoadingAi = true;
  List<dynamic> _aiItinerary = [];

  @override
  void initState() {
    super.initState();
    _fetchItinerary();
  }

  Future<void> _fetchItinerary() async {
    try {
      final itinerary = await ApiService.getAiItinerary();
      if (mounted) {
        setState(() {
          _aiItinerary = itinerary;
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch AI Itinerary: $e");
      if (mounted) {
        setState(() {
          _isLoadingAi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyTheme.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/SakhiAI.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SakhiAI', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Text(
                'AI Smart Schedule',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
          onPressed: () {
            setState(() => _isLoadingAi = true);
            _fetchItinerary();
          },
          tooltip: 'Refresh Schedule',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingAi) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Analyzing patient risk and tasks...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_aiItinerary.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: MyTheme.successGreen, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Your schedule is clear!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "SakhiAI found no immediate high-risk patients or pending tasks today.\nGreat job!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _aiItinerary.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: MyTheme.primaryBlue, size: 24),
                const SizedBox(width: 10),
                const Text(
                  "Today's Priority List",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textDark,
                  ),
                ),
              ],
            ),
          );
        }

        final item = _aiItinerary[index - 1];
        final type = item['type'] ?? 'UNKNOWN';
        
        // Define styling based on priority/type
        Color iconColor = MyTheme.primaryBlue;
        Color bgColor = iconColor.withOpacity(0.1);
        IconData iconData = Icons.assignment_rounded;
        
        if (type == 'FOLLOW_UP_LOCKED') {
          iconColor = MyTheme.warningOrange;
          bgColor = iconColor.withOpacity(0.1);
          iconData = Icons.lock_rounded;
        } else if (type == 'PATIENT_VISIT') {
          iconColor = MyTheme.criticalRed;
          bgColor = iconColor.withOpacity(0.1);
          iconData = Icons.favorite_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['displayName'] ?? 'Pending Item',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: MyTheme.textDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#$index',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['reasoning'] ?? 'Requires your attention today.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
