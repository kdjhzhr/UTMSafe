import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'quiz.dart'; // Import the quiz.dart file
import 'studentfeedpage.dart'; // Import the FeedPage
import 'safety.dart'; // Import the safety.dart file for EarlyMeasurementPage

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  int _selectedIndex = 1;

  // Emergency contacts
  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'Balai Keselamatan', 'phone': '+6075333013'},
    {'name': 'Pusat Kesihatan UTM', 'phone': '+6075530999'},
    {'name': 'Gangguan Haiwan Liar 1', 'phone': '+6075530014'},
    {'name': 'Gangguan Haiwan Liar 2', 'phone': '+6075530002'},
  ];

  // Function to copy a phone number to the clipboard
  void _copyToClipboard(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number copied to clipboard.')),
      );
    });
  }

  // Handle bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FeedPage()), // Feed Page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UTMSafe',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF5E9D4),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Emergency Contact Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.phone_in_talk,
                  color: Color(0xFF8B0000),
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Emergency Contact',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = _emergencyContacts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(contact['name']!),
                      subtitle: Text(contact['phone']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF8B0000)),
                        onPressed: () => _copyToClipboard(contact['phone']!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Divider Line between Emergency Contact and Safety Tips
          const Divider(
            color: Color(0xFF8B0000), // Divider color
            thickness: 2, // Divider thickness
            indent: 16, // Indentation to align with other content
            endIndent: 16, // Indentation to align with other content
          ),

          // Reduced space from the divider line to the next section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0), // Reduced vertical space
            child: Column(
              children: [
                const Text(
                  'Already called help? What need to do while waiting for help to come?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EarlyMeasurementPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Take this early measurement tips',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 2), // Reduced height between the text and the button
                const Text(
                  'Think you know how to stay safe? Test your knowledge with this safety quiz!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10), // Adjusted height to bring the button closer
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafetyQuizPage(), // Navigate to the quiz page
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B0000), // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Padding inside the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Take safety quiz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E9D4),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B0000),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
        ],
      ),
    );
  }
}
