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
  final Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _initMockEvents();
  }

  void _initMockEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _events[today] = [
      {'title': 'Visit: Sharma Family', 'time': '10:00 AM', 'status': 'Pending', 'type': 'visit'},
      {'title': 'Follow-up: Anita Devi', 'time': '02:00 PM', 'status': 'Completed', 'type': 'followup'},
    ];
    _events[today.add(const Duration(days: 1))] = [
      {'title': 'Vaccination Drive', 'time': '09:00 AM', 'status': 'Scheduled', 'type': 'vaccination'},
    ];
    _events[today.add(const Duration(days: 2))] = [
      {'title': 'Visit: Verma Household', 'time': '11:00 AM', 'status': 'Scheduled', 'type': 'visit'},
    ];
    _events[today.add(const Duration(days: 5))] = [
      {'title': 'ANC Checkup: Priya', 'time': '10:30 AM', 'status': 'Scheduled', 'type': 'anc'},
    ];
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events.entries
        .where((e) => _isSameDay(e.key, normalized))
        .expand((e) => e.value)
        .toList();
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendarGrid(),
            const SizedBox(height: 4),
            _buildEventsList(selectedEvents),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_left_rounded, color: Colors.grey[600], size: 22),
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MyTheme.textDark),
                ),
                GestureDetector(
                  onTap: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey[400]),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (firstWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) return const SizedBox();

              final dayNumber = index - (firstWeekday - 1) + 1;
              final currentDay = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              final isToday = _isSameDay(currentDay, DateTime.now());
              final isSelected = _isSameDay(currentDay, _selectedDay);
              final hasEvents = _getEventsForDay(currentDay).isNotEmpty;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDay = currentDay;
                  _focusedDay = currentDay;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MyTheme.primaryBlue
                        : isToday
                            ? MyTheme.primaryBlue.withValues(alpha: 0.08)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : MyTheme.textDark,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (hasEvents)
                        Positioned(
                          bottom: 5,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : MyTheme.primaryBlue,
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

  // ─────────────────────────────────────────────────────────
  // EVENTS LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildEventsList(List<Map<String, dynamic>> events) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Text(
                  _selectedDay != null
                      ? (_isSameDay(_selectedDay!, DateTime.now())
                          ? "Today's Schedule"
                          : DateFormat('d MMM').format(_selectedDay!))
                      : "Today's Schedule",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MyTheme.textDark),
                ),
                const SizedBox(width: 8),
                if (events.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: MyTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: MyTheme.primaryBlue),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_available_rounded, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No visits scheduled',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: events.length,
                    itemBuilder: (context, i) => _buildEventCard(events[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final status = event['status'] as String;
    final type = event['type'] as String? ?? 'visit';

    Color statusColor = Colors.grey;
    if (status == 'Pending') statusColor = Colors.orange;
    if (status == 'Completed') statusColor = MyTheme.successGreen;
    if (status == 'Scheduled') statusColor = MyTheme.primaryBlue;

    IconData typeIcon = Icons.home_rounded;
    if (type == 'followup') typeIcon = Icons.replay_rounded;
    if (type == 'vaccination') typeIcon = Icons.vaccines_rounded;
    if (type == 'anc') typeIcon = Icons.pregnant_woman_rounded;

    return Container(
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
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(typeIcon, color: statusColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  (event['time'] as String).split(' ')[0],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
                Text(
                  (event['time'] as String).split(' ').last,
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
                  event['title'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MyTheme.textDark),
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
    );
  }
}
