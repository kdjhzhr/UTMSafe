import 'package:flutter/material.dart';
import 'studentfeedpage.dart';
import 'policefeedpage.dart';

class WelcomePage extends StatefulWidget {
  final String role;

  const WelcomePage({Key? key, required this.role}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = true;

    // Wait 2 seconds and then start fading out
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisible = false;
      });

      // Navigate to the next page after fading out
      Future.delayed(const Duration(milliseconds: 500), () {
        if (widget.role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FeedPage()),
          );
        } else if (widget.role == 'auxiliary_police') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PoliceInterface()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5E9D4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo with fade out effect
              AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  'assets/utmsafelogo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 50),

              // Animated Text with fade out effect
              AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Your Safety is Our Priority',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
