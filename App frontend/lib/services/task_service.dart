import 'package:flutter/material.dart';

class TaskItem {
  final String id;
  final String title;
  final String patient;
  final DateTime due;
  final String priority;
  final IconData icon;
  final String type; // 'visit', 'vaccination', 'anc', 'report', etc.
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.patient,
    required this.due,
    required this.priority,
    required this.icon,
    required this.type,
    this.isCompleted = false,
  });

  // Helper method for format in Calendar
  String get formattedTime {
    return '${due.hour % 12 == 0 ? 12 : due.hour % 12}:${due.minute.toString().padLeft(2, '0')} ${due.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class TaskService extends ChangeNotifier {
  // Singleton pattern for simple global state in this demo
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal() {
    _initMockTasks();
  }

  final List<TaskItem> _tasks = [];
  
  List<TaskItem> get allTasks => _tasks;

  void _initMockTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _tasks.addAll([
      TaskItem(
        id: 't1',
        title: 'Newborn Vaccination Follow-up',
        patient: 'Baby of Priya Sharma',
        due: today.add(const Duration(hours: 10)), // 10:00 AM Today
        priority: 'High',
        icon: Icons.vaccines_rounded,
        type: 'vaccination',
      ),
      TaskItem(
        id: 't2',
        title: 'Monthly Nutrition Report',
        patient: 'Village Center',
        due: today.add(const Duration(days: 1, hours: 9)), // Tomorrow 9 AM
        priority: 'Medium',
        icon: Icons.analytics_rounded,
        type: 'report',
      ),
      TaskItem(
        id: 't3',
        title: 'Update Pregnant Women Registry',
        patient: 'All Wards',
        due: today.add(const Duration(days: 2, hours: 14)), // Day after 2 PM
        priority: 'Low',
        icon: Icons.pregnant_woman_rounded,
        type: 'registry',
      ),
      TaskItem(
        id: 't4',
        title: 'ANC Checkup Coordination',
        patient: 'Meera Bai',
        due: today.subtract(const Duration(days: 1, hours: 2)), // Yesterday completed
        priority: 'Medium',
        icon: Icons.monitor_heart_rounded,
        type: 'anc',
        isCompleted: true,
      ),
      // Adding the pure calendar visits so they show in tasks too
      TaskItem(
        id: 't5',
        title: 'Visit: Sharma Family',
        patient: 'Sharma Family',
        due: today.add(const Duration(hours: 11)), // 11:00 AM Today
        priority: 'Medium',
        icon: Icons.home_rounded,
        type: 'visit',
      ),
      TaskItem(
        id: 't6',
        title: 'Follow-up: Anita Devi',
        patient: 'Anita Devi',
        due: today.add(const Duration(hours: 14)), // 2:00 PM Today
        priority: 'Low',
        icon: Icons.replay_rounded,
        type: 'followup',
        isCompleted: true,
      ),
    ]);
  }

  void toggleTaskCompletion(String id, bool completed) {
    final taskIndex = _tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = completed;
      notifyListeners();
    }
  }

  List<TaskItem> getTasksForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _tasks.where((t) {
      return t.due.year == normalized.year && 
             t.due.month == normalized.month && 
             t.due.day == normalized.day;
    }).toList();
  }

  Map<String, dynamic> getTodayActivitySummary() {
    final now = DateTime.now();
    final todayTasks = getTasksForDay(now);
    final completed = todayTasks.where((t) => t.isCompleted).toList();
    
    return {
      'total': todayTasks.length,
      'completed': completed.length,
      'pending': todayTasks.length - completed.length,
      'completedTasks': completed.map((t) => {
        'title': t.title,
        'patient': t.patient,
        'time': t.formattedTime,
      }).toList(),
    };
  }
}

