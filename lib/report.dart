import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  // Variables to store the selected time filter for incident posts
  String _timeFilter = 'This Week';

  // Method to count incident posts in Firestore based on the selected time filter
  Stream<int> _fetchIncidentPostCount() {
    DateTime now = DateTime.now();
    DateTime startTime;

    if (_timeFilter == 'Today') {
      startTime = DateTime(now.year, now.month, now.day); // Start of today
    } else {
      startTime =
          now.subtract(const Duration(days: 7)); // Start of the past week
    }

    return FirebaseFirestore.instance
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startTime)
        .snapshots()
        .map((snapshot) => snapshot.size); // Get document count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title above the filter dropdown
            const Text(
              'Incident Posts Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Add space between title and dropdown
            // Dropdown menu for selecting the time filter (Today or This Week)
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
            const SizedBox(height: 32),
            // Display count based on the selected time filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B0000), width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
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
                  return Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
