import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Mock data for visits
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime.now(): [
      {'title': 'Visit: Sharma Family', 'time': '10:00 AM', 'status': 'Pending'},
      {'title': 'Follow-up: Anita Devi', 'time': '02:00 PM', 'status': 'Completed'},
    ],
    DateTime.now().add(const Duration(days: 1)): [
      {'title': 'Vaccination Drive', 'time': '09:00 AM', 'status': 'Scheduled'},
    ],
    DateTime.now().add(const Duration(days: 2)): [
      {'title': 'Visit: Verma Household', 'time': '11:00 AM', 'status': 'Scheduled'},
    ],
  };

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Normalize date to remove time part for map lookup
    final normalizedDay = DateTime(day.year, day.month, day.day);
    // Find matching key (since map keys have time, we need to match by date part)
    // Actually, let's just make keys normalized in _events
    // For simplicity in this demo, strict matching won't work perfectly without utils.
    // We'll iterate.
    
    return _events.entries
        .where((element) => isSameDay(element.key, day))
        .expand((element) => element.value)
        .toList();
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule & Follow-ups'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {}, // Add task placeholder
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Calendar Header
          _buildCalendarHeader(),
          
          // Custom Calendar Grid
          _buildCalendarGrid(),

          const SizedBox(height: 16),
          const Divider(),

          // Event List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    // Header row (Mon, Tue, Wed...)
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => Expanded(
              child: Center(
                child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (firstWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 days a week
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox(); // Empty slots before first day
              }
              final dayNumber = index - (firstWeekday - 1) + 1;
              final currentDay = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              final isToday = isSameDay(currentDay, DateTime.now());
              final isSelected = isSameDay(currentDay, _selectedDay);
              final hasEvents = _getEventsForDay(currentDay).isNotEmpty;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = currentDay;
                    _focusedDay = currentDay; // Also focus to update list
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? MyTheme.primaryBlue : (isToday ? Colors.blue.shade50 : Colors.transparent),
                    shape: BoxShape.circle,
                    border: isToday && !isSelected ? Border.all(color: MyTheme.primaryBlue) : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.white : MyTheme.textDark,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasEvents)
                        Positioned(
                          bottom: 6,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : MyTheme.criticalRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    Color statusColor = Colors.grey;
    if (event['status'] == 'Pending') statusColor = Colors.orange;
    if (event['status'] == 'Completed') statusColor = Colors.green;
    if (event['status'] == 'Scheduled') statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['time'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event['status'],
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
