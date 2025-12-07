class CalorieCalculator {
  // calc calories from steps
  // formula: steps x weight x activity multiplier
  static int calculateCaloriesFromSteps({
    required int steps,
    double weightKg = 70.0,
    String activityLevel = 'moderate',
  }) {
    if (steps <= 0) return 0;

    double baseCaloriesPerStep = (weightKg * 0.57) / 1000;

    double activityMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'light':
        activityMultiplier = 0.9;
        break;
      case 'intense':
        activityMultiplier = 1.3;
        break;
      case 'moderate':
      default:
        activityMultiplier = 1.0;
        break;
    }

    double totalCalories = steps * baseCaloriesPerStep * activityMultiplier;
    return totalCalories.round();
  }

  // calc calories with user data
  static int calculateCaloriesFromStepsWithUserData({
    required int steps,
    required int age,
    required String gender,
    double? heightCm,
    double? weightKg,
  }) {
    double estimatedWeight = weightKg ?? _estimateWeight(gender, age);

    double genderMultiplier = gender.toLowerCase() == 'male' ? 1.05 : 1.0;

    double ageMultiplier = 1.0;
    if (age > 50) {
      ageMultiplier = 0.95;
    } else if (age > 60) {
      ageMultiplier = 0.90;
    }

    var baseCaloriesPerStep = (estimatedWeight * 0.57) / 1000;
    var totalCalories = steps * baseCaloriesPerStep;
    totalCalories = totalCalories * genderMultiplier;
    totalCalories = totalCalories * ageMultiplier;

    var result = totalCalories.round();
    return result;
  }

  // estimate weight by gender and age
  static double _estimateWeight(String gender, int age) {
    var isMale = gender.toLowerCase() == 'male';
    if (isMale == true) {
      if (age < 30) {
        return 75.0;
      }
      if (age < 50) {
        return 80.0;
      }
      return 78.0;
    } else {
      if (age < 30) {
        return 62.0;
      }
      if (age < 50) {
        return 68.0;
      }
      return 65.0;
    }
  }

  // recommended daily steps
  static int getRecommendedDailySteps(int age) {
    if (age < 18) return 12000;
    if (age < 40) return 10000;
    if (age < 60) return 8000;
    return 7000;
  }

  // recommended daily water
  static int getRecommendedDailyWater(double weightKg) {
    var waterAmount = weightKg * 33;
    var result = waterAmount.round();
    return result;
  }

  static String getActivityLevel(int steps) {
    if (steps < 3000) return 'Sedentary';
    if (steps < 5000) return 'Low Active';
    if (steps < 7500) return 'Somewhat Active';
    if (steps < 10000) return 'Active';
    if (steps < 12500) return 'Very Active';
    return 'Highly Active';
  }

  // calc distance in km
  static double calculateDistanceKm(int steps) {
    double meters = steps * 0.762;
    return meters / 1000;
  }

  // estimate active time in mins
  static int estimateActiveMinutes(int steps) {
    return (steps / 100).round();
  }
}
