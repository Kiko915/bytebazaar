import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';
import 'package:bytebazaar/utils/local_storage/local_storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  Future<void> nextPage() async {
    if (currentPageIndex.value == 3) {
      // Mark onboarding as completed
      final storage = BLocalStorage();
      await storage.saveData('isFirstTime', false);
      
      // Navigate to Login Screen
      Get.offAll(() => const LoginScreen());
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
  Future<void> getStarted() async {
    // Mark onboarding as completed
    final storage = BLocalStorage();
    await storage.saveData('isFirstTime', false);
    
    // Navigate to Login Screen
    Get.offAll(() => const LoginScreen());
  }
}
