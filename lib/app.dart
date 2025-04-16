import 'package:bytebazaar/features/onboarding/screens/onboarding_screen.dart'; // Import OnboardingScreen
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:bytebazaar/utils/theme/theme.dart';
// import 'package:bytebazaar/features/authentication/screens/splash_screen.dart'; // Comment out or remove SplashScreen import if no longer needed here

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Replace MaterialApp with GetMaterialApp
      title: 'ByteBazaar | Your Marketplace in the Digital Age.',
      theme: BTheme.byteTheme,

      home: const OnboardingScreen(), // Set OnboardingScreen as the home screen
      debugShowCheckedModeBanner: false, // Optional: Remove debug banner
    );
  }
}
