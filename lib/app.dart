import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/theme/theme.dart';
import 'package:bytebazaar/features/authentication/screens/splash_screen.dart'; 

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteBazaar | Your Marketplace in the Digital Age.',
      theme: BTheme.byteTheme,
      
      home: SplashScreen(), // Use SplashScreen as the home screen
      debugShowCheckedModeBanner: false, // Optional: Remove debug banner
    );
  }
}