import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/task_service.dart';
import 'package:intl/intl.dart';

class MessengerScreen extends StatefulWidget {
  const MessengerScreen({super.key});

  @override
  State<MessengerScreen> createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Mock chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Dr. Sharma',
      'lastMsg': 'The patient in Ward 4 is stable now.',
      'time': '10:30 AM',
      'unread': 2,
      'isDoctor': true,
      'avatar': 'https://i.pravatar.cc/150?u=sharma'
    },
    {
      'name': 'ANM Sunita',
      'lastMsg': 'Asha, have you updated the survey data?',
      'time': '9:45 AM',
      'unread': 0,
      'isDoctor': false,
      'avatar': 'https://i.pravatar.cc/150?u=sunita'
    },
    {
      'name': 'Rajesh (Supervisor)',
      'lastMsg': 'Meeting tomorrow at 9 AM at PHC.',
      'time': 'Yesterday',
      'unread': 0,
      'isDoctor': false,
      'avatar': 'https://i.pravatar.cc/150?u=rajesh'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatTab(),
                  _buildTaskTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: MyTheme.primaryBlue,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Messenger Hub',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MyTheme.textDark),
              ),
              const Spacer(),
              _buildIconButton(Icons.search_rounded, () {}),
              const SizedBox(width: 8),
              _buildIconButton(Icons.more_vert_rounded, () {}),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.grey[600], size: 22),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
          hintText: 'Search people or tasks...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: MyTheme.primaryBlue,
        unselectedLabelColor: Colors.grey[400],
        indicatorColor: MyTheme.primaryBlue,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: [
          const Tab(text: 'Messages'),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tasks'),
                const SizedBox(width: 6),
                ListenableBuilder(
                  listenable: TaskService(),
                  builder: (context, _) {
                    int pending = TaskService().allTasks.where((t) => !t.isCompleted).length;
                    if (pending == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: MyTheme.primaryBlue, shape: BoxShape.circle),
                      child: Text('$pending', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CHATS TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildChatTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _chats.length,
      itemBuilder: (context, i) {
        final chat = _chats[i];
        return InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(radius: 26, backgroundImage: NetworkImage(chat['avatar'])),
                    if (chat['isDoctor'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.verified_rounded, color: MyTheme.primaryBlue, size: 14),
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
                            chat['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MyTheme.textDark),
                          ),
                          Text(
                            chat['time'],
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat['lastMsg'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chat['unread'] > 0 ? MyTheme.textDark : Colors.grey[500],
                          fontSize: 14,
                          fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (chat['unread'] > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: MyTheme.primaryBlue, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // TASKS TAB
  // ─────────────────────────────────────────────────────────
  Widget _buildTaskTab() {
    return ListenableBuilder(
      listenable: TaskService(),
      builder: (context, _) {
        final tasks = TaskService().allTasks;
        
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_turned_in_rounded, size: 64, color: Colors.grey[200]),
                const SizedBox(height: 16),
                const Text('No tasks for today!', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: MyTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Tap a task to mark it as completed',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return _buildTaskCard(
                    task: task,
                    onChanged: (val) {
                      if (val != null) {
                        TaskService().toggleTaskCompletion(task.id, val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(val ? 'Task completed!' : 'Task reopened'),
                            backgroundColor: val ? MyTheme.successGreen : Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard({
    required TaskItem task,
    required ValueChanged<bool?> onChanged,
  }) {
    String title = task.title;
    String patient = task.patient;
    String due = task.formattedTime;
    String priority = task.priority;
    IconData icon = task.icon;
    bool isCompleted = task.isCompleted;

    Color priorityColor;
    switch (priority) {
      case 'High': priorityColor = MyTheme.criticalRed; break;
      case 'Medium': priorityColor = MyTheme.warningOrange; break;
      default: priorityColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () => onChanged(!isCompleted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isCompleted)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: priority == 'High' && !isCompleted
              ? Border(left: BorderSide(color: priorityColor, width: 4))
              : Border.all(color: Colors.transparent),
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
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.grey.shade200 : priorityColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 16, color: isCompleted ? Colors.grey : priorityColor),
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
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
                        if (!isCompleted)
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
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: MyTheme.successGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Done ✅',
                              style: TextStyle(
                                color: MyTheme.successGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
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
}
