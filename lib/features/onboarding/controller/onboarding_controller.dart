import 'package:bytebazaar/features/authentication/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Assuming login screen exists

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page.
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Update Current Index & jump to next page
  void nextPage() {
    if (currentPageIndex.value == 3) { // 3 pages (0, 1, 2, 3)
      // Navigate to Login Screen or Home Screen after the last page
      // You might want to add logic here to store that onboarding is completed
      Get.offAll(() => const SplashScreen()); // Navigate and remove previous screens
    } else {
      int page = currentPageIndex.value + 1;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Update Current Index & animate to the last Page
  void skipPage() {
    currentPageIndex.value = 3;
    pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handle Get Started button click on the last page
  void getStarted() {
    // Navigate to Login Screen or Home Screen
    // You might want to add logic here to store that onboarding is completed
    Get.offAll(() => const SplashScreen()); // Navigate and remove previous screens
  }
}
