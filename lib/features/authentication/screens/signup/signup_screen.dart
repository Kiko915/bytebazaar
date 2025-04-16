import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart'; // Added import
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 72, 150),
      body: Stack( // Use Stack as the direct body
        children: [
          // Background Image Widget as first layer, filling the stack
          Positioned.fill(
            child: Image.asset(
              BImages.authBg,
              fit: BoxFit.fill, // Force fill the bounds/ Blend mode for tinting
            ),
          ),

          // Positioned Hero Image
          Positioned(
            top: BSizes.appBarHeight * 1.5,
            left: BSizes.defaultSpace,
            right: BSizes.defaultSpace,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  height: BHelperFunctions.screenHeight() * 0.3, // Adjust height as needed
                  image: const AssetImage(BImages.authWelcome),
                ),
              ],
            ),
          ),

          // Positioned Form Container (fills bottom part)
          Positioned(
            top: BHelperFunctions.screenHeight() * 0.4, // Start below hero image
            left: 0,
            right: 0,
            bottom: 0, // Extend to bottom
            child: Container(
              decoration: BoxDecoration(
                color: dark ? BColors.darkGrey : BColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(BSizes.cardRadiusLg * 1.5),
                  topRight: Radius.circular(BSizes.cardRadiusLg * 1.5),
                ),
              ),
              // Make content scrollable inside the container
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: BSizes.xl,
                    left: BSizes.defaultSpace,
                    right: BSizes.defaultSpace,
                    bottom: BSizes.defaultSpace,
                  ),
                  child: Column(
                    children: [
                      // Tag Icon
                      const Image(
                        height: 100, // Adjust size as needed
                        image: AssetImage(BImages.authTagIcon),
                      ),
                      const SizedBox(height: BSizes.spaceBtwItems),

                      // Title & Subtitle
                      Text(BTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: BSizes.sm / 2),
                      Text(BTexts.signupSubTitle, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: BSizes.spaceBtwSections),

                      // --- Signup Form ---
                      Form(
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(labelText: BTexts.email),
                            ),
                            const SizedBox(height: BSizes.spaceBtwInputFields),
                            TextFormField(
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: BTexts.password,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwInputFields),
                            TextFormField(
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: BTexts.confirmPassword,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                // Added style for height
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                                child: const Text(BTexts.createAccount, style: TextStyle(fontSize: BSizes.fontSizeMd)),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Divider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(child: Divider(color: dark ? BColors.darkGrey : BColors.grey, thickness: 0.5, indent: 60, endIndent: 5)),
                                Text(BTexts.orContinueWith, style: Theme.of(context).textTheme.labelMedium),
                                Flexible(child: Divider(color: dark ? BColors.darkGrey : BColors.grey, thickness: 0.5, indent: 5, endIndent: 60)),
                              ],
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Google Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {},
                                // Added style for height
                                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Image(image: AssetImage(BImages.google), width: BSizes.iconMd, height: BSizes.iconMd),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(BTexts.alreadyHaveAccount, style: Theme.of(context).textTheme.bodySmall),
                                TextButton(
                                  // Changed navigation to LoginScreen
                                  onPressed: () => Get.to(() => const LoginScreen()),
                                  child: const Text(BTexts.logIn),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
