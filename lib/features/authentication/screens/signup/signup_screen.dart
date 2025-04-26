import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart'; // Added import
import 'package:bytebazaar/features/authentication/screens/signup/registration_screen.dart'; // Import RegistrationScreen
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  double _passwordStrength = 0.0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;

  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
  if (password.isEmpty) return 0.0;
  double strength = 0;
  if (password.length >= 8) strength += 0.3;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
  if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
  if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
  if (RegExp(r'[!@#\$&*~_\-]').hasMatch(password)) strength += 0.15;
  return strength.clamp(0.0, 1.0);
}

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: BTexts.email),
                              validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
},
                            ),
                            const SizedBox(height: BSizes.spaceBtwInputFields),
                            TextFormField(
                              controller: _passwordController,
                              onChanged: (value) {
                                setState(() {
                                  _passwordStrength = _calculatePasswordStrength(value);
                                  if (_passwordStrength < 0.4) {
                                    _passwordStrengthLabel = 'Weak';
                                    _passwordStrengthColor = Colors.red;
                                  } else if (_passwordStrength < 0.8) {
                                    _passwordStrengthLabel = 'Medium';
                                    _passwordStrengthColor = Colors.orange;
                                  } else {
                                    _passwordStrengthLabel = 'Strong';
                                    _passwordStrengthColor = Colors.green;
                                  }
                                });
                              },
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: BTexts.password,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain an uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain a lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain a number';
  }
  if (!RegExp(r'[!@#\$&*~_\-]').hasMatch(value)) {
    return 'Password must contain a special character';
  }
  return null;
},
                            ),
                            const SizedBox(height: BSizes.spaceBtwInputFields),
                            // Password Strength Bar
                            if (_passwordController.text.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    borderRadius: BorderRadius.circular(BSizes.cardRadiusLg),
                                    value: _passwordStrength,
                                    minHeight: 7,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _passwordStrengthLabel,
                                    style: TextStyle(
                                      color: _passwordStrengthColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: BTexts.confirmPassword,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Confirm password is required';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                if (value.length < 8) {
                                  return 'Confirm password must be at least 8 characters';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Confirm password must contain an uppercase letter';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Confirm password must contain a lowercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Confirm password must contain a number';
                                }
                                if (!RegExp(r'[!@#\$&*~_\-]').hasMatch(value)) {
                                  return 'Confirm password must contain a special character';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                            Obx(() => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          final error = await _authController.signUp(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          );
                                          if (error == null) {
                                            // Go to registration screen, pass email
                                            Get.to(() => RegistrationScreen(
                                              email: _emailController.text.trim(),
                                              displayName: null,
                                            ));
                                          } else {
                                            Get.snackbar('Signup Failed', error, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                                child: _authController.isLoading.value
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(BTexts.createAccount, style: TextStyle(fontSize: BSizes.fontSizeMd)),
                              ),
                            )),
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
                                onPressed: () async {
                                  final error = await _authController.signInWithGoogle();
                                  if (error == null) {
                                    final user = _authController.firebaseUser.value;
                                    final email = user?.email ?? '';
                                    final displayName = user?.displayName;
                                    Get.to(() => RegistrationScreen(
                                      email: email,
                                      displayName: displayName,
                                    ));
                                  } else {
                                    Get.snackbar('Google Signup Failed', error ?? 'Unknown error', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.withOpacity(0.7), colorText: Colors.white);
                                  }
                                },
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
