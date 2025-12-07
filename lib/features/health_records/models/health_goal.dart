class HealthGoal {
  final int? id;
  final int dailyStepsGoal;
  final int dailyCaloriesGoal;
  final int dailyWaterGoal;
  final int weeklyStepsGoal;
  final int weeklyCaloriesGoal;
  final int weeklyWaterGoal;
  final DateTime createdAt;
  final DateTime? updatedAt;

  HealthGoal({
    this.id,
    this.dailyStepsGoal = 10000,
    this.dailyCaloriesGoal = 500,
    this.dailyWaterGoal = 2000,
    this.weeklyStepsGoal = 70000,
    this.weeklyCaloriesGoal = 3500,
    this.weeklyWaterGoal = 14000,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return{
      'id':id,
      'dailyStepsGoal': dailyStepsGoal,
      'dailyCaloriesGoal':dailyCaloriesGoal,
      'dailyWaterGoal': dailyWaterGoal,
      'weeklyStepsGoal': weeklyStepsGoal,
      'weeklyCaloriesGoal': weeklyCaloriesGoal,
      'weeklyWaterGoal': weeklyWaterGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory HealthGoal.fromMap(Map<String, dynamic> map) {
    var goalId = map['id'] as int?;
    return HealthGoal(
      id: goalId,
      dailyStepsGoal: map['dailyStepsGoal'] as int,
      dailyCaloriesGoal: map['dailyCaloriesGoal'] as int,
      dailyWaterGoal: map['dailyWaterGoal'] as int,
      weeklyStepsGoal: map['weeklyStepsGoal'] as int,
      weeklyCaloriesGoal: map['weeklyCaloriesGoal'] as int,
      weeklyWaterGoal: map['weeklyWaterGoal'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  HealthGoal copyWith({
    int? id,
    int? dailyStepsGoal,
    int? dailyCaloriesGoal,
    int? dailyWaterGoal,
    int? weeklyStepsGoal,
    int? weeklyCaloriesGoal,
    int? weeklyWaterGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthGoal(
      id: id ?? this.id,
      dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
      dailyCaloriesGoal: dailyCaloriesGoal ?? this.dailyCaloriesGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      weeklyStepsGoal: weeklyStepsGoal ?? this.weeklyStepsGoal,
      weeklyCaloriesGoal: weeklyCaloriesGoal ?? this.weeklyCaloriesGoal,
      weeklyWaterGoal: weeklyWaterGoal ?? this.weeklyWaterGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
