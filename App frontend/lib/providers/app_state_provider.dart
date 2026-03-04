import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../services/api_service.dart';

class AppStateProvider extends ChangeNotifier {
  final Box _box = Hive.box('appData');
  bool _isLoading = false;
  String? _error;

  // Data lists
  List<dynamic> _patients = [];
  List<dynamic> _visits = [];
  List<dynamic> _inventory = [];

  // Offline pending requests
  List<Map<String, dynamic>> _pendingRequests = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get patients => _patients;
  List<dynamic> get visits => _visits;
  List<dynamic> get inventory => _inventory;

  // Set Loading
  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Load from local storage
  void loadLocalData() {
    _patients = _box.get('patients', defaultValue: []);
    _visits = _box.get('visits', defaultValue: []);
    _inventory = _box.get('inventory', defaultValue: []);
    
    final List<dynamic> localPending = _box.get('pendingRequests', defaultValue: []);
    _pendingRequests = localPending.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    
    notifyListeners();

    // Attempt to sync on load
    syncPendingRequests();
  }

  // Fetch Patients
  Future<void> fetchPatients() async {
    setLoading(true);
    _error = null;
    try {
      final response = await ApiService.get('/patients');
      _patients = response['patients'] ?? [];
      _box.put('patients', _patients);
    } catch (e) {
      _error = 'Failed to fetch patients: $e';
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

  // Fetch all main data
  Future<void> fetchAllData() async {
    setLoading(true);
    _error = null;
    try {
      await Future.wait([
        fetchPatients(),
        fetchVisits(),
        fetchInventory(),
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
}
