import 'package:flutter/material.dart';
import 'package:Nailysis/models/measurement_result.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isConnected = true;
  DateTime? _lastSync;
  MeasurementResult? _currentMeasurement;
  List<MeasurementResult> _measurementHistory = [];

  bool get isConnected => _isConnected;
  DateTime? get lastSync => _lastSync;
  MeasurementResult? get currentMeasurement => _currentMeasurement;
  List<MeasurementResult> get measurementHistory =>
      List.unmodifiable(_measurementHistory);
  List<MeasurementResult> get recentMeasurements =>
      _measurementHistory.take(3).toList();

  AppStateProvider() {
    _lastSync = DateTime.now().subtract(const Duration(minutes: 30));
    _simulateNetworkChanges();
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
}
