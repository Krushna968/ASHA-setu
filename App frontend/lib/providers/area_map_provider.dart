import 'package:flutter/material.dart';
// Triggering rebuild
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../services/api_service.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class AssignedArea {
  final String areaId;
  final String areaName;
  final int gridColumns;

  AssignedArea({
    required this.areaId,
    required this.areaName,
    required this.gridColumns,
  });
}

class Household {
  final String householdId;
  final String displayId; // H001, H002, etc.
  final String headName;
  final String address;
  int pendingTasksCount;
  String status; // pending, completed, high-risk, closed
  bool isClosed;
  final List<String> badges;
  final int memberCount;

  Household({
    required this.householdId,
    required this.displayId,
    required this.headName,
    required this.address,
    required this.pendingTasksCount,
    required this.status,
    required this.isClosed,
    required this.badges,
    this.memberCount = 0,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    try {
      final String statusVal = json['status']?.toString().toLowerCase() ?? 'pending';
      // Robustly handle isClosed, checking both if it's explicitly boolean or if status is 'closed'
      final dynamic isClosedRaw = json['isClosed'];
      final bool isClosedVal = (isClosedRaw == true) || (statusVal == 'closed');
      
      return Household(
        householdId: json['householdId']?.toString() ?? json['id']?.toString() ?? '',
        headName: json['headName']?.toString() ?? 'Unknown Head',
        address: json['address']?.toString() ?? 'No Address',
        displayId: json['displayId']?.toString() ?? json['houseNumber']?.toString() ?? json['house_number']?.toString() ?? 'H-000',
        status: statusVal,
        isClosed: isClosedVal,
        pendingTasksCount: int.tryParse(json['pendingTasksCount']?.toString() ?? '0') ?? 0,
        memberCount: int.tryParse(json['memberCount']?.toString() ?? '0') ?? 0,
        badges: (json['badges'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('Error parsing Household JSON: $e');
      // Return a safe fallback to prevent the whole app from crashing
      return Household(
        householdId: 'error',
        headName: 'Error Loading',
        address: '',
        displayId: 'ERR',
        status: 'pending',
        isClosed: false,
        pendingTasksCount: 0,
        memberCount: 0,
        badges: [],
      );
    }
  }
}

class HouseholdDetail {
  final String householdId;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> latestVisits;
  List<Map<String, dynamic>> pendingTasks;
  final String notes;

  HouseholdDetail({
    required this.householdId,
    required this.members,
    required this.latestVisits,
    required this.pendingTasks,
    required this.notes,
  });

  factory HouseholdDetail.fromJson(Map<String, dynamic> json) =>
      HouseholdDetail(
        householdId: json['householdId'] ?? '',
        members: (json['members'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        latestVisits: (json['latestVisits'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        pendingTasks: (json['pendingTasks'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
        notes: json['notes'] ?? '',
      );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class AreaMapProvider extends ChangeNotifier {
  AssignedArea? _area;
  List<Household> _households = [];
  final Map<String, HouseholdDetail> _detailCache = {};
  bool _isLoading = false;
  bool _isDetailLoading = false;
  String? _error;
  bool _isDemoMode = false;

  // Dashboard Stats
  int _completedToday = 0;
  int _targetToday = 8;
  int _highRiskCount = 0;
  int _dueTodayCount = 0;
  bool _hasOverdue = false;

  // In-memory offline queue for task completions
  final List<Map<String, dynamic>> _offlineQueue = [];

  AssignedArea? get area => _area;
  List<Household> get households => _households;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get error => _error;
  bool get isDemoMode => _isDemoMode;

  int get completedToday => _completedToday;
  int get targetToday => _targetToday;
  int get highRiskCount => _highRiskCount;
  int get dueTodayCount => _dueTodayCount;
  bool get hasOverdue => _hasOverdue;

  int get totalPending =>
      _households.fold(0, (sum, h) => sum + h.pendingTasksCount);
  int get totalCompleted =>
      _households.where((h) => h.status == 'completed').length;
  int get totalClosed =>
      _households.where((h) => h.status == 'closed' || h.isClosed == true).length;
  double get progressValue {
    if (_households.isEmpty) return 0.0;
    final double total = _households.length.toDouble();
    return (totalCompleted + totalClosed) / total;
  }

  HouseholdDetail? getCachedDetail(String householdId) =>
      _detailCache[householdId];

  /// Load households from the real database
  Future<void> refreshArea() async {
    _isLoading = true;
    _error = null;
    _isDemoMode = false;
    notifyListeners();

    try {
      final response = await ApiService.get('/households');
      final list = response['households'] as List<dynamic>? ?? [];
      _households = list
          .map((e) => Household.fromJson(e as Map<String, dynamic>))
          .toList();

      _area = AssignedArea(
        areaId: 'live',
        areaName: 'My Assigned Area',
        gridColumns: 4,
      );

      // Update Dashboard Stats from /worker/stats
      try {
        final stats = await ApiService.get('/worker/stats');
        _completedToday = stats['completedToday'] ?? 0;
        _targetToday = stats['targetToday'] ?? 8;
        _highRiskCount = stats['highRiskCount'] ?? 0;
        _dueTodayCount = stats['dueTodayCount'] ?? 0;
        _hasOverdue = stats['hasOverdue'] ?? false;
      } catch (e) {
        debugPrint('Error fetching worker stats: $e');
        // Derive some stats from households if stats call fails
        _highRiskCount = _households.where((h) => h.status == 'high-risk').length;
      }

      // Clear detail cache on full refresh
      _detailCache.clear();
    } catch (e) {
      _error = e.toString();
      // Keep existing data if we have it, only load demo if completely empty
      if (_households.isEmpty) {
        _loadDemoData();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lazy-load household details from the real DB
  Future<void> loadHouseholdDetails(String householdId) async {
    if (_detailCache.containsKey(householdId)) return;
    _isDetailLoading = true;
    notifyListeners();

    try {
      final json = await ApiService.get('/households/$householdId');
      _detailCache[householdId] =
          HouseholdDetail.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      if (!_detailCache.containsKey(householdId)) {
        // Check demo data as fallback
        if (_demoDetails.containsKey(householdId)) {
          _detailCache[householdId] = _demoDetails[householdId]!;
        } else {
          _detailCache[householdId] = HouseholdDetail(
            householdId: householdId,
            members: [],
            latestVisits: [],
            pendingTasks: [],
            notes: 'Could not load details — check connection.',
          );
        }
      }
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  /// Create a new household
  Future<bool> createHousehold({
    required String houseNumber,
    required String headName,
    required String address,
    String? village,
  }) async {
    try {
      final body = {
        'houseNumber': houseNumber,
        'headName': headName,
        'address': address,
        if (village != null) 'village': village,
      };
      final response = await ApiService.post('/households', body);
      if (response != null && !response.containsKey('error')) {
        await refreshArea();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Close a household
  Future<bool> closeHousehold(String householdId) async {
    // Optimistic update
    final idx = _households.indexWhere((h) => h.householdId == householdId);
    if (idx != -1) {
      _households[idx].status = 'closed';
      _households[idx].isClosed = true;
      _households[idx].pendingTasksCount = 0;
      notifyListeners();
    }

    try {
      await ApiService.put('/households/$householdId/close', {});
      return true;
    } catch (_) {
      // Rollback
      if (idx != -1) {
        _households[idx].status = 'pending';
        _households[idx].isClosed = false;
        notifyListeners();
      }
      return false;
    }
  }

  /// Complete a task — optimistic update with rollback on failure
  Future<bool> completeTask({
    required String householdId,
    required String taskId,
    required BuildContext context,
  }) async {
    final detail = _detailCache[householdId];
    Map<String, dynamic>? removedTask;
    if (detail != null) {
      final idx = detail.pendingTasks.indexWhere((t) => t['taskId'] == taskId);
      if (idx != -1) removedTask = detail.pendingTasks.removeAt(idx);
    }

    final hIdx = _households.indexWhere((h) => h.householdId == householdId);
    if (hIdx != -1 && _households[hIdx].pendingTasksCount > 0) {
      _households[hIdx].pendingTasksCount--;
      if (_households[hIdx].pendingTasksCount == 0) {
        _households[hIdx].status = 'completed';
      }
    }
    notifyListeners();

    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      _offlineQueue.add({'householdId': householdId, 'taskId': taskId});
      return false;
    }

    try {
      await ApiService.put(
          '/tasks/$taskId/status', {'status': 'COMPLETED'});
      return true;
    } catch (_) {
      // Rollback
      if (removedTask != null && detail != null) {
        detail.pendingTasks.add(removedTask);
      }
      if (hIdx != -1) {
        _households[hIdx].pendingTasksCount++;
        if (_households[hIdx].status == 'completed') {
          _households[hIdx].status = 'pending';
        }
      }
      notifyListeners();
      return false;
    }
  }

  /// Replay offline queued actions when network returns
  Future<void> replayOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in _offlineQueue) {
      try {
        await ApiService.put(
            '/tasks/${item['taskId']}/status',
            {'status': 'COMPLETED'});
      } catch (_) {
        remaining.add(item);
      }
    }
    _offlineQueue
      ..clear()
      ..addAll(remaining);
    notifyListeners();
  }

  // ─── Demo Fallback Data ─────────────────────────────────────────────────────

  void _loadDemoData() {
    _isDemoMode = true;
    _area = AssignedArea(
      areaId: 'area_demo',
      areaName: 'Sector A – Ambedkar Nagar (Demo)',
      gridColumns: 4,
    );
    _households = List.from(_demoHouseholds);
    _detailCache.addAll(_demoDetails);
    _error = null;
  }
}

// ─── Demo Data (kept as fallback for offline / no-backend scenario) ────────────

final _demoHouseholds = [
  Household(householdId: 'h_001', displayId: 'H001', headName: 'Sita Devi', address: 'Ward 3, House 21', pendingTasksCount: 2, status: 'pending', isClosed: false, badges: ['vaccination', 'postnatal']),
  Household(householdId: 'h_002', displayId: 'H002', headName: 'Meena Sharma', address: 'Ward 3, House 22', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_003', displayId: 'H003', headName: 'Radha Kumari', address: 'Ward 3, House 23', pendingTasksCount: 3, status: 'high-risk', isClosed: false, badges: ['antenatal', 'bp-check']),
  Household(householdId: 'h_004', displayId: 'H004', headName: 'Kavita Patel', address: 'Ward 3, House 24', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: ['vaccination']),
  Household(householdId: 'h_005', displayId: 'H005', headName: 'Sunita Rao', address: 'Ward 3, House 25', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_006', displayId: 'H006', headName: 'Asha Thakur', address: 'Ward 4, House 01', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: ['postnatal']),
  Household(householdId: 'h_007', displayId: 'H007', headName: 'Geetha Nair', address: 'Ward 4, House 02', pendingTasksCount: 2, status: 'high-risk', isClosed: false, badges: ['antenatal']),
  Household(householdId: 'h_008', displayId: 'H008', headName: 'Priya Verma', address: 'Ward 4, House 03', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_009', displayId: 'H009', headName: 'Lalita Singh', address: 'Ward 4, House 04', pendingTasksCount: 0, status: 'closed', isClosed: true, badges: []),
  Household(householdId: 'h_010', displayId: 'H010', headName: 'Anjali Gupta', address: 'Ward 4, House 05', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: []),
  Household(householdId: 'h_011', displayId: 'H011', headName: 'Rani Mukerji', address: 'Ward 4, House 06', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_012', displayId: 'H012', headName: 'Deepika P.', address: 'Ward 4, House 07', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_013', displayId: 'H013', headName: 'Priyanka C.', address: 'Ward 4, House 08', pendingTasksCount: 2, status: 'pending', isClosed: false, badges: []),
  Household(householdId: 'h_014', displayId: 'H014', headName: 'Kareena K.', address: 'Ward 4, House 09', pendingTasksCount: 1, status: 'high-risk', isClosed: false, badges: []),
  Household(householdId: 'h_015', displayId: 'H015', headName: 'Aishwarya R.', address: 'Ward 4, House 10', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_016', displayId: 'H016', headName: 'Vidya Balan', address: 'Ward 4, House 11', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_017', displayId: 'H017', headName: 'Madhuri D.', address: 'Ward 4, House 12', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: []),
  Household(householdId: 'h_018', displayId: 'H018', headName: 'Kajol D.', address: 'Ward 4, House 13', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_019', displayId: 'H019', headName: 'Juhi Chawla', address: 'Ward 4, House 14', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_020', displayId: 'H020', headName: 'Sridevi K.', address: 'Ward 4, House 15', pendingTasksCount: 2, status: 'pending', isClosed: false, badges: []),
  Household(householdId: 'h_021', displayId: 'H021', headName: 'Rekha G.', address: 'Ward 4, House 16', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_022', displayId: 'H022', headName: 'Hema Malini', address: 'Ward 4, House 17', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_023', displayId: 'H023', headName: 'Jaya B.', address: 'Ward 4, House 18', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: []),
  Household(householdId: 'h_024', displayId: 'H024', headName: 'Shabana A.', address: 'Ward 4, House 19', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_025', displayId: 'H025', headName: 'Smita Patil', address: 'Ward 4, House 20', pendingTasksCount: 0, status: 'completed', isClosed: false, badges: []),
  Household(householdId: 'h_026', displayId: 'H026', headName: 'Nargis D.', address: 'Ward 4, House 21', pendingTasksCount: 1, status: 'pending', isClosed: false, badges: []),
];

final Map<String, HouseholdDetail> _demoDetails = {
  'h_001': HouseholdDetail(
    householdId: 'h_001',
    members: [
      {'name': 'Sita Devi', 'age': 28, 'id': 'p_101', 'relation': 'Head (Mother)'},
      {'name': 'Rajesh Kumar', 'age': 30, 'id': 'p_102', 'relation': 'Husband'},
      {'name': 'Baby Aarav', 'age': 0, 'id': 'p_103', 'relation': 'Newborn (2 months)'},
    ],
    latestVisits: [
      {'type': 'PNC Visit', 'date': '2026-02-20', 'status': 'done'},
    ],
    pendingTasks: [
      {'taskId': 't1_1', 'type': 'Vaccination', 'dueDate': '2026-03-05', 'notes': 'BCG vaccine due for Baby Aarav'},
      {'taskId': 't1_2', 'type': 'PNC Visit', 'dueDate': '2026-03-10', 'notes': '6-week postnatal check'},
    ],
    notes: 'BP slightly elevated at last visit.',
  ),
  'h_003': HouseholdDetail(
    householdId: 'h_003',
    members: [
      {'name': 'Radha Kumari', 'age': 24, 'id': 'p_301', 'relation': 'Head (Mother)'},
      {'name': 'Sunil Yadav', 'age': 29, 'id': 'p_302', 'relation': 'Husband'},
    ],
    latestVisits: [
      {'type': 'ANC Visit', 'date': '2026-02-25', 'status': 'done'},
    ],
    pendingTasks: [
      {'taskId': 't3_1', 'type': 'ANC Visit', 'dueDate': '2026-03-08', 'notes': '3rd trimester check-up'},
      {'taskId': 't3_2', 'type': 'BP Monitoring', 'dueDate': '2026-03-06', 'notes': 'BP 145/95 — URGENT'},
      {'taskId': 't3_3', 'type': 'IFA Supplement', 'dueDate': '2026-03-05', 'notes': 'Replenish IFA tablets'},
    ],
    notes: 'HIGH RISK: Hypertension (145/95).',
  ),
};
