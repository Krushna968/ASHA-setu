import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessengerScreen extends StatelessWidget {
  const MessengerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: MyTheme.backgroundWhite,
        appBar: AppBar(
          title: const Text('ASHA Messenger'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
          bottom: const TabBar(
            labelColor: MyTheme.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: MyTheme.primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'All Messages'),
              Tab(text: 'Supervisor'),
              Tab(text: 'Health Dept'),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          children: [
            _buildCriticalMessage(context),
            _buildAudioMessage(
              context,
              sender: 'Supervisor (Aruna J.)',
              time: 'Yesterday',
              avatarColor: Colors.teal,
              duration: '1:24',
              text: 'New prenatal record templates are now available. Please listen to instructions.',
              isPlaying: false,
            ),
            _buildStandardMessage(
              context,
              sender: 'Supervisor',
              time: 'Monday',
              avatarColor: Colors.orange,
              text: 'Weekly review meeting scheduled for Friday at the Community Center. 10 AM sharp.\n\n✓ Seen',
            ),
             _buildAudioMessage(
              context,
              sender: 'Health Dept',
              time: 'Aug 12',
              avatarColor: Colors.blue,
              duration: '',
              text: 'Guideline update for seasonal fever monitoring.',
              isPlaying: true, // Visual play state
              isBlueCard: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalMessage(BuildContext context) {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal, // Placeholder image
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Health Dept',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '8:45 AM',
                          style: TextStyle(color: MyTheme.criticalRed, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'CRITICAL INSTRUCTION:',
                      style: TextStyle(
                        color: MyTheme.criticalRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Emergency pulse polio drive updated for Ward 4. Please confirm deployment immediately.',
                      style: TextStyle(color: MyTheme.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: MyTheme.criticalRed,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: const Text(
                   'URGENT',
                   style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: ElevatedButton(
                   onPressed: () {},
                   style: ElevatedButton.styleFrom(
                     backgroundColor: MyTheme.criticalRed,
                     padding: const EdgeInsets.symmetric(vertical: 12),
                   ),
                   child: const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                       SizedBox(width: 8),
                       Text('Acknowledge Receipt'),
                     ],
                   ),
                 ),
               )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStandardMessage(BuildContext context, {
    required String sender,
    required String time,
    required Color avatarColor,
    required String text,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
       margin: const EdgeInsets.only(bottom: 2), // Separator
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(color: Color(0xFF424242), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage(BuildContext context, {
    required String sender,
    required String time,
    required Color avatarColor,
    required String duration,
    required String text,
    required bool isPlaying,
    bool isBlueCard = false,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
       margin: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(color: Color(0xFF424242)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBlueCard ? Colors.blue.shade50 : const Color(0xFFFFF8E1), // Amber[50] replacement
                    borderRadius: BorderRadius.circular(24),
                     border: Border.all(color: isBlueCard ? Colors.blue.shade100 : Colors.amber.shade100),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isPlaying ? MyTheme.primaryBlue : Colors.orange,
                        radius: 20,
                        child: Icon(
                          isPlaying ? Icons.play_arrow : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: isPlaying ? 0.3 : 0.0,
                            child: Container(
                              color: isPlaying ? MyTheme.primaryBlue : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                       const SizedBox(width: 12),
                       if (duration.isNotEmpty)
                        Text(
                          duration,
                          style: TextStyle(
                            color: isPlaying ? MyTheme.primaryBlue : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                       else
                         const Icon(Icons.chat_bubble, color: MyTheme.primaryBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
