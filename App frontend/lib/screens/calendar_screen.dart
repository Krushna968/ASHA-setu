import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: ListenableBuilder(
                  listenable: TaskService(),
                  builder: (context, child) {
                    final selectedEvents = TaskService().getTasksForDay(_selectedDay ?? _focusedDay);
                    return Column(
                      children: [
                        _buildCalendarGrid(),
                        _buildEventsList(selectedEvents),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MyTheme.textDark),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MyTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Today',
                style: TextStyle(
                  color: MyTheme.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CALENDAR GRID
  // ─────────────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(Icons.chevron_left_rounded, 
                    () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1))),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MyTheme.textDark, letterSpacing: 0.5),
                ),
                _buildNavButton(Icons.chevron_right_rounded, 
                    () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey[400]),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (firstWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();

              final dayNumber = index - (firstWeekday - 1) + 1;
              final currentDay = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              final isToday = _isSameDay(currentDay, DateTime.now());
              final isSelected = _isSameDay(currentDay, _selectedDay);
              final hasEvents = TaskService().getTasksForDay(currentDay).isNotEmpty;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = currentDay;
                  _focusedDay = currentDay;
                }),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? Colors.transparent 
                        : (isToday ? MyTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent),
                    border: isSelected 
                        ? Border.all(color: MyTheme.primaryBlue, width: 2) 
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? MyTheme.primaryBlue : (isToday ? MyTheme.primaryBlue : MyTheme.textDark),
                          fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
                          height: 1.0, // Control line height for better centering
                        ),
                      ),
                      if (hasEvents) ...[
                        const SizedBox(height: 4), // Clear gap below number
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: MyTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 20),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // EVENTS LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildEventsList(List<TaskItem> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDay != null
                        ? (_isSameDay(_selectedDay!, DateTime.now())
                            ? "Today's Schedule"
                            : DateFormat('d MMMM').format(_selectedDay!))
                        : "Today's Schedule",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MyTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${events.length} activities planned',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Spacer(),
              if (events.isNotEmpty)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: MyTheme.primaryBlue),
                    ),
                  ),
                ),
            ],
          ),
        ),
        events.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey[300]),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Clean schedule for this day',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: events.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) => _buildEventCard(events[i]),
              ),
      ],
    );
  }

  Widget _buildEventCard(TaskItem event) {
    final status = event.isCompleted ? 'Completed' : (event.due.isBefore(DateTime.now()) ? 'Pending' : 'Scheduled');

    Color statusColor = Colors.grey;
    if (status == 'Pending') statusColor = Colors.orange;
    if (status == 'Completed') statusColor = MyTheme.successGreen;
    if (status == 'Scheduled') statusColor = MyTheme.primaryBlue;

    return GestureDetector(
      onTap: () {
        if (!event.isCompleted) {
            TaskService().toggleTaskCompletion(event.id, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${event.title} marked as completed'),
                backgroundColor: MyTheme.successGreen,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Time badge
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(event.icon, color: statusColor, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    event.formattedTime.split(' ')[0],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                  Text(
                    event.formattedTime.split(' ').last,
                    style: TextStyle(fontSize: 8, color: statusColor),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: MyTheme.textDark,
                      decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 22),
          ],
        ),
      ),
    );
  }
}
