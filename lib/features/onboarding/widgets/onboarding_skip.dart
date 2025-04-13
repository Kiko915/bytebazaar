import 'package:bytebazaar/features/onboarding/controller/onboarding_controller.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/device/device_utils.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: BDevice.getBottomNavigationBarHeight(),
      left: BSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        child: Text(
          BTexts.skip,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: BColors.white), // Ensure visibility
        ),
      ),
    );
  }
}
