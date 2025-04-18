import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:bytebazaar/utils/theme/theme.dart';
// import 'package:bytebazaar/features/authentication/screens/splash_screen.dart'; // Comment out or remove SplashScreen import if no longer needed here

class App extends StatelessWidget {
  final Widget initialScreen; // Add this line

  const App({super.key, required this.initialScreen}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Replace MaterialApp with GetMaterialApp
      title: 'ByteBazaar | Your Marketplace in the Digital Age.',
      theme: BTheme.byteTheme,

      home: initialScreen, // Use the passed initialScreen
      debugShowCheckedModeBanner: false, // Optional: Remove debug banner
    );
  }
}
