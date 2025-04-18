import 'package:bytebazaar/features/authentication/screens/password_configuration/new_password_screen.dart'; // Import NewPasswordScreen
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart'; // Import Get

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context); // Corrected: THelperFunctions -> BHelperFunctions
    return Scaffold(
      // Set scaffold background to transparent to let the container gradient show
      backgroundColor: Colors.transparent,
      body: SizedBox( // Ensure the container covers the full screen height
        height: MediaQuery.of(context).size.height,
        child: Container(
          // Apply the gradient decoration to the container
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BColors.primary,
                Color.fromARGB(255, 35, 87, 171),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(BSizes.defaultSpace), // Corrected: TSizes -> BSizes
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logo
              Image(
                height: 200, // Adjust height as needed
                image: AssetImage(
                    BImages.splashLogo), // Corrected: TImages -> BImages
              ),
              const SizedBox(height: BSizes.spaceBtwSections), // Corrected: TSizes -> BSizes

              /// White Card Container
              Container(
                padding: const EdgeInsets.all(BSizes.defaultSpace), // Corrected: TSizes -> BSizes
                decoration: BoxDecoration(
                  color: dark ? BColors.darkerGrey : BColors.background, // Corrected: TColors -> BColors
                  borderRadius: BorderRadius.circular(BSizes.cardRadiusLg), // Corrected: TSizes -> BSizes
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// Shield Icon
                    const Image(
                      height: 80,
                      image: AssetImage(BImages.otpVerificationIcon), // Corrected: TImages -> BImages // Use constant
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems), // Corrected: TSizes -> BSizes

                    /// Title & Subtitle
                    Text(
                      BTexts.otpTitle, // Corrected: TTexts -> BTexts
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems / 2), // Corrected: TSizes -> BSizes
                    Text(
                      BTexts.otpSubTitle, // Corrected: TTexts -> BTexts // Assuming email is passed or retrieved
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections), // Corrected: TSizes -> BSizes

                    /// OTP Fields
                    OtpTextField(
                      numberOfFields: 5,
                      borderColor: BColors.primary,
                      focusedBorderColor: BColors.primary,
                      showFieldAsBox: true,
                      fieldWidth: 45,
                      //runs when every textfield is filled
                      onSubmit: (String verificationCode) {
                        // Add logic to verify OTP
                        print("verificationCode: $verificationCode"); // Debug print
                      }, // end onSubmit
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections), // Corrected: TSizes -> BSizes

                    /// Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const NewPasswordScreen()), // Navigate to NewPasswordScreen
                        child: Text(
                          BTexts.verify, // Corrected: TTexts -> BTexts
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: BColors.background), // Set text color explicitly
                        ),
                      ),
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems), // Corrected: TSizes -> BSizes

                    /// Resend Text
                    TextButton(
                      onPressed: () {
                        // Add resend logic
                      },
                      child: const Text(BTexts.resendOtp), // Corrected: TTexts -> BTexts
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BSizes.spaceBtwSections), // Corrected: TSizes -> BSizes

              /// Go Back Button
              TextButton(
                onPressed: () => Get.back(), // Use Get.back()
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.arrow_back_ios, size: BSizes.iconSm, color: BColors.background,), // Corrected: TSizes -> BSizes & Added color
                    SizedBox(width: BSizes.spaceBtwItems / 2), // Corrected: TSizes -> BSizes
                    Text(BTexts.goBack, style: TextStyle(color: BColors.background)), // Corrected: TTexts -> BTexts & Added style
                  ],
                ),
              ),
            ],
          ), // End Column
        ), // End Padding
      ), // End SingleChildScrollView
    ), // End Container
  ), // End SizedBox
); // End Scaffold
  }
}
