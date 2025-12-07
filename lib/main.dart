import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/health_records/screens/dashboard_screen.dart';
import 'features/health_records/providers/health_record_provider.dart';
import 'features/health_records/providers/goals_provider.dart';
import 'features/health_records/providers/preferences_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (context) => GoalsProvider()),
        ChangeNotifierProvider(create: (context) => PreferencesProvider()),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefsProvider, _) {
          return MaterialApp(
            title: 'HealthMate',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: prefsProvider.getPrimaryColor(),
                brightness: prefsProvider.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
