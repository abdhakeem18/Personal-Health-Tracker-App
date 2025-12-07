import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/health_record_provider.dart';
import '../models/health_record.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _selectedPeriod = 'week';

  @override
  Widget build(BuildContext context) {
    // TODO: maybe add export to pdf feature?
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Charts'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: {_selectedPeriod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedPeriod = newSelection.first;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          var records = _selectedPeriod == 'week'
              ? _getLastWeekRecords(provider.healthRecords)
              : _getLastMonthRecords(provider.healthRecords);

          if (records.isEmpty) {
            return const Center(
              child: Text('No data available for charts'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                    'Steps Progress', Icons.directions_walk, Colors.green),
                const SizedBox(height: 16),
                _buildLineChart(records, 'steps', Colors.green),
                const SizedBox(height: 32),
                _buildSectionTitle('Calories Burned',
                    Icons.local_fire_department, Colors.orange),
                const SizedBox(height: 16),
                _buildBarChart(records, 'calories', Colors.orange),
                const SizedBox(height: 32),
                _buildSectionTitle(
                    'Water Intake', Icons.water_drop, Colors.blue),
                const SizedBox(height: 16),
                _buildLineChart(records, 'water', Colors.blue),
                const SizedBox(height: 32),
                _buildSectionTitle(
                    'Comparison Overview', Icons.compare_arrows, Colors.purple),
                const SizedBox(height: 16),
                _buildComparisonChart(records),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(
      List<HealthRecord> records, String metric, Color color) {
    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      final value = metric == 'steps'
          ? records[i].steps.toDouble()
          : metric == 'calories'
              ? records[i].calories.toDouble()
              : records[i].water.toDouble();
      spots.add(FlSpot(i.toDouble(), value));
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: metric == 'water'
                ? 500
                : metric == 'steps'
                    ? 2000
                    : 100,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withAlpha(50),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < records.length) {
                    final date = DateTime.parse(records[value.toInt()].date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: color,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withAlpha(50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
      List<HealthRecord> records, String metric, Color color) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: records
                  .map((r) => metric == 'calories' ? r.calories : r.steps)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() *
              1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}',
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < records.length) {
                    final date = DateTime.parse(records[value.toInt()].date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: metric == 'calories' ? 100 : 2000,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(records.length, (index) {
            final value = metric == 'calories'
                ? records[index].calories
                : records[index].steps;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  color: color,
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildComparisonChart(List<HealthRecord> records) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < records.length) {
                    final date = DateTime.parse(records[value.toInt()].date);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(records.length, (index) {
            final record = records[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (record.steps / 100).toDouble(),
                  color: Colors.green,
                  width: 8,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                ),
                BarChartRodData(
                  toY: record.calories.toDouble() / 10,
                  color: Colors.orange,
                  width: 8,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                ),
                BarChartRodData(
                  toY: record.water.toDouble() / 50,
                  color: Colors.blue,
                  width: 8,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(2)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<HealthRecord> _getLastWeekRecords(List<HealthRecord> allRecords) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return allRecords
        .where((r) => DateTime.parse(r.date).isAfter(weekAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<HealthRecord> _getLastMonthRecords(List<HealthRecord> allRecords) {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return allRecords
        .where((r) => DateTime.parse(r.date).isAfter(monthAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
