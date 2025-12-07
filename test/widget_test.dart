import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/features/health_records/models/health_record.dart';
import 'package:healthmate/features/health_records/utils/calorie_calculator.dart';

void main() {
  group('HealthRecord Model Tests', () {
    test('HealthRecord should create from map correctly', () {
      final map = {
        'id': 1,
        'date': '2025-12-05',
        'steps': 10000,
        'calories': 500,
        'water': 2000,
      };

      final record = HealthRecord.fromMap(map);

      expect(record.id, 1);
      expect(record.date, '2025-12-05');
      expect(record.steps, 10000);
      expect(record.calories, 500);
      expect(record.water, 2000);
    });

    test('HealthRecord should convert to map correctly', () {
      final record = HealthRecord(
        id: 1,
        date: '2025-12-05',
        steps: 8000,
        calories: 400,
        water: 1500,
      );

      final map = record.toMap();

      expect(map['id'], 1);
      expect(map['steps'], 8000);
      expect(map['calories'], 400);
    });
  });

  group('Calorie Calculator Tests', () {
    test('Should calculate calories from steps correctly', () {
      final calories = CalorieCalculator.calculateCaloriesFromSteps(
        steps: 10000,
        weightKg: 70.0,
        activityLevel: 'moderate',
      );

      /////// [Should be positive and reasonable (not zero or crazy high)] //////////
      expect(calories, greaterThan(0));
      expect(
          calories,
          lessThan(
              1000)); /////// [10k steps shouldn't burn 1000+ calories] //////////
    });

    test('Should return 0 calories for 0 steps', () {
      final calories = CalorieCalculator.calculateCaloriesFromSteps(
        steps: 0,
        weightKg: 70.0,
      );

      expect(calories, 0);
    });

    test('Should calculate more calories for higher intensity', () {
      final moderateCalories = CalorieCalculator.calculateCaloriesFromSteps(
        steps: 5000,
        weightKg: 70.0,
        activityLevel: 'moderate',
      );

      final intenseCalories = CalorieCalculator.calculateCaloriesFromSteps(
        steps: 5000,
        weightKg: 70.0,
        activityLevel: 'intense',
      );

      expect(intenseCalories, greaterThan(moderateCalories));
    });
  });
}
