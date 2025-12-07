import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../providers/health_record_provider.dart';
import '../utils/calorie_calculator.dart';

class AddEditRecordScreen extends StatefulWidget {
  final HealthRecord? record;

  const AddEditRecordScreen({super.key, this.record});

  @override
  State<AddEditRecordScreen> createState() => _AddEditRecordScreenState();
}

class _AddEditRecordScreenState extends State<AddEditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _stepsController.text = widget.record!.steps.toString();
      _caloriesController.text = widget.record!.calories.toString();
      _waterController.text = widget.record!.water.toString();
      _selectedDate = DateTime.parse(widget.record!.date);
    }

    _stepsController.addListener(_calculateCalories);
  }

  void _calculateCalories() {
    //calculate calories based on steps
    final steps = int.tryParse(_stepsController.text);
    if (steps != null && steps > 0) {
      var calories = CalorieCalculator.calculateCaloriesFromSteps(steps: steps);
      var caloriesText = calories.toString();
      _caloriesController.text = caloriesText;
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var provider = Provider.of<HealthRecordProvider>(context, listen: false);
      var dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      var record = HealthRecord(
        id: widget.record?.id,
        date: dateString,
        steps: int.parse(_stepsController.text),
        calories: int.parse(_caloriesController.text),
        water: int.parse(_waterController.text),
      );

      if (widget.record == null) {
        await provider.addHealthRecord(record);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await provider.updateHealthRecord(record);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record updated successfully!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.record != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Record' : 'Add Health Record'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Selection Card
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today,
                            color: Colors.teal),
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('EEEE, MMMM d, yyyy')
                              .format(_selectedDate),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _selectDate(context),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Steps Input
                    _buildInputField(
                      controller: _stepsController,
                      label: 'Steps Walked',
                      icon: Icons.directions_walk,
                      color: Colors.green,
                      hintText: 'e.g., 10000',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter steps';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Steps cannot be negative';
                        }
                        return null;
                      },
                    ),

                    // Activity insights
                    if (_stepsController.text.isNotEmpty &&
                        int.tryParse(_stepsController.text) != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildActivityInsights(
                            int.parse(_stepsController.text)),
                      ),

                    const SizedBox(height: 16),

                    // Calories Input (Auto-calculated)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Calories Burned (kcal)',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Auto-calculated from steps',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _caloriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Auto-calculated',
                                suffixIcon: Tooltip(
                                  message:
                                      'Calculated based on your steps, age, and gender',
                                  child: Icon(Icons.info_outline,
                                      color: Colors.grey.shade500),
                                ),
                                filled: true,
                                fillColor: Colors.orange.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter steps first';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                if (int.parse(value) < 0) {
                                  return 'Calories cannot be negative';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tip: Enter your steps above to auto-calculate calories',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Water Input
                    _buildInputField(
                      controller: _waterController,
                      label: 'Water Intake (ml)',
                      icon: Icons.water_drop,
                      color: Colors.blue,
                      hintText: 'e.g., 2000',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter water intake';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Water intake cannot be negative';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditMode ? 'Update Record' : 'Save Record',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Health Guidelines Card
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Daily Recommendations',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildGuideline(
                              icon: Icons.directions_walk,
                              text: 'Steps: 10,000 steps/day',
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            _buildGuideline(
                              icon: Icons.local_fire_department,
                              text: 'Calories: 300-500 kcal/day',
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            _buildGuideline(
                              icon: Icons.water_drop,
                              text: 'Water: 2,000-3,000 ml/day',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGuideline({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityInsights(int steps) {
    final distance = CalorieCalculator.calculateDistanceKm(steps);
    final activityLevel = CalorieCalculator.getActivityLevel(steps);
    final activeMinutes = CalorieCalculator.estimateActiveMinutes(steps);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: Colors.teal.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                'Activity Insights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  Icons.straighten,
                  '${distance.toStringAsFixed(2)} km',
                  'Distance',
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  Icons.speed,
                  activityLevel,
                  'Level',
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  Icons.timer_outlined,
                  '$activeMinutes min',
                  'Active Time',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal.shade600, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade900,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.teal.shade600,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
