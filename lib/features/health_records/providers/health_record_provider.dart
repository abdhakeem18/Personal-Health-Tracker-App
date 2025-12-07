import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/health_record.dart';

class HealthRecordProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<HealthRecord> _healthRecords = [];
  List<HealthRecord> _filteredRecords = [];
  bool _isLoading = false;
  String? _searchDate;

  List<HealthRecord> get healthRecords => _filteredRecords;
  bool get isLoading => _isLoading;
  String? get searchDate => _searchDate;

  Future<void> initialize() async {
    await loadHealthRecords();
  }

  Future<void> loadHealthRecords() async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthRecords = await _dbHelper.getAllHealthRecords();
      _filteredRecords = List.from(_healthRecords);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      await _dbHelper.insertHealthRecord(record);
      await loadHealthRecords();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      await _dbHelper.updateHealthRecord(record);
      await loadHealthRecords();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(int id) async {
    try {
      await _dbHelper.deleteHealthRecord(id);
      await loadHealthRecords();
    } catch (e) {
      rethrow;
    }
  }

  void filterByDate(String? date) {
    _searchDate = date;
    if (date == null || date.isEmpty) {
      _filteredRecords = List.from(_healthRecords);
    } else {
      _filteredRecords =
          _healthRecords.where((record) => record.date == date).toList();
    }
    notifyListeners();
  }

  void clearFilter() {
    _searchDate = null;
    _filteredRecords = List.from(_healthRecords);
    notifyListeners();
  }

  Future<Map<String, int>> getTodayStats() async {
    var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await _dbHelper.getStatsByDate(today);
  }

  Map<String, int> getTodayStatsSync() {
    var today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var todayRecords =
        _healthRecords.where((record) => record.date == today).toList();

    if (todayRecords.isEmpty) {
      return {'steps': 0, 'calories': 0, 'water': 0};
    }

    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in todayRecords) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    return {
      'steps': totalSteps,
      'calories': totalCalories,
      'water': totalWater,
    };
  }

  Future<Map<String, int>> getStatsByDate(String date) async {
    return await _dbHelper.getStatsByDate(date);
  }

  Future<List<HealthRecord>> getTodayRecords() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return await _dbHelper.getTodayHealthRecords(today);
  }
}
