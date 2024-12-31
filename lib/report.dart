import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'commonincident.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String mainDropdownValue = 'Incident Post';
  String timeFilterValue = 'Today';
  String chartTypeValue = 'Bar Chart';
  String _selectedCategory = 'Category';

  Future<Map<String, dynamic>> _fetchMostCommonCategoryWithCount() async {
    DateTime now = DateTime.now();
    // Always use the last 7 days, regardless of timeFilterValue
    DateTime startTime = now.subtract(const Duration(days: 7));

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
      return {'category': 'No incidents', 'count': 0};
    }

    String mostCommonCategory =
        categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'category': mostCommonCategory,
      'count': categoryCounts[mostCommonCategory]!
    };
  }

  Stream<List<int>> _fetchIncidentPostData() async* {
    DateTime now = DateTime.now();
    DateTime startTime = timeFilterValue == 'Today'
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
    DateTime startTime = timeFilterValue == 'Today'
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

      // Ensure we always return a list, even if empty
      final result = categoryCounts.entries
          .map((e) => {'category': e.key, 'count': e.value})
          .toList();

      // If no data, yield a default "No Data" entry
      yield result.isNotEmpty
          ? result
          : [
              {'category': 'No Data', 'count': 0}
            ];
    }
  }

// Method to fetch category count for the last 7 days
  Stream<int> _fetchCategoryCount(String category) async* {
    // Skip fetching if the category is the default "Category"
    if (category == 'Category') {
      yield 0;
      return;
    }

    try {
      // Reference to the category_count collection
      DocumentReference categoryDoc = FirebaseFirestore.instance
          .collection('category_counts')
          .doc(category);

      // Listen for changes to the document
      yield* categoryDoc.snapshots().map((snapshot) {
        if (snapshot.exists) {
          // Cast the data to a Map<String, dynamic>
          final data = snapshot.data() as Map<String, dynamic>;
          print('Fetched data for $category: $data'); // Debugging output
          return data['count'] ?? 0; // Default to 0 if count field is missing
        } else {
          // Document does not exist
          print('Document for $category does not exist.');
          return 0;
        }
      });
    } catch (e) {
      print('Error fetching category count: $e');
      yield 0; // Return 0 in case of error
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Incident Activity Report',
              style: TextStyle(
                fontSize: 24, // Adjust size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black, // Change color if needed
              ),
            ),
            SizedBox(height: 16),

            // Row to separate alert banner and category filter
            Row(
              children: [
                // Alert Banner (Expanded to take most of the space)
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchMostCommonCategoryWithCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Container(
                          color: Colors.red.shade100,
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      return _buildAlertBanner(
                          snapshot.data!['category'], snapshot.data!['count']);
                    },
                  ),
                ),

                // Inside the build method, modify the category filter section
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Smaller Category Filter Dropdown
                      DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text('Category', style: TextStyle(fontSize: 10)),
                        iconSize: 16, // Smaller dropdown icon
                        style: TextStyle(
                            fontSize: 10, color: Colors.black), // Smaller text
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
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
                              style: TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),

                      // Larger Counter
                      StreamBuilder<int>(
                        stream: _fetchCategoryCount(_selectedCategory),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade500),
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                'Error',
                                style: TextStyle(
                                    color: Colors.red.shade700, fontSize: 12),
                              ),
                            );
                          }

                          final categoryCount = snapshot.data ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryCount > 0
                                  ? Colors.red.shade100
                                  : Colors.grey.shade200,
                              border: Border.all(
                                color: categoryCount > 0
                                    ? Colors.red
                                    : Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$categoryCount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: categoryCount > 0
                                    ? Colors.red.shade800
                                    : Colors.grey.shade700,
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
            _buildDropdowns(),
            const SizedBox(height: 16),
            Expanded(child: _buildChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0), // Adjust the value as needed
      child: Row(
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
            items: ['Today', 'Week']
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
      ),
    );
  }

  Widget _buildAlertBanner(String category, int count) {  
    Color bannerColor = count > 0 ? Colors.blue.shade100 : Colors.grey.shade200;  
    IconData icon = count > 0 ? Icons.warning_outlined : Icons.info_outline;  
    Color iconColor = count > 0 ? Colors.yellow : Colors.grey;  

    return GestureDetector(  
      onTap: count > 0   
        ? () {  
            Navigator.push(  
              context,  
              MaterialPageRoute(  
                builder: (context) => FilteredPostsPage(category: category),  
              ),  
            );  
          }  
        : null,  
      child: Container(  
        width: double.infinity,  
        padding: const EdgeInsets.all(12.0),  
        decoration: BoxDecoration(  
          color: bannerColor,  
          borderRadius: BorderRadius.circular(8.0),  
        ),  
        child: Row(  
          children: [  
            Icon(icon, color: iconColor),  
            const SizedBox(width: 12),  
            Expanded(  
              child: RichText(  
                text: TextSpan(  
                  style: const TextStyle(color: Colors.black87),  
                  children: [  
                    const TextSpan(  
                      text: 'Most Common Incident This Week: ',  
                      style: TextStyle(fontWeight: FontWeight.bold),  
                    ),  
                    TextSpan(  
                      text: category,  
                      style: TextStyle(  
                        fontWeight: FontWeight.bold,  
                        color: count > 0 ? Colors.red : Colors.grey,  
                      ),  
                    ),  
                    if (count > 0)  
                      TextSpan(  
                        text: ' (Count: $count)',  
                        style: const TextStyle(  
                            color: Color.fromARGB(255, 48, 47, 47)),  
                      ),  
                  ],  
                ),  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }

  Widget _buildBarChartIncidentPost(List<int> data, DateTime now) {
    // Check if all data points are zero
    bool hasNoData = data.every((count) => count == 0);

    // If no data, return the "No incident data available" message
    if (hasNoData) {
      return const Center(
        child: Text(
          'No incident data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Define days of the week
    List<String> xLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Calculate total posts
    int totalPosts = data.reduce((a, b) => a + b);

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
      child: Stack(
        children: [
          BarChart(
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
                  sideTitles:
                      SideTitles(showTitles: false), // Hide right titles
                ),
              ),
              maxY: yMax.toDouble(), // Dynamically adjust the Y-axis max value
              barGroups: barGroups,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Total = $totalPosts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
    // Handle no data scenario
    if (data.isEmpty || (data.length == 1 && data[0]['count'] == 0)) {
      return const Center(
        child: Text(
          'No incident data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Define the category labels (X-axis)
    List<String> categories = data.map((e) => e['category'] as String).toList();
    List<int> counts = data.map((e) => e['count'] as int).toList();

    // Calculate total posts
    int totalPosts = counts.reduce((a, b) => a + b);

    // Map the data to BarChartGroupData
    List<BarChartGroupData> barGroups = data.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value['count'].toDouble(),
            color: Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Stack(
        children: [
          BarChart(
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
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.round();
                      if (index >= 0 && index < categories.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 3, // Rotate 270 degrees
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                fontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 60, // Increased to accommodate rotated labels
                  ),
                  axisNameWidget: const Text(
                    'Category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  axisNameSize: 16,
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              maxY: (counts.isNotEmpty)
                  ? (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble()
                  : 1,
              barGroups: barGroups,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Total = $totalPosts',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartIncidentCategory(List<Map<String, dynamic>> data) {
    // Check if data is empty or all counts are zero
    bool hasNoData = data.isEmpty || data.every((item) => item['count'] == 0);

    // If no data, return the "No data to display" message
    if (hasNoData) {
      return const Center(child: Text("No data to display"));
    }

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
