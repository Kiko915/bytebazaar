// import 'package:bytebazaar/features/authentication/screens/signup_screen.dart'; // Commented out: Assuming signup screen exists
import 'package:bytebazaar/features/onboarding/controller/onboarding_controller.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/device/device_utils.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingGetStarted extends StatelessWidget {
  const OnBoardingGetStarted({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    final controller = OnboardingController.instance;

    return Positioned(
      bottom: BDevice.getBottomNavigationBarHeight() + BSizes.defaultSpace, // Position above bottom nav height + padding
      left: BSizes.defaultSpace,
      right: BSizes.defaultSpace,
      child: Column( // Use Column for button and text below
        mainAxisSize: MainAxisSize.min, // Take minimum space needed
        children: [
          // Get Started Button
          SizedBox(
            width: double.infinity, // Make button full width
            child: ElevatedButton(
              onPressed: () => controller.getStarted(),
              style: ElevatedButton.styleFrom(
                backgroundColor: BColors.white, // White background
                foregroundColor: const Color.fromARGB(255, 33, 88, 177), // Black text
                padding: const EdgeInsets.symmetric(vertical: BSizes.buttonHeight / 3), // Increased vertical padding
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BSizes.buttonRadius)), // Rounded corners
              ),
              child: const Text(BTexts.getStarted, style: TextStyle(fontSize: BSizes.fontSizeLg),),
            ),
          ),
          const SizedBox(height: BSizes.spaceBtwItems / 1.5), // Space between button and text

          // "Don't have an account? Sign Up" Text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                BTexts.dontHaveAccount,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BColors.white.withOpacity(0.8)),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Sign Up Screen
                  // Ensure SignupScreen exists and is imported
                  // Get.offAll(() => const SignupScreen()); // Commented out: Replace previous screens
                  // TODO: Implement navigation to SignupScreen once it's created
                  print("Navigate to Signup Screen"); // Placeholder action
                },
                // Reduce padding/margin for tighter spacing
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: BSizes.xs),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                child: Text(
                  BTexts.signUp,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: BColors.white, // White color for Sign Up
                    fontWeight: FontWeight.bold, // Make it bold
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
