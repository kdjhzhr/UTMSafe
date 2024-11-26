import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String _timeFilter = 'This Week';
  String _chartType = 'Line Chart';

  // Fetches incident post counts for graph data.
  Stream<List<int>> _fetchIncidentPostData() async* {
    DateTime now = DateTime.now();
    DateTime startTime;

    // Set the start time based on the selected filter (Today or This Week)
    if (_timeFilter == 'Today') {
      startTime = DateTime(now.year, now.month, now.day); // Midnight today
    } else {
      startTime = now.subtract(const Duration(days: 7)); // 7 days ago
    }

    await for (var snapshot in FirebaseFirestore.instance
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .snapshots()) {
      final countsPerDay = List.generate(7, (_) => 0); // 7 days for the week

      for (var doc in snapshot.docs) {
        if (doc['timestamp'] != null) {
          DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
          int index = now.difference(timestamp).inDays;

          if (index >= 0 && index < 7) {
            // Get the weekday of the post's timestamp (0 = Monday, 6 = Sunday)
            int dayOfWeek =
                timestamp.weekday - 1; // Convert to 0 (Mon) to 6 (Sun)
            if (dayOfWeek < 0) dayOfWeek = 6; // Adjust if it's Sunday (7th day)

            // Add to the corresponding day of the week
            countsPerDay[dayOfWeek] += 1;
          }
        }
      }
      yield countsPerDay; // Return the updated counts per day for the chart
    }
  }

  // Method to count incident posts in Firestore based on the selected time filter.
  Stream<int> _fetchIncidentPostCount() {
    DateTime now = DateTime.now();
    DateTime startTime;

    if (_timeFilter == 'Today') {
      startTime = DateTime(now.year, now.month, now.day);
    } else {
      startTime = now.subtract(const Duration(days: 7));
    }

    return FirebaseFirestore.instance
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title for Incident Post Count (Moved higher)
            const Padding(
              padding: EdgeInsets.only(
                  top: 16.0, bottom: 16.0), // Increased top padding
              child: Text(
                'Incident Posts Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Display filters and incident post count (Centered)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content
              children: [
                // Filters and count value centered
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center filters
                  children: [
                    // Time Filter Dropdown (Today or This Week)
                    DropdownButton<String>(
                      value: _timeFilter,
                      onChanged: (newValue) {
                        setState(() {
                          _timeFilter = newValue!;
                        });
                      },
                      items: <String>['Today', 'This Week']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Chart Type Dropdown (Line Chart or Pie Chart)
                    DropdownButton<String>(
                      value: _chartType,
                      onChanged: (newValue) {
                        setState(() {
                          _chartType = newValue!;
                        });
                      },
                      items: <String>['Line Chart', 'Pie Chart']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Incident Post Count
                StreamBuilder<int>(
                  stream: _fetchIncidentPostCount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text("Error loading count");
                    }
                    final count = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.red,
                            width: 2), // Red border with 2px width
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: Text(
                        '$count', // Display count
                        style: const TextStyle(
                          fontSize: 36, // Adjusted font size
                          fontWeight: FontWeight.bold,
                          color:
                              Colors.black, // Text color inside the container
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Graph (Line or Pie) Display
            Expanded(
              child: StreamBuilder<List<int>>(
                stream: _fetchIncidentPostData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Text("Error loading data");
                  }
                  final data = snapshot.data!;
                  return _chartType == 'Line Chart'
                      ? _buildLineChart(data, now)
                      : _buildPieChart(data, now);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<int> data, DateTime now) {
    // Define days of the week
    List<String> xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Find the maximum value in the data for dynamic scaling
    int maxValue = data.reduce((a, b) => a > b ? a : b);
    int yMax = (maxValue > 0) ? maxValue + 1 : 1; // Ensure a non-zero Y-axis

    // Map the data to FlSpot
    List<FlSpot> spots = data
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.toDouble(),
            ))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(
              show: true, border: Border.all(color: Colors.black, width: 1)),
          gridData: const FlGridData(
              show: true, horizontalInterval: 1, verticalInterval: 1),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(value.toInt().toString(),
                        style: const TextStyle(fontSize: 12));
                  }),
              axisNameWidget: const Text('Incident Post Count',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              axisNameSize: 16,
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Ensure titles appear at regular intervals
                getTitlesWidget: (value, meta) {
                  int index = value.round(); // Round value to an integer
                  if (index >= 0 && index < xLabels.length) {
                    return Text(xLabels[index],
                        style: const TextStyle(fontSize: 12));
                  }
                  return const Text(
                      ''); // Return empty for out-of-bounds indices
                },
              ),
              axisNameWidget: const Text('Days',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              axisNameSize: 16,
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          maxY: yMax.toDouble(), // Dynamically adjust the Y-axis max value
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List<int> data, DateTime now) {
    List<Color> pieChartColors = [
      Colors.blue, // Monday
      Colors.green, // Tuesday
      Colors.orange, // Wednesday
      Colors.red, // Thursday
      Colors.purple, // Friday
      Colors.teal, // Saturday
      Colors.yellow, // Sunday
    ];

    List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<PieChartSectionData> pieSections = [];

    // Create pie chart sections
    for (int i = 0; i < data.length; i++) {
      if (data[i] > 0) {
        pieSections.add(PieChartSectionData(
          color: pieChartColors[i], // Assign each day a different color
          value: data[i].toDouble(),
          title: "${data[i]}", // Display count in the chart section
          radius: 50,
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
        : Column(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2, // Space between sections
                  ),
                ),
              ),
              // Indicator (Legend) for each day
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(data.length, (index) {
                    if (data[index] > 0) {
                      return Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            color: pieChartColors[index], // Day-specific color
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dayLabels[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 16),
                        ],
                      );
                    } else {
                      return const SizedBox(); // Skip empty days
                    }
                  }),
                ),
              ),
            ],
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
