import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'loginpage.dart';
import 'policefeedpage.dart';
import 'studentfeedpage.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from your firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app after Firebase is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTMSafe',
      theme: ThemeData(
        // Customize theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const LoginPage(), 
        '/policeFeed': (context) => const PoliceInterface(),
        '/studentFeed': (context) => const FeedPage(), 
      },
    );
  }
}
