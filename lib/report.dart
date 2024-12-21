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
  String _chartType = 'Bar Chart';
  String _selectedCategory = 'Category';

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
            
            // Alert Banner with Category Filter and Counter
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
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Alert Banner
          Expanded(
            flex: 2,
            child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8), // Adjust spacing
                      Expanded(
                        child: Text(
                          'Most Common Incident:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Adjust spacing
                  Text(
                    '$mostCommonCategory (Count: $count)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16), // Space between alert and category filter
          // Category Filter and Counter in a Row
          Flexible(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category Filter Dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: <String>[
                      'Category',
                      'Animal Encounter',
                      'Theft',
                      'Fire Emergency',
                      'Road Closure',
                      'Power Outage',
                      'Lost Item',
                      'Medical Emergency',
                      'Transportation Incident',
                      'Infrastructure Failure',
                      'Property Damage'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8), // Adjust spacing between dropdown and counter
                // Category Counter
                StreamBuilder<int>(
                  stream: _fetchCategoryCount(_selectedCategory),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text("Error");
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
              ],
            ),
          ),
        ],
      ),
    );
  },
),

            const Padding(
  padding: EdgeInsets.only(
    top: 16.0,
    bottom: 16.0,
  ),
  child: Center( // Wrap Text in Center widget
    child: Text(
      'Incident Post Overview',
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
            items: <String>['Bar Chart', 'Pie Chart']
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
                  return _chartType == 'Bar Chart'
                      ? _buildBarChart(data, now)
                      : _buildPieChart(data, now);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<int> data, DateTime now) {
  // Generate a list of the past 7 days (formatted as "dd/MM")
  List<String> xLabels = List.generate(7, (index) {
    DateTime date = now.subtract(Duration(days: 6 - index));
    return "${date.day}/${date.month}";
  });

  // Find the maximum value in the data for dynamic scaling
  int maxValue = data.reduce((a, b) => a > b ? a : b);
  int yMax = (maxValue > 0) ? maxValue + 1 : 1; // Ensure a non-zero Y-axis

  // Map the data to BarChartGroupData
  List<BarChartGroupData> barGroups = data
      .asMap()
      .entries
      .map((entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.red,
                width: 15,
                borderRadius: BorderRadius.circular(4),
              )
            ],
          ))
      .toList();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
    child: BarChart(
      BarChartData(
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
                return const Text(''); // Return empty for out-of-bounds indices
              },
            ),
            axisNameWidget: const Text('Dates',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            axisNameSize: 16,
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        maxY: yMax.toDouble(), // Dynamically adjust the Y-axis max value
        barGroups: barGroups,
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
    Colors.yellow, // Saturday
    Colors.teal, // Sunday
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
            // Indicator (Legend) for each day with dates
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(data.length, (index) {
                  if (data[index] > 0) {
                    // Correctly align the weekday with its corresponding date
                    int daysOffset = (index - (now.weekday - 1));
                    DateTime date = now.add(Duration(days: daysOffset));

                    String dateLabel = "${date.day}/${date.month}";

                    return Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: pieChartColors[index], // Day-specific color
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${dayLabels[index]} ($dateLabel)", // Include date
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
}