import 'package:bytebazaar/features/onboarding/controller/onboarding_controller.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/device/device_utils.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Assuming you use hugeicons for consistency

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    return Positioned(
      right: BSizes.defaultSpace,
      bottom: BDevice.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () async => await OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(BSizes.md), // Adjust padding for size
        ),
        child: Icon(
          HugeIcons.strokeRoundedArrowRight02, // Or Icons.arrow_forward_ios
          color: dark ? BColors.black : BColors.white,
          size: BSizes.iconMd, // Adjust icon size
        ),
      ),
    );
  }
}
