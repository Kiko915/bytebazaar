
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:iconsax/iconsax.dart';

class NewPasswordScreen extends StatefulWidget { // Changed to StatefulWidget
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> { // Added State class
  bool _obscurePassword = true; // State for password field
  bool _obscureConfirmPassword = true; // State for confirm password field
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              /// Logo
              Image(
                height: 200,
                image: AssetImage(
                    BImages.splashLogo), // Changed to splash logo
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
                      BTexts.setPasswordTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwItems / 2),
                    Text(
                      BTexts.setPasswordSubTitle,
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),

                    /// Password Text Field
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword, // Use state variable
                            decoration: InputDecoration(
                              labelText: BTexts.password,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Iconsax.eye_slash : Iconsax.eye),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword; // Toggle state
                                  });
                                },
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Password required' : null,
                          ),
                          const SizedBox(height: BSizes.spaceBtwInputFields),
                          /// Confirm Password Text Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword, // Use state variable
                            decoration: InputDecoration(
                              labelText: BTexts.confirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword; // Toggle state
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Confirm password required';
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: BSizes.spaceBtwSections),
                          /// Update Button
                          Obx(() => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            final error = await _authController.updatePassword(_passwordController.text.trim());
                                            if (error == null) {
                                              BFeedback.show(context, title: 'Success', message: 'Password updated!', type: BFeedbackType.success);
                                            } else {
                                              BFeedback.show(context, title: 'Update Failed', message: error ?? 'Unknown error', type: BFeedbackType.error);
                                            }
                                          }
                                        },
                                  child: _authController.isLoading.value
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          BTexts.update,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: BColors.background),
                                        ),
                                ),
                              )),
                        ],
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
                  children: [
                    Icon(Icons.arrow_back_ios, size: BSizes.iconSm, color: BColors.background,), // Added color
                    SizedBox(width: BSizes.spaceBtwItems / 2),
                    Text(BTexts.goBack, style: TextStyle(color: BColors.background)), // Added style
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
