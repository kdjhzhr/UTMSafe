import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:utmsafe/policefeedpage.dart';
import 'firebase_options.dart';
import 'loginpage.dart';
import 'studentfeedpage.dart'; // Import StudentFeedPage
import 'policefeedpage.dart'; // Import SOS page (if you have one)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTMSafe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/student_feed': (context) => const FeedPage(),
        '/sos': (context) =>
            const PoliceInterface(), // Add this route if needed
      },
    );
  }
}
