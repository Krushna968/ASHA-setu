import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  final Box _box = Hive.box('appData');
  bool _isLoading = false;
  String? _error;

  // Data lists
  List<dynamic> _individuals = [];
  List<dynamic> _visits = [];
  List<dynamic> _inventory = [];
  List<dynamic> _learningModules = [];
  List<dynamic> _messages = [];

  // Offline pending requests
  List<Map<String, dynamic>> _pendingRequests = [];
  
  bool _isTransitioning = false;
  
  // Tab navigation (used by MainScreen)
  int _currentIndex = 0;

  bool get isLoading => _isLoading;
  bool get isTransitioning => _isTransitioning;
  int get currentIndex => _currentIndex;
  String? get error => _error;
  List<dynamic> get individuals => _individuals;
  List<dynamic> get visits => _visits;
  List<dynamic> get inventory => _inventory;
  List<dynamic> get learningModules => _learningModules;
  List<dynamic> get messages => _messages;

  // Set Loading
  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void setTransitioning(bool val) {
    _isTransitioning = val;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Load from local storage
  void loadLocalData() {
    _individuals = _box.get('individuals', defaultValue: []);
    _visits = _box.get('visits', defaultValue: []);
    _inventory = _box.get('inventory', defaultValue: []);
    
    final List<dynamic> localPending = _box.get('pendingRequests', defaultValue: []);
    _pendingRequests = localPending.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    
    notifyListeners();

    // Attempt to sync on load
    syncPendingRequests();
  }

  // Fetch Individuals
  Future<void> fetchIndividuals() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/patients');
      _individuals = response['patients'] ?? [];
      _box.put('individuals', _individuals);
    } catch (e) {
      _error = 'Failed to fetch individuals: $e';
    } finally {
      setLoading(false);
    }
  }

  // Fetch Visits
  Future<void> fetchVisits() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/visits');
      _visits = response['visits'] ?? [];
      _box.put('visits', _visits);
    } catch (e) {
      _error = 'Failed to fetch visits: $e';
    } finally {
      setLoading(false);
    }
  }

  // Fetch Inventory
  Future<void> fetchInventory() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/inventory');
      _inventory = response['inventory'] ?? [];
      _box.put('inventory', _inventory);
    } catch (e) {
      _error = 'Failed to fetch inventory: $e';
    } finally {
      setLoading(false);
    }
  }

  // Fetch Learning Modules
  Future<void> fetchLearningModules() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/learning');
      _learningModules = response as List<dynamic>? ?? [];
      _box.put('learningModules', _learningModules);
    } catch (e) {
      _error = 'Failed to fetch learning modules: $e';
    } finally {
      setLoading(false);
    }
  }

  // Fetch Messages
  Future<void> fetchMessages() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/messages');
      _messages = response as List<dynamic>? ?? [];
      _box.put('messages', _messages);
    } catch (e) {
      _error = 'Failed to fetch messages: $e';
    } finally {
      setLoading(false);
    }
  }

  // Fetch all main data
  Future<void> fetchAllData() async {
    setLoading(true);
    _error = null;
    try {
      await Future.wait([
        fetchIndividuals(),
        fetchVisits(),
        fetchInventory(),
        fetchLearningModules(),
        fetchMessages(),
      ]);
    } catch (e) {
      _error = 'Failed to fetch data: $e';
    } finally {
      setLoading(false);
    }
  }

  // Helper for logging visit with offline support
  Future<bool> logVisitOfflineSupport(Map<String, dynamic> visitData) async {
    bool hasInternet = await InternetConnection().hasInternetAccess;
    
    if (hasInternet) {
      try {
        final res = await ApiService.post('/visits', visitData);
        if (res != null && !res.containsKey('error')) {
          await fetchVisits();
          return true; // Synced immediately
        }
      } catch (e) {
        // Fallback to offline
      }
    }
    
    // Save offline
    _pendingRequests.add({
      'type': 'visit', 
      'data': visitData, 
      'timestamp': DateTime.now().toIso8601String()
    });
    await _box.put('pendingRequests', _pendingRequests);
    
    // Optimistically update UI
    _visits.insert(0, visitData);
    await _box.put('visits', _visits);
    notifyListeners();
    
    return false; // Indicates saved offline
  }

  // Background sync logic
  Future<void> syncPendingRequests() async {
    if (_pendingRequests.isEmpty) return;
    bool hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) return;

    List<Map<String, dynamic>> remaining = [];
    bool updated = false;

    for (var req in _pendingRequests) {
      if (req['type'] == 'visit') {
        try {
          final res = await ApiService.post('/visits', req['data']);
          if (res != null && !res.containsKey('error')) {
            updated = true;
          } else {
            remaining.add(req);
          }
        } catch (e) {
          remaining.add(req);
        }
      } else {
        remaining.add(req);
      }
    }
    
    _pendingRequests = remaining;
    await _box.put('pendingRequests', _pendingRequests);
    
    if (updated) {
      await fetchVisits();
    }
  }

  // Seed Demo Data for Testing
  void seedDemoData() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    // Demo Individuals
    _individuals = [
      {'id': 'p1', 'name': 'Aditi Sharma', 'householdId': 'h1'},
      {'id': 'p2', 'name': 'Rajesh Kumar', 'householdId': 'h1'},
      {'id': 'p3', 'name': 'Sita Devi', 'householdId': 'h2'},
      {'id': 'p4', 'name': 'Amit Patel', 'householdId': 'h3'},
      {'id': 'p5', 'name': 'Priya Singh', 'householdId': 'h4'},
    ];
    
    // Demo Visits
    _visits = [
      {
        'patientId': 'p1',
        'visitDate': '${todayStr}T10:30:00',
        'visitType': 'Routine',
        'outcome': 'Normal'
      },
      {
        'patientId': 'p2',
        'visitDate': '${todayStr}T11:45:00',
        'visitType': 'Follow-up',
        'outcome': 'Stable'
      },
      {
        'patientId': 'p3',
        'visitDate': '${todayStr}T09:20:00',
        'visitType': 'ANC Follow-up',
        'outcome': 'Healthy'
      },
      {
        'patientId': 'p4',
        'visitDate': '${todayStr}T14:15:00',
        'visitType': 'Emergency',
        'outcome': 'Referred'
      },
      {
        'patientId': 'p5',
        'visitDate': '${todayStr}T15:00:00',
        'visitType': 'PNC Follow-up',
        'outcome': 'Stable'
      },
    ];
    
    _box.put('individuals', _individuals);
    _box.put('visits', _visits);
    notifyListeners();
  }
}
