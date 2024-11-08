import 'package:flutter/material.dart';
import 'studentfeedpage.dart'; // Make sure to import FeedPage.dart
import 'policefeedpage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E9D4),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? userType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/utmsafelogo.png',
          height: 200,
          width: 200,
        ),
        const SizedBox(height: 24),
        const Text(
          'Log in as:',
          style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        ),
        const SizedBox(height: 16),
        _buildUserTypeOption('UTM Auxiliary Police', 'auxiliary_police'),
        _buildUserTypeOption('UTM Student', 'student'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B0000),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'LOG IN',
            style: TextStyle(fontFamily: 'Roboto', color: Colors.white),
          ),
        ),
        const SizedBox(height: 24),
        Image.asset(
          'assets/loginpic.png',
          height: 150,
          width: 150,
        ),
      ],
    );
  }

  Widget _buildUserTypeOption(String title, String value) {
    return RadioListTile(
      title: Text(title),
      value: value,
      groupValue: userType,
      onChanged: (value) {
        setState(() {
          userType = value;
        });
      },
    );
  }

  void _handleLogin() {
    if (userType == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedPage(), // Navigate to FeedPage for student
        ),
      );
    } else if (userType == 'auxiliary_police') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PoliceInterface()),
      );
    }
  }
}
