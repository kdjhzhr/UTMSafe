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
  String _selectedCategory = 'Select Category';

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

  Stream<int> _fetchCategoryCount(String category) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Future<Map<String, dynamic>> _fetchMostCommonCategoryWithCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('category_counts')
          .orderBy('count', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var categoryDoc = snapshot.docs.first;
        return {
          'category': categoryDoc.id,  // Document ID as category name
          'count': categoryDoc['count'], // Category count
        };
      } else {
        return {'category': 'No data available', 'count': 0};
      }
    } catch (e) {
      debugPrint("Error fetching most common category: $e");
      return {'category': 'Error fetching data', 'count': 0};
    }
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
            // Alert Banner
            FutureBuilder<Map<String, dynamic>>(
              future: _fetchMostCommonCategoryWithCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text("Error loading data");
                }

                final mostCommonCategory = snapshot.data!['category'];
                final count = snapshot.data!['count'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0), child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Centered with some margin
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.red, // Updated alert banner color
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Subtle shadow
                          blurRadius: 6.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center align content
                      children: [
                        const Icon(
                          Icons.warning,
                          color: Colors.yellow, // Updated icon color
                          size: 24.0,
                        ),
                        const SizedBox(width: 12), // Space between icon and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Most Common Incident:',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Text color
                                ),
                              ),
                              Text(
                                '$mostCommonCategory (Count: $count)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // Text color
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Title "Incident Insights"
            const Padding(
  padding: EdgeInsets.only(
    top: 16.0,
    bottom: 16.0,
  ),
  child: Center( // Wrap Text in Center widget
    child: Text(
      'Incident Post and Incident Category Counter',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

            // Row to place filters for post count and graph type in a single row
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center filters
        children: [
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
                child: Text(value, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
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
                child: Text(value, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),
    Flexible(
      child: StreamBuilder<int>(
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
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 8),
    Flexible(
  child: SizedBox(
    width: 120, // Set a fixed width for the dropdown
    child: DropdownButton<String>(
      value: _selectedCategory,
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue!;
        });
      },
      isExpanded: true, // Ensure the dropdown expands within the fixed width
      items: <String>[
        'Select Category',
        'Fire Emergency',
        'Snake Encounter',
        'Monkey Attack',
        'Electric Shock',
        'Minor Accident'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis, // Prevent text overflow
          ),
        );
      }).toList(),
    ),
  ),
),

    const SizedBox(width: 8),
    Flexible(
      child: StreamBuilder<int>(
        stream: _fetchCategoryCount(_selectedCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return const Text("Error loading category count");
          }
          final categoryCount = snapshot.data ?? 0;
          return Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '$categoryCount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
        },
      ),
    ),
  ],
),

            const SizedBox(height: 16),

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