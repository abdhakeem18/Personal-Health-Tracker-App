import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../providers/health_record_provider.dart';
import 'add_edit_record_screen.dart';

class HealthRecordListScreen extends StatefulWidget {
  const HealthRecordListScreen({super.key});

  @override
  State<HealthRecordListScreen> createState() => _HealthRecordListScreenState();
}

class _HealthRecordListScreenState extends State<HealthRecordListScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthRecordProvider>(context, listen: false)
          .loadHealthRecords();
    });
  }

  Future<void> _selectDateFilter(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      final dateString = DateFormat('yyyy-MM-dd').format(picked);
      Provider.of<HealthRecordProvider>(context, listen: false)
          .filterByDate(dateString);
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
    });
    Provider.of<HealthRecordProvider>(context, listen: false).clearFilter();
  }

  Future<void> _deleteRecord(BuildContext context, int id) async {
    var confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Provider.of<HealthRecordProvider>(context, listen: false)
            .deleteHealthRecord(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting record: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _selectDateFilter(context),
            tooltip: 'Filter by date',
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
              tooltip: 'Clear filter',
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter indicator
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.teal[50],
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    'Filtered by: ${DateFormat('MMM d, yyyy').format(_selectedDate!)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilter,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Records List
          Expanded(
            child: Consumer<HealthRecordProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = provider.healthRecords;

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedDate != null
                              ? 'No records found for this date'
                              : 'No health records yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first record',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadHealthRecords(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildRecordCard(context, record);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditRecordScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, HealthRecord record) {
    final date = DateTime.parse(record.date);
    final formattedDate = DateFormat('MMM d, yyyy').format(date);
    final dayOfWeek = DateFormat('EEEE').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
            date.day.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(dayOfWeek),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Statistics
                _buildStatRow(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: '${record.steps}',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: '${record.calories} kcal',
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  icon: Icons.water_drop,
                  label: 'Water',
                  value: '${record.water} ml',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditRecordScreen(
                              record: record,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteRecord(context, record.id!),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
