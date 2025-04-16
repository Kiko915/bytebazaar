import 'package:bytebazaar/features/authentication/screens/otp/otp_verification_screen.dart'; // Import OTPScreen
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
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
            padding: const EdgeInsets.all(BSizes.defaultSpace),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: BSizes.spaceBtwSections + 20),
              /// Logo
              Image(
                height: 200,
                image: AssetImage(BImages.splashLogo),
              ),
              const SizedBox(height: BSizes.spaceBtwSections),

              /// White Card Container
              Container(
                padding: const EdgeInsets.all(BSizes.defaultSpace),
                decoration: BoxDecoration(
                  color: dark ? BColors.darkerGrey : BColors.background,
                  borderRadius: BorderRadius.circular(BSizes.cardRadiusLg),
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
                    /// Key Icon
                    const Image(
                      height: 80,
                      image: AssetImage(BImages.passwordKeyIcon),
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems),

                    /// Title & Subtitle
                    Text(
                      BTexts.forgotPasswordTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems / 2),
                    Text(
                      BTexts.forgotPasswordSubTitle,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),

                    /// Email Text Field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: BTexts.email,
                      ),
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),

                    /// Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const OTPScreen()), // Navigate to OTPScreen
                        child: Text(
                          BTexts.submit,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: BColors.background), // Set text color explicitly
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BSizes.spaceBtwSections),

              /// Go Back Button
              TextButton(
                onPressed: () => Get.back(), // Use Get.back()
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_back_ios, size: BSizes.iconSm, color: BColors.background,),
                    SizedBox(width: BSizes.spaceBtwItems / 2),
                    Text(BTexts.goBack, style: TextStyle(color: BColors.background),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ), // End SingleChildScrollView
    ), // End Container
   ), // End SizedBox
  ); // End Scaffold
  }
}
