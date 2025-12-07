import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import '../database/database_helper.dart';

class PreferencesProvider with ChangeNotifier {
  UserPreferences _preferences = UserPreferences();
  bool _isLoading = false;

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _preferences.isDarkMode;
  String get themeColor => _preferences.themeColor;

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      var db = await DatabaseHelper.instance.database;
      var result = await db.query('user_preferences', limit: 1);

      if (result.isNotEmpty) {
        _preferences = UserPreferences.fromMap(result.first);
      } else {
        await savePreferences(_preferences);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    try {
      var db = await DatabaseHelper.instance.database;
      final updatedPrefs = prefs.copyWith(updatedAt: DateTime.now());

      if (updatedPrefs.id == null) {
        var id = await db.insert('user_preferences', updatedPrefs.toMap());
        _preferences = updatedPrefs.copyWith(id: id);
      } else {
        await db.update(
          'user_preferences',
          updatedPrefs.toMap(),
          where: 'id = ?',
          whereArgs: [updatedPrefs.id],
        );
        _preferences = updatedPrefs;
      }
      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print('Error saving preferences: $e');
      rethrow;
    }
  }

  Future<void> toggleDarkMode() async {
    await savePreferences(
        _preferences.copyWith(isDarkMode: !_preferences.isDarkMode));
  }

  Future<void> changeThemeColor(String color) async {
    await savePreferences(_preferences.copyWith(themeColor: color));
  }

  Future<void> updateHealthMetrics(double? height, double? weight) async {
    await savePreferences(
        _preferences.copyWith(height: height, weight: weight));
  }

  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? waterReminders,
    bool? dailyLogReminders,
    bool? goalAlerts,
    String? reminderTime,
  }) async {
    await savePreferences(_preferences.copyWith(
      notificationsEnabled: notificationsEnabled,
      waterReminders: waterReminders,
      dailyLogReminders: dailyLogReminders,
      goalAlerts: goalAlerts,
      reminderTime: reminderTime,
    ));
  }

  Color getPrimaryColor() {
    switch (_preferences.themeColor) {
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'teal':
      default:
        return Colors.teal;
    }
  }
}
