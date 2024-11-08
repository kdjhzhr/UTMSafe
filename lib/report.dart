import 'package:flutter/material.dart'; // Importing Flutter material library for building the UI components.
import 'package:cloud_firestore/cloud_firestore.dart'; // Importing Firestore to interact with the Firestore database.

class Report extends StatefulWidget {
  // Stateful widget to represent the main screen for displaying and filtering incident posts.
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState(); // Creates the mutable state for this widget.
}

class _ReportState extends State<Report> {
  // Variable to store the selected time filter for incident posts (default is 'This Week').
  String _timeFilter = 'This Week';

  // Method to count incident posts in Firestore based on the selected time filter.
  Stream<int> _fetchIncidentPostCount() {
    DateTime now = DateTime.now(); // Get the current date and time.
    DateTime startTime;

    // Determine the start time based on the selected filter option.
    if (_timeFilter == 'Today') {
      startTime = DateTime(now.year, now.month, now.day); // Start of the current day.
    } else {
      startTime = now.subtract(const Duration(days: 7)); // Start of the past week.
    }

    // Query Firestore to get posts where 'timestamp' is greater than or equal to the start time.
    return FirebaseFirestore.instance
        .collection('posts') // Reference the 'posts' collection.
        .where('timestamp', isGreaterThanOrEqualTo: startTime) // Filter documents by timestamp.
        .snapshots() // Listen for real-time updates.
        .map((snapshot) => snapshot.size); // Map the result to the count of documents.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center-align child widgets vertically.
          children: [
            // Title displayed above the dropdown menu.
            const Text(
              'Incident Posts Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // Space between the title and the dropdown menu.

            // Dropdown menu for selecting the time filter (Today or This Week).
            DropdownButton<String>(
              value: _timeFilter, // The current selected value.
              onChanged: (newValue) {
                // Update the state with the new selected value.
                setState(() {
                  _timeFilter = newValue!;
                });
              },
              items: <String>['Today', 'This Week'] // Dropdown options.
                  .map<DropdownMenuItem<String>>((String value) {
                // Create a dropdown item for each option.
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value), // Display text for the dropdown item.
                );
              }).toList(),
            ),
            const SizedBox(height: 32), // Space between the dropdown and the count display.

            // Container displaying the count based on the selected time filter.
            Container(
              padding: const EdgeInsets.all(16), // Padding around the container content.
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8B0000), width: 2.0), // Red border around the container.
                borderRadius: BorderRadius.circular(8.0), // Rounded corners.
              ),
              // StreamBuilder to display real-time data updates.
              child: StreamBuilder<int>(
                stream: _fetchIncidentPostCount(), // The data source for the StreamBuilder.
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator if data is still being fetched.
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    // Show an error message if there was an error loading data.
                    return const Text("Error loading count");
                  }
                  // Get the count value or default to 0 if null.
                  final count = snapshot.data ?? 0;
                  return Text(
                    count.toString(), // Display the count as a string.
                    style: const TextStyle(
                      fontSize: 48, // Large font size for the count.
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
