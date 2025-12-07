class UserPreferences {
  final int? id;
  final bool isDarkMode;
  final String themeColor; // 'teal', 'blue', 'purple', 'green', 'orange'
  final bool notificationsEnabled;
  final bool waterReminders;
  final bool dailyLogReminders;
  final bool goalAlerts;
  final String? reminderTime; // HH:mm format
  final double? height; // in cm
  final double? weight; // in kg
  final DateTime? updatedAt;

  UserPreferences({
    this.id,
    this.isDarkMode = false,
    this.themeColor = 'teal',
    this.notificationsEnabled = true,
    this.waterReminders = true,
    this.dailyLogReminders = true,
    this.goalAlerts = true,
    this.reminderTime = '09:00',
    this.height,
    this.weight,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isDarkMode': isDarkMode ? 1 : 0,
      'themeColor': themeColor,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'waterReminders': waterReminders ? 1 : 0,
      'dailyLogReminders': dailyLogReminders ? 1 : 0,
      'goalAlerts': goalAlerts ? 1 : 0,
      'reminderTime': reminderTime,
      'height': height,
      'weight': weight,
      'updatedAt':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    var darkMode = (map['isDarkMode'] as int) == 1 ? true : false;
    return UserPreferences(
      id: map['id'] as int?,
      isDarkMode: darkMode,
      themeColor: map['themeColor'] as String? ?? 'teal',
      notificationsEnabled: (map['notificationsEnabled'] as int) == 1,
      waterReminders: (map['waterReminders'] as int) == 1,
      dailyLogReminders: (map['dailyLogReminders'] as int) == 1,
      goalAlerts: (map['goalAlerts'] as int) == 1,
      reminderTime: map['reminderTime'] as String?,
      height: map['height'] as double?,
      weight: map['weight'] as double?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  UserPreferences copyWith({
    int? id,
    bool? isDarkMode,
    String? themeColor,
    bool? notificationsEnabled,
    bool? waterReminders,
    bool? dailyLogReminders,
    bool? goalAlerts,
    String? reminderTime,
    double? height,
    double? weight,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeColor: themeColor ?? this.themeColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      waterReminders: waterReminders ?? this.waterReminders,
      dailyLogReminders: dailyLogReminders ?? this.dailyLogReminders,
      goalAlerts: goalAlerts ?? this.goalAlerts,
      reminderTime: reminderTime ?? this.reminderTime,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // calc bmi
  double? calculateBMI() {
    if (height == null || weight == null || height! <= 0) return null;
    var heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // get bmi category
  String getBMICategory() {
    var bmi = calculateBMI();
    if (bmi == null) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // ideal weight range
  Map<String, double>? getIdealWeightRange() {
    if (height == null || height! <= 0) return null;
    var heightInMeters = height! / 100;
    return {
      'min': 18.5 * (heightInMeters * heightInMeters),
      'max': 25 * (heightInMeters * heightInMeters),
    };
  }
}
