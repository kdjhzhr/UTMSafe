import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String mainDropdownValue = 'Incident Post';
  String timeFilterValue = 'Day';
  String chartTypeValue = 'Bar Chart';

  Future<Map<String, dynamic>> _fetchMostCommonCategoryWithCount() async {
    DateTime now = DateTime.now();
    DateTime startTime = timeFilterValue == 'Day' 
      ? DateTime(now.year, now.month, now.day)
      : now.subtract(const Duration(days: 7));

    QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .where('timestamp', isGreaterThanOrEqualTo: startTime)
      .get();

    Map<String, int> categoryCounts = {};
    
    for (var doc in snapshot.docs) {
      final category = doc['category'] as String? ?? 'Uncategorized';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    if (categoryCounts.isEmpty) {
      return {'category': 'No Data', 'count': 0};
    }

    String mostCommonCategory = categoryCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

    return {
      'category': mostCommonCategory,
      'count': categoryCounts[mostCommonCategory]!
    };
  }

  Stream<List<int>> _fetchIncidentPostData() async* {
    DateTime now = DateTime.now();
    DateTime startTime = timeFilterValue == 'Day' 
      ? DateTime(now.year, now.month, now.day)
      : now.subtract(const Duration(days: 7));

    await for (var snapshot in FirebaseFirestore.instance
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .snapshots()) {
      final countsPerDay = List.generate(7, (_) => 0);

      for (var doc in snapshot.docs) {
        if (doc['timestamp'] != null) {
          DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
          int dayOfWeek = timestamp.weekday - 1;
          if (dayOfWeek < 0) dayOfWeek = 6;
          countsPerDay[dayOfWeek] += 1;
        }
      }
      yield countsPerDay;
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchCategoryCounts() async* {
    DateTime now = DateTime.now();
    DateTime startTime = timeFilterValue == 'Day' 
      ? DateTime(now.year, now.month, now.day)
      : now.subtract(const Duration(days: 7));

    await for (var snapshot in FirebaseFirestore.instance
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .snapshots()) {
      final categoryCounts = <String, int>{};
      
      for (var doc in snapshot.docs) {
        final category = doc['category'] as String? ?? 'Uncategorized';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      yield categoryCounts.entries
          .map((e) => {'category': e.key, 'count': e.value})
          .toList();
    }
  }

  Widget _buildChart() {
    if (mainDropdownValue == 'Incident Post') {
      return StreamBuilder<List<int>>(
        stream: _fetchIncidentPostData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          
          return chartTypeValue == 'Bar Chart'
              ? _buildBarChartIncidentPost(snapshot.data!, DateTime.now())
              : _buildPieChartIncidentPost(snapshot.data!, DateTime.now());
        },
      );
    } else {
      return StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchCategoryCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          
          return chartTypeValue == 'Bar Chart'
              ? _buildBarChartIncidentCategory(snapshot.data!)
              : _buildPieChartIncidentCategory(snapshot.data!);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchMostCommonCategoryWithCount(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                
                return _buildAlertBanner(
                  snapshot.data!['category'],
                  snapshot.data!['count']
                );
              },
            ),
            const SizedBox(height: 16),
            _buildDropdowns(),
            const SizedBox(height: 16),
            Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropdownButton<String>(
          value: mainDropdownValue,
          items: ['Incident Post', 'Incident Category']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => mainDropdownValue = value!),
        ),
        DropdownButton<String>(
          value: timeFilterValue,
          items: ['Day', 'Week']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => timeFilterValue = value!),
        ),
        DropdownButton<String>(
          value: chartTypeValue,
          items: ['Bar Chart', 'Pie Chart']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => chartTypeValue = value!),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(String category, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, color: Colors.yellow, size: 20.0),
              const SizedBox(width: 8),
              const Text(
                'Most Common Incident:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$category (Count: $count)',
            style: const TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

Widget _buildBarChartIncidentPost(List<int> data, DateTime now) {
  // Define days of the week
  List<String> xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Find the maximum value in the data for dynamic scaling
  int maxValue = data.reduce((a, b) => a > b ? a : b);
  int yMax = (maxValue > 0) ? maxValue + 1 : 1; // Ensure a non-zero Y-axis

  // Map the data to BarChartGroupData
  List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value.toDouble(),
          color: Colors.red,
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    child: BarChart(
      BarChartData(
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        gridData: const FlGridData(
          show: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
            axisNameWidget: const Text(
              'Incident Post Count',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            axisNameSize: 16,
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Ensure titles appear at regular intervals
              getTitlesWidget: (value, meta) {
                int index = value.round(); // Round value to an integer
                if (index >= 0 && index < xLabels.length) {
                  return Text(
                    xLabels[index],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text(
                    ''); // Return empty for out-of-bounds indices
              },
            ),
            axisNameWidget: const Text(
              'Days',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            axisNameSize: 16,
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide top titles
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right titles
          ),
        ),
        maxY: yMax.toDouble(), // Dynamically adjust the Y-axis max value
        barGroups: barGroups,
      ),
    ),
  );
}

  Widget _buildPieChartIncidentPost(List<int> data, DateTime now) {
  List<Color> pieChartColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
  ];

  List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<PieChartSectionData> pieSections = [];

  // Create pie chart sections
  for (int i = 0; i < data.length; i++) {
    if (data[i] > 0) {
      pieSections.add(PieChartSectionData(
        color: pieChartColors[i],
        value: data[i].toDouble(),
        title: "${data[i]}",
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
  }

  return data.every((value) => value == 0)
      ? const Center(child: Text("No data to display"))
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(data.length, (index) {
                    if (data[index] > 0) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pieChartColors[index],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dayLabels[index],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                ),
              ],
            ),
          ),
        );
}

  Widget _buildBarChartIncidentCategory(List<Map<String, dynamic>> data) {
  // Define the category labels (X-axis)
  List<String> categories = data.map((e) => e['category'] as String).toList();
  List<int> counts = data.map((e) => e['count'] as int).toList();

  // Map the data to BarChartGroupData
  List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value['count'].toDouble(),
          color: Colors.red, // You can customize the color
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    child: BarChart(
      BarChartData(
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black, width: 1),
        ),
        gridData: const FlGridData(
          show: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
            axisNameWidget: const Text(
              'Incident Count',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            axisNameSize: 16,
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1, // Ensure titles appear at regular intervals
              getTitlesWidget: (value, meta) {
                int index = value.round(); // Round value to an integer
                if (index >= 0 && index < categories.length) {
                  return Text(
                    categories[index],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text(''); // Return empty for out-of-bounds indices
              },
            ),
            axisNameWidget: const Text(
              'Category',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            axisNameSize: 16,
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide top titles
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide right titles
          ),
        ),
        maxY: (counts.isNotEmpty) ? (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble() : 1,
        barGroups: barGroups,
      ),
    ),
  );
}

Widget _buildPieChartIncidentCategory(List<Map<String, dynamic>> data) {
  List<Color> pieChartColors = Colors.primaries;

  List<PieChartSectionData> pieSections = data.asMap().entries.map((entry) {
    final index = entry.key;
    final value = entry.value;
    final count = value['count'] as int;

    return PieChartSectionData(
      color: pieChartColors[index % pieChartColors.length],
      value: count.toDouble(),
      title: count.toString(),
      radius: 80,
      titleStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }).toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    child: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: data.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final category = value['category'] as String;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pieChartColors[index % pieChartColors.length],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

  String _getDayOfWeek(DateTime date) {
    return date.weekday == DateTime.monday
        ? 'Mon'
        : date.weekday == DateTime.tuesday
            ? 'Tue'
            : date.weekday == DateTime.wednesday
                ? 'Wed'
                : date.weekday == DateTime.thursday
                    ? 'Thu'
                    : date.weekday == DateTime.friday
                        ? 'Fri'
                        : date.weekday == DateTime.saturday
                            ? 'Sat'
                            : 'Sun';
  }
}