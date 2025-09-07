import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Nailysis/models/patient_data.dart';

class PatientProvider extends ChangeNotifier {
  PatientData? _currentPatient;
  bool _isAuthenticated = false;

  PatientData? get currentPatient => _currentPatient;
  bool get isAuthenticated => _isAuthenticated;

  PatientProvider() {
    _loadPatientData();
  }

  Future<void> login(PatientData patient) async {
    _currentPatient = patient;
    _isAuthenticated = true;
    await _savePatientData();
    notifyListeners();
  }

  Future<void> register(PatientData patient) async {
    _currentPatient = patient;
    _isAuthenticated = true;
    await _savePatientData();
    notifyListeners();
  }

  Future<void> logout() async {
    _currentPatient = null;
    _isAuthenticated = false;
    await _clearPatientData();
    notifyListeners();
  }

  Future<void> updatePatient(PatientData updatedPatient) async {
    _currentPatient = updatedPatient;
    await _savePatientData();
    notifyListeners();
  }

  Future<void> _loadPatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientJson = prefs.getString('patient_data');
      final isAuth = prefs.getBool('is_authenticated') ?? false;

      if (patientJson != null && isAuth) {
        final patientMap = json.decode(patientJson) as Map<String, dynamic>;
        _currentPatient = PatientData.fromJson(patientMap);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading patient data: $e');
    }
  }

  Future<void> _savePatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentPatient != null) {
        final patientJson = json.encode(_currentPatient!.toJson());
        await prefs.setString('patient_data', patientJson);
        await prefs.setBool('is_authenticated', _isAuthenticated);
      }
    } catch (e) {
      debugPrint('Error saving patient data: $e');
    }
  }

  Future<void> _clearPatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('patient_data');
      await prefs.setBool('is_authenticated', false);
    } catch (e) {
      debugPrint('Error clearing patient data: $e');
    }
  }
}
