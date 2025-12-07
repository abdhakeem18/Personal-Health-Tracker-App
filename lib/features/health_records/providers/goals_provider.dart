import 'package:flutter/material.dart';
import '../models/health_goal.dart';
import '../database/database_helper.dart';

class GoalsProvider with ChangeNotifier {
  HealthGoal _goals = HealthGoal();
  bool _isLoading = false;

  HealthGoal get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('health_goals', limit: 1);

      if (result.isNotEmpty) {
        _goals = HealthGoal.fromMap(result.first);
      } else {
        await saveGoals(_goals);
      }
    } catch (e) {
      print('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGoals(HealthGoal newGoals) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final updatedGoals = newGoals.copyWith(updatedAt: DateTime.now());

      if (updatedGoals.id == null) {
        final id = await db.insert('health_goals', updatedGoals.toMap());
        _goals = updatedGoals.copyWith(id: id);
      } else {
        await db.update(
          'health_goals',
          updatedGoals.toMap(),
          where: 'id = ?',
          whereArgs: [updatedGoals.id],
        );
        _goals = updatedGoals;
      }
      notifyListeners();
    } catch (e) {
      print('Error saving goals: $e');
      rethrow;
    }
  }

  // calculate progress %
  double getProgressPercentage(int current, int goal) {
    if (goal == 0) return 0;
    return (current / goal * 100).clamp(0, 100);
  }

  bool isGoalAchieved(int current, int goal) {
    return current >= goal;
  }

  String getMotivationalMessage(double percentage) {
    if (percentage >= 100) return 'Goal achieved! Amazing!';
    if (percentage >= 75) return 'Almost there! Keep going!';
    if (percentage >= 50) return 'Great progress! Stay strong!';
    if (percentage >= 25) return 'Good start! You can do it!';
    return 'Let\'s get moving!';
  }
}
