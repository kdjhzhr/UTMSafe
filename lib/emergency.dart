import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Import Clipboard functionality
import 'studentfeedpage.dart'; // Import FeedPage

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  int _selectedIndex = 1;

  // Sample emergency contacts
  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'Balai Keselamatan', 'phone': '+6075333013'},
    {'name': 'Pusat Kesihatan UTM', 'phone': '+6075530999'},
    {'name': 'Gangguan Haiwan Liar 1', 'phone': '+6075530014'},
    {'name': 'Gangguan Haiwan Liar 2', 'phone': '+6075530002'},
  ];

  // Function to copy phone number to clipboard
  void _copyToClipboard(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone number copied to clipboard.')),
      );
    });
  }

  // Handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FeedPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UTMSafe',
          style: TextStyle(
            color: const Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF5E9D4),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: const [
                Icon(
                  Icons.phone_in_talk,
                  color: Color(0xFF8B0000),
                  size: 28,
                ),
                SizedBox(width: 8),
                Text(
                  'Emergency Contact',
                  style: TextStyle(
                    fontSize: 24,
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
                return ListTile(
                  title: Text(contact['name']!),
                  subtitle: Text(contact['phone']!),
                  trailing: IconButton(
                    icon: Icon(Icons.copy, color: Color(0xFF8B0000)),
                    onPressed: () => _copyToClipboard(contact['phone']!),
                  ),
                );
              },
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
