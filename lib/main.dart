import 'package:bytebazaar/screens/splash_screen.dart'; // Import the splash screen
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import generated options

void main() async { // Make main asynchronous
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await Firebase.initializeApp( // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(), // Use SplashScreen as the home screen
      debugShowCheckedModeBanner: false, // Optional: Remove debug banner
    );
  }
}
