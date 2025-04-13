import 'package:bytebazaar/features/onboarding/controller/onboarding_controller.dart';
import 'package:bytebazaar/features/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:bytebazaar/features/onboarding/widgets/onboarding_get_started.dart';
import 'package:bytebazaar/features/onboarding/widgets/onboarding_next_button.dart';
import 'package:bytebazaar/features/onboarding/widgets/onboarding_page.dart';
import 'package:bytebazaar/features/onboarding/widgets/onboarding_skip.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart'; // Need to create this
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            physics: const BouncingScrollPhysics(),
            children: const [
              OnBoardingPage(
                image: BImages.onBoardingImage1, // Define in BImages
                logo: BImages.onBoardingLogo,    // Define in BImages
                title: BTexts.onBoardingTitle1,
                subTitle: BTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: BImages.onBoardingImage2, // Define in BImages
                logo: BImages.onBoardingLogo,
                title: BTexts.onBoardingTitle2,
                subTitle: BTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: BImages.onBoardingImage3, // Define in BImages
                logo: BImages.onBoardingLogo,
                title: BTexts.onBoardingTitle3,
                subTitle: BTexts.onBoardingSubTitle3,
              ),
              OnBoardingPage( // Special last page
                image: BImages.onBoardingImage4, // Define in BImages
                logo: BImages.onBoardingLogo,
                title: BTexts.onBoardingTitle4,
                subTitle: BTexts.onBoardingSubTitle4,
                isLastPage: true, // Flag for different layout if needed
              ),
            ],
          ),

          /// Skip Button - Hide on last page
          Obx(() => controller.currentPageIndex.value == 3 
              ? const SizedBox() 
              : const OnBoardingSkip()),

          /// Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),

          /// Circular Button (Next or Get Started)
          Obx(() {
            // Show Get Started button only on the last page
            return controller.currentPageIndex.value == 3
                ? const OnBoardingGetStarted()
                : const OnBoardingNextButton();
          }),
        ],
      ),
    );
  }
}
