import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6006FF); // Define the primary color

    return Scaffold(
      backgroundColor: primaryColor, // Use primary color as background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Logo
            Image.asset(
              'assets/logos/ByteBazaar-Icon-NBG.png',
              width: 150, // Adjust size as needed
              height: 150,
            ),
            const SizedBox(height: 30), // Spacing between logo and text

            // Text with modern styling
            Text(
              'ByteBazaar',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Change text color to white
                letterSpacing: 1.2, // Add some letter spacing
              ),
            ),
            const SizedBox(height: 10), // Spacing between title and subtitle
            Text(
              'will rise here',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300, // Lighter font weight
                color: Colors.white.withOpacity(0.8), // Lighter white for subtitle
              ),
            ),
          ],
        ),
      ),
    );
  }
}
