import 'package:flutter/material.dart';
import 'package:Nailysis/models/measurement_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isConnected = true;
  DateTime? _lastSync;
  MeasurementResult? _currentMeasurement;
  List<MeasurementResult> _measurementHistory = [];
  bool _isResearchMode = false;

  bool get isConnected => _isConnected;
  DateTime? get lastSync => _lastSync;
  MeasurementResult? get currentMeasurement => _currentMeasurement;
  List<MeasurementResult> get measurementHistory =>
      List.unmodifiable(_measurementHistory);
  List<MeasurementResult> get recentMeasurements =>
      _measurementHistory.take(3).toList();
  bool get isResearchMode => _isResearchMode;

  AppStateProvider() {
    _lastSync = DateTime.now().subtract(const Duration(minutes: 30));
    _simulateNetworkChanges();
    _loadResearchMode();
  }

  void setConnected(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void updateLastSync() {
    _lastSync = DateTime.now();
    notifyListeners();
  }

  void setCurrentMeasurement(MeasurementResult? measurement) {
    _currentMeasurement = measurement;
    notifyListeners();
  }

  void addMeasurement(MeasurementResult measurement) {
    _measurementHistory.insert(0, measurement);
    updateLastSync();
    notifyListeners();
  }

  void clearCurrentMeasurement() {
    _currentMeasurement = null;
    notifyListeners();
  }

  String formatLastSync() {
    if (_lastSync == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(_lastSync!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';

    final hours = diff.inHours;
    if (hours < 24) return '${hours}h ago';

    return '${_lastSync!.day}/${_lastSync!.month}/${_lastSync!.year}';
  }

  void _simulateNetworkChanges() {
    // Simulate network connectivity changes for demo
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        // Randomly change connection status
        if (DateTime.now().millisecond % 10 == 0) {
          setConnected(!_isConnected);
        }
        _simulateNetworkChanges();
      }
    });
  }

  bool mounted = true;

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  Future<void> setResearchMode(bool isEnabled) async {
    _isResearchMode = isEnabled;
    await _saveResearchMode();
    notifyListeners();
  }

  Future<void> _loadResearchMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isResearchMode = prefs.getBool('isResearchMode') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading research mode: $e');
    }
  }

  Future<void> _saveResearchMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isResearchMode', _isResearchMode);
    } catch (e) {
      debugPrint('Error saving research mode: $e');
    }
  }
}
