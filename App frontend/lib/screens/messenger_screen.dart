import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Messenger Hub',
          style: TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: MyTheme.textDark),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: MyTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: MyTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Messages'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(),
          _buildTasksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: MyTheme.primaryBlue,
        child: Icon(
          _tabController.index == 0 ? Icons.chat_bubble_rounded : Icons.add_task_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // MESSAGES TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildMessagesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildCriticalAlert(),
        const SizedBox(height: 8),
        _buildMessageTile(
          name: 'Dr. Anjali (Medical Officer)',
          message: 'Please review the vaccination list for Ward 4.',
          time: '10:30 AM',
          unreadCount: 2,
          isOnline: true,
          initials: 'AJ',
          avatarColor: Colors.purple.shade400,
        ),
        _buildAudioMessageTile(
          name: 'Rajesh Kumar (Supervisor)',
          time: '9:15 AM',
          duration: '1:45',
          initials: 'RK',
          avatarColor: Colors.teal.shade400,
          isPlaying: false,
        ),
        _buildMessageTile(
          name: 'Healthcare Dept',
          message: 'New guidelines for iron supplement distribution.',
          time: 'Yesterday',
          isSeen: true,
          initials: 'HD',
          avatarColor: Colors.blue.shade400,
        ),
        _buildMessageTile(
          name: 'Sarita Devi',
          message: 'Thank you for the visit yesterday.',
          time: 'Yesterday',
          initials: 'SD',
          avatarColor: Colors.orange.shade400,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search chats or messages...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: MyTheme.primaryBlue, size: 22),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Colors.grey, size: 20),
              onPressed: () {},
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyTheme.criticalRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyTheme.criticalRed.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MyTheme.criticalRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Text(
                '8:45 AM',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Health Dept',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            'Emergency pulse polio drive updated for Ward 4. Please confirm deployment immediately.',
            style: TextStyle(color: MyTheme.textDark, height: 1.4, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.criticalRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text('Acknowledge Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String message,
    required String time,
    int? unreadCount,
    bool isOnline = false,
    bool isSeen = false,
    required String initials,
    required Color avatarColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: avatarColor.withValues(alpha: 0.1),
                    child: Text(
                      initials,
                      style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                        ),
                        Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: unreadCount != null ? MyTheme.textDark : Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: unreadCount != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSeen)
                          const Icon(Icons.done_all_rounded, size: 16, color: MyTheme.primaryBlue),
                        if (unreadCount != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: MyTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMessageTile({
    required String name,
    required String time,
    required String duration,
    required String initials,
    required Color avatarColor,
    required bool isPlaying,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: avatarColor.withValues(alpha: 0.1),
                child: Text(
                  initials,
                  style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.textDark),
                        ),
                        Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: MyTheme.primaryBlue,
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildAudioWaveform(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            duration,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MyTheme.primaryBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioWaveform() {
    return Row(
      children: List.generate(15, (index) {
        return Container(
          width: 3,
          height: (index % 3 == 0 ? 12 : (index % 2 == 0 ? 18 : 10)),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: index < 5 ? MyTheme.primaryBlue : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TASKS TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildTasksTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTaskCard(
          title: 'Newborn Vaccination Follow-up',
          patient: 'Baby of Priya Sharma',
          due: 'Today',
          priority: 'High',
          isCompleted: false,
        ),
        _buildTaskCard(
          title: 'Monthly Nutrition Report',
          patient: 'Village Center',
          due: 'Tomorrow',
          priority: 'Medium',
          isCompleted: false,
        ),
        _buildTaskCard(
          title: 'Update Pregnant Women Registry',
          patient: 'All Wards',
          due: 'Mar 5',
          priority: 'Low',
          isCompleted: false,
        ),
        _buildTaskCard(
          title: 'ANC Checkup Coordination',
          patient: 'Meera Bai',
          due: 'Feb 26',
          priority: 'Medium',
          isCompleted: true,
        ),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String patient,
    required String due,
    required String priority,
    required bool isCompleted,
  }) {
    Color priorityColor;
    switch (priority) {
      case 'High': priorityColor = MyTheme.criticalRed; break;
      case 'Medium': priorityColor = MyTheme.warningOrange; break;
      default: priorityColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: priority == 'High' && !isCompleted
            ? Border(left: BorderSide(color: priorityColor, width: 4))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                unselectedWidgetColor: Colors.grey.shade300,
              ),
              child: Checkbox(
                value: isCompleted,
                activeColor: MyTheme.successGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.grey : MyTheme.textDark,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        due,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
