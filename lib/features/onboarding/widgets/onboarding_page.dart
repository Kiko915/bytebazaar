import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.logo,
    required this.title,
    required this.subTitle,
    this.isLastPage = false, // Default to false
  });

  final String image, logo, title, subTitle;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions directly from context
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover, // Cover the whole screen
        ),
      ),
      child: Container( // Add overlay for better text visibility
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1), // Slight dimming at top
              Colors.black.withOpacity(0.6), // More dimming towards bottom
            ],
          ),
        ),
        padding: const EdgeInsets.all(BSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            // Logo - Positioned higher
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.3), // Adjust spacing as needed
              child: Image(
                width: screenWidth * 0.4, // Adjust size as needed
                image: AssetImage(logo),
              ),
            ),
            const Spacer(flex: 2), // Pushes content down

            const SizedBox(height: BSizes.spaceBtwItems * 4), // Space for dots

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: BColors.white, // Ensure text is visible on image
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0, // Add space between letters
                  ),
              textAlign: TextAlign.center,

            ),
            const SizedBox(height: BSizes.spaceBtwItems),

            // SubTitle
            Padding(
              padding: EdgeInsets.zero, // Remove horizontal padding for left alignment
              child: Text(
                subTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: BColors.white.withOpacity(0.9), // Slightly less prominent
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 5), // Pushes content up from bottom elements (like buttons/dots)
          ],
        ),
      ),
    );
  }
}
