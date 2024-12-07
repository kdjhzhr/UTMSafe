import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Account'),
        backgroundColor: const Color(0xFFF5E9D4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User input field
              _buildTextField('Username', usernameController),
              const SizedBox(height: 16),
              _buildTextField('Email', emailController),
              const SizedBox(height: 16),
              _buildTextField('Password', passwordController,
                  obscureText: true),
              const SizedBox(height: 16),

              const Text('Select Role:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),

              // Interactive Role Selection
              _buildRoleCard('UTM Auxiliary Police', 'auxiliary_police'),
              const SizedBox(height: 16),
              _buildRoleCard('UTM Student', 'student'),
              const SizedBox(height: 24),

              // Register Button
              ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: Icon(
            label == 'Password' ? Icons.lock : Icons.account_circle,
            color: const Color(0xFF8B0000),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B0000)),
          ),
        ),
      ),
    );
  }

  // Helper method to build the role selection cards without assets
  Widget _buildRoleCard(String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          userType = value;
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: userType == value ? Colors.lightBlueAccent : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                value == 'auxiliary_police' ? Icons.security : Icons.school,
                color: userType == value ? Colors.white : Colors.black,
                size: 30,
              ), // Using icons based on role
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: userType == value ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to register the user in Firebase
  void _registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        userType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Check if the username is unique
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
        return;
      }

      // Register user in Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'username': username,
        'email': email,
        'role': userType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pop(context); // Navigate back to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
