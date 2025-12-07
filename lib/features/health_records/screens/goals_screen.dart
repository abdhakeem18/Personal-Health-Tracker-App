import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/goals_provider.dart';
import '../models/health_goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dailyStepsController;
  late TextEditingController _dailyCaloriesController;
  late TextEditingController _dailyWaterController;
  late TextEditingController _weeklyStepsController;
  late TextEditingController _weeklyCaloriesController;
  late TextEditingController _weeklyWaterController;

  @override
  void initState() {
    super.initState();
    _dailyStepsController = TextEditingController();
    _dailyCaloriesController = TextEditingController();
    _dailyWaterController = TextEditingController();
    _weeklyStepsController = TextEditingController();
    _weeklyCaloriesController = TextEditingController();
    _weeklyWaterController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      goalsProvider.loadGoals();
    });
  }

  @override
  void dispose() {
    _dailyStepsController.dispose();
    _dailyCaloriesController.dispose();
    _dailyWaterController.dispose();
    _weeklyStepsController.dispose();
    _weeklyCaloriesController.dispose();
    _weeklyWaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Goals'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var goals = provider.goals;
          _dailyStepsController.text = goals.dailyStepsGoal.toString();
          _dailyCaloriesController.text = goals.dailyCaloriesGoal.toString();
          _dailyWaterController.text = goals.dailyWaterGoal.toString();
          _weeklyStepsController.text = goals.weeklyStepsGoal.toString();
          _weeklyCaloriesController.text = goals.weeklyCaloriesGoal.toString();
          _weeklyWaterController.text = goals.weeklyWaterGoal.toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Daily Goals', Icons.today, Colors.teal),
                  const SizedBox(height: 16),
                  _buildGoalCard(
                    title: 'Steps Goal',
                    icon: Icons.directions_walk,
                    color: Colors.green,
                    controller: _dailyStepsController,
                    suffix: 'steps',
                    recommendedValue: '10,000',
                  ),
                  const SizedBox(height: 12),
                  _buildGoalCard(
                    title: 'Calories Goal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    controller: _dailyCaloriesController,
                    suffix: 'kcal',
                    recommendedValue: '500',
                  ),
                  const SizedBox(height: 12),
                  _buildGoalCard(
                    title: 'Water Goal',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    controller: _dailyWaterController,
                    suffix: 'ml',
                    recommendedValue: '2,000',
                  ),
                  const SizedBox(height: 32),
                  // _buildSectionHeader(
                  //     'Weekly Goals', Icons.calendar_month, Colors.purple),
                  // const SizedBox(height: 16),
                  // _buildGoalCard(
                  //   title: 'Steps Goal',
                  //   icon: Icons.directions_walk,
                  //   color: Colors.green,
                  //   controller: _weeklyStepsController,
                  //   suffix: 'steps',
                  //   recommendedValue: '70,000',
                  // ),
                  // const SizedBox(height: 12),
                  // _buildGoalCard(
                  //   title: 'Calories Goal',
                  //   icon: Icons.local_fire_department,
                  //   color: Colors.orange,
                  //   controller: _weeklyCaloriesController,
                  //   suffix: 'kcal',
                  //   recommendedValue: '3,500',
                  // ),
                  // const SizedBox(height: 12),
                  // _buildGoalCard(
                  //   title: 'Water Goal',
                  //   icon: Icons.water_drop,
                  //   color: Colors.blue,
                  //   controller: _weeklyWaterController,
                  //   suffix: 'ml',
                  //   recommendedValue: '14,000',
                  // ),
                  // const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveGoals(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required String suffix,
    required String recommendedValue,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Recommended: $recommendedValue',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: color.withAlpha(25),
                suffixText: suffix,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a goal';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGoals(GoalsProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final newGoals = HealthGoal(
        id: provider.goals.id,
        dailyStepsGoal: int.parse(_dailyStepsController.text),
        dailyCaloriesGoal: int.parse(_dailyCaloriesController.text),
        dailyWaterGoal: int.parse(_dailyWaterController.text),
        weeklyStepsGoal: int.parse(_weeklyStepsController.text),
        weeklyCaloriesGoal: int.parse(_weeklyCaloriesController.text),
        weeklyWaterGoal: int.parse(_weeklyWaterController.text),
      );

      await provider.saveGoals(newGoals);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goals saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving goals: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
