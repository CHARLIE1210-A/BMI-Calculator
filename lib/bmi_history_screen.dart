import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';
import 'package:intl/intl.dart';

class BmiHistoryScreen extends StatefulWidget {
  const BmiHistoryScreen({super.key});

  @override
  _BmiHistoryScreenState createState() => _BmiHistoryScreenState();
}

class _BmiHistoryScreenState extends State<BmiHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _bmiRecords;

  @override
  void initState() {
    super.initState();
    _bmiRecords = DatabaseHelper().getBmiRecords();
  }

  Color _getCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getCategoryText(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  List<FlSpot> _getBmiSpots(List<Map<String, dynamic>> records) {
    return records.asMap().entries
        .where((entry) => entry.value['bmi'] != null)
        .map((entry) {
          final index = entry.key;
          final bmiRaw = entry.value['bmi'];
          final bmi = bmiRaw is double ? bmiRaw : double.tryParse(bmiRaw.toString()) ?? 0.0;
          return FlSpot(index.toDouble(), bmi);
        }).toList();
  }

  SideTitles _buildBottomTitles(List<Map<String, dynamic>> records) {
    return SideTitles(
      showTitles: true,
      interval: 1,
      getTitlesWidget: (value, meta) {
        if (value.toInt() >= 0 && value.toInt() < records.length) {
          final record = records[value.toInt()];
          final date = DateTime.tryParse(record['date']);
          if (date != null) {
            return Text('${date.month}/${date.day}', style: const TextStyle(fontSize: 10));
          }
        }
        return const Text('');
      },
    );
  }

  SideTitles get _leftTitles => SideTitles(
        showTitles: true,
        interval: 5,
        getTitlesWidget: (value, meta) {
          return Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10));
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('BMI History')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bmiRecords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No BMI records found.'));
            }

            final records = snapshot.data!;
            final spots = _getBmiSpots(records);

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            barWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: _buildBottomTitles(records)),
                          leftTitles: AxisTitles(sideTitles: _leftTitles),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey, width: 0.5),
                        ),
                        lineTouchData: LineTouchData(enabled: true),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final bmiRaw = record['bmi'];
                      final bmi = bmiRaw is double ? bmiRaw : double.tryParse(bmiRaw.toString()) ?? 0.0;
                      final date = DateTime.tryParse(record['date']) ?? DateTime.now();
                      final formattedDate = DateFormat('MMM dd, yyyy').format(date);

                      return Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(bmi),
                          ),
                          title: Text(
                            '${record['name']} - BMI: ${bmi.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${_getCategoryText(bmi)}'),
                              Text('Date: $formattedDate'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
