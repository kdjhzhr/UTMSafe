import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  String? userType;
  final String auxiliaryPoliceCode =
      '12345'; // Security code for auxiliary police
  bool passwordVisible = false;

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
              // Role selection at the top
              const Text('Select Role:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              _buildRoleCard('UTM Auxiliary Police', 'auxiliary_police'),
              const SizedBox(height: 16),
              _buildRoleCard('UTM Student', 'student'),
              const SizedBox(height: 24),
              _buildTextField('Full Name', fullNameController),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', phoneController),
              const SizedBox(height: 16),
              _buildTextField('Email', emailController),
              const SizedBox(height: 16),
              _buildPasswordField('Password', passwordController),
              const SizedBox(height: 16),
              // Show code input only if the user is auxiliary police
              if (userType == 'auxiliary_police') ...[
                _buildTextField('Enter Code', codeController),
                const SizedBox(height: 16),
              ],

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

  // Helper method for the password field with visibility toggle
// Helper method for the password field with visibility toggle and instructions
  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: !passwordVisible,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(
              Icons.lock,
              color: Color(0xFF8B0000),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF8B0000),
              ),
              onPressed: () {
                setState(() {
                  passwordVisible = !passwordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B0000)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Password must be at least 6 characters long.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == 'Password'
              ? Icons.lock
              : label == 'Phone Number'
                  ? Icons.phone
                  : Icons.email,
          color: const Color(0xFF8B0000),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B0000)),
        ),
      ),
    );
  }

  // Helper method to build the role selection cards
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
              ),
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
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final code = codeController.text.trim();
    // Derive username from email
    final username = email.split('@')[0];

    // Validate input fields
    if (fullName.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        userType == null ||
        (userType == 'auxiliary_police' && code.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (userType == 'auxiliary_police' && code != auxiliaryPoliceCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code for auxiliary police')),
      );
      return;
    }

    try {
      // Register user in Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'full_name': fullName,
        'phone': phone,
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
