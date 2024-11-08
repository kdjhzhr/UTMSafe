import 'package:flutter/material.dart';
import 'studentfeedpage.dart'; // Import the Student FeedPage for student navigation
import 'policefeedpage.dart'; // Import the Police FeedPage for auxiliary police navigation

// This is the main LoginPage widget where users will see the login interface
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5E9D4), // Background color for the login page
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), // Add padding around the login form
          child: const LoginForm(), // Display the LoginForm widget
        ),
      ),
    );
  }
}

// This widget handles the login form functionality, including user selection and login button
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String?
      userType; // Stores the selected user type (either student or auxiliary police)

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Center the form elements vertically
      children: [
        // Display the UTMSafe logo
        Image.asset(
          'assets/utmsafelogo.png',
          height: 200,
          width: 200,
        ),
        const SizedBox(height: 24), // Add space below the logo
        const Text(
          'Log in as:', // Label prompting user to select a role
          style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        ),
        const SizedBox(height: 16), // Space between label and user options
        _buildUserTypeOption('UTM Auxiliary Police',
            'auxiliary_police'), // Option for auxiliary police role
        _buildUserTypeOption(
            'UTM Student', 'student'), // Option for student role
        const SizedBox(height: 24), // Space between options and login button

        // Login button which calls _handleLogin when pressed
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000), // Set button color
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 12), // Button padding
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(24), // Rounded corners for the button
            ),
          ),
          child: const Text(
            'LOG IN',
            style: TextStyle(
                fontFamily: 'Roboto', color: Colors.white), // Button text style
          ),
        ),
        const SizedBox(height: 24), // Space below the login button

        // Display an additional image below the login button
        Image.asset(
          'assets/loginpic.png',
          height: 150,
          width: 150,
        ),
      ],
    );
  }

  // Helper widget to build radio button options for user type selection
  Widget _buildUserTypeOption(String title, String value) {
    return RadioListTile(
      title: Text(title), // Display title (e.g., UTM Auxiliary Police)
      value: value, // Set the value for the radio button
      groupValue: userType, // Associate with the selected userType
      onChanged: (value) {
        setState(() {
          userType =
              value as String?; // Update userType when option is selected
        });
      },
    );
  }

  // Handles the login action based on the selected user type
  void _handleLogin() {
    if (userType == 'student') {
      // Navigate to the student FeedPage if user type is student
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedPage(), // FeedPage for students
        ),
      );
    } else if (userType == 'auxiliary_police') {
      // Navigate to the police interface if user type is auxiliary police
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const PoliceInterface(), // Police interface page
        ),
      );
    }
  }
}
