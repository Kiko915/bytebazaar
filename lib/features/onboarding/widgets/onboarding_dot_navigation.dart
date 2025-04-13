import 'package:bytebazaar/features/onboarding/controller/onboarding_controller.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;

    return Positioned(
      // Position dots in the center vertically, above the title
      top: MediaQuery.of(context).size.height * 0.50,
      left: BSizes.defaultSpace,
      right: BSizes.defaultSpace, // Center the dots
      child: Center( // Ensure dots are centered horizontally
        child: SmoothPageIndicator(
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 4, // Total number of onboarding pages
          effect: ExpandingDotsEffect(
            activeDotColor: BColors.primary,
            dotHeight: 6,
            dotWidth: 6, // Make dots smaller
            expansionFactor: 2, // Control expansion size
            dotColor: BColors.white.withOpacity(0.5), // Inactive dot color
          ),
        ),
      ),
    );
  }
}
