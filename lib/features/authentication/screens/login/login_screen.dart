import 'package:bytebazaar/common/widgets/bottom_nav_bar.dart'; // Import BottomNavBar
import 'package:bytebazaar/features/authentication/screens/password_configuration/forgot_password_screen.dart'; // Import ForgotPasswordScreen
import 'package:bytebazaar/features/authentication/screens/signup/signup_screen.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/features/authentication/screens/signup/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 24, 72, 150),
      body: Stack(
        // Use Stack as the direct body
        children: [
          // Background Image Widget as first layer, filling the stack
          Positioned.fill(
            child: Image.asset(
              BImages.authBg,
              fit: BoxFit.fill, // Force fill the bounds
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
                  height: BHelperFunctions.screenHeight() *
                      0.3, // Adjust height as needed
                  image: const AssetImage(BImages.authWelcome),
                ),
              ],
            ),
          ),

          // Positioned Form Container (fills bottom part)
          Positioned(
            top:
                BHelperFunctions.screenHeight() * 0.4, // Start below hero image
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
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
                        height:
                            150, // Adjust size as needed (Note: was 150 in previous error state, reverting to 100)
                        image: AssetImage(BImages.authTagIcon),
                      ),
                      const SizedBox(height: BSizes.spaceBtwItems),

                      // Title & Subtitle
                      Text(BTexts.loginTitle,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: BSizes.sm / 2),
                      Text(BTexts.loginSubTitle,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: BSizes.spaceBtwSections),

                      // --- Login Form ---
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: BTexts.email),
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
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: BTexts.password,
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible),
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility),
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
                            const SizedBox(
                                height: BSizes.spaceBtwInputFields / 2),
                            // Forget Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Get.to(() =>
                                    const ForgotPasswordScreen()), // Navigate to ForgotPasswordScreen
                                child: const Text(BTexts.forgetPassword),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                            Obx(() => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _authController.isLoading.value
                                        ? null
                                        : () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final error =
                                                  await _authController.signIn(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                              if (error == null) {
                                                // Personalized welcome back
                                                final email = _emailController
                                                    .text
                                                    .trim();
                                                final username =
                                                    email.contains('@')
                                                        ? email.split('@')[0]
                                                        : email;
                                                BFeedback.show(
                                                  context,
                                                  title: 'Welcome back!',
                                                  message:
                                                      'Hello, $username! Glad to see you again.',
                                                  type: BFeedbackType.success,
                                                );
                                                Get.offAll(
                                                    () => const BottomNavBar());
                                              } else {
                                                BFeedback.show(context,
                                                    title: 'Login Failed',
                                                    message: error ??
                                                        'Unknown error',
                                                    type: BFeedbackType.error);
                                                print(error);
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size(double.infinity, 50)),
                                    child: _authController.isLoading.value
                                        ? const CircularProgressIndicator(
                                            color: Colors.white)
                                        : const Text(BTexts.signIn,
                                            style: TextStyle(
                                                fontSize: BSizes.fontSizeMd)),
                                  ),
                                )),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Divider
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: Divider(
                                        color: dark
                                            ? BColors.darkGrey
                                            : BColors.grey,
                                        thickness: 0.5,
                                        indent: 60,
                                        endIndent: 5)),
                                Text(BTexts.orContinueWith,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                                Flexible(
                                    child: Divider(
                                        color: dark
                                            ? BColors.darkGrey
                                            : BColors.grey,
                                        thickness: 0.5,
                                        indent: 5,
                                        endIndent: 60)),
                              ],
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Google Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () async {
                                        final error = await _authController
                                            .signInWithGoogle();
                                        if (error == null) {
                                          final user = _authController
                                              .firebaseUser.value;
                                          final email = user?.email ?? '';
                                          final displayName = user?.displayName;
                                          // Check Firestore for existing user profile
                                          if (user != null) {
                                            final uid = user.uid;
                                            final doc = await FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(uid)
                                                .get();
                                            if (!doc.exists) {
                                              // New user, redirect to registration
                                              Get.to(() => RegistrationScreen(
                                                  email: email,
                                                  displayName: displayName));
                                              return;
                                            }
                                          }
                                          // Existing user, proceed as before
                                          String username = '';
                                          if (user != null) {
                                            username = user.displayName ??
                                                (user.email?.split('@')[0] ??
                                                    'User');
                                          } else {
                                            username = 'User';
                                          }
                                          BFeedback.show(
                                            context,
                                            title: 'Welcome back!',
                                            message:
                                                'Hello, $username! Glad to see you again.',
                                            type: BFeedbackType.success,
                                          );
                                          Get.offAll(
                                              () => const BottomNavBar());
                                        } else {
                                          BFeedback.show(context,
                                              title: 'Google Sign-In Failed',
                                              message: error ?? 'Unknown error',
                                              type: BFeedbackType.error);
                                        }
                                      },
                                style: OutlinedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50)),
                                child: Obx(
                                  () => _authController.isLoading.value
                                      ? const CircularProgressIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              BImages.google,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(BTexts.dontHaveAccount,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                TextButton(
                                  onPressed: () =>
                                      Get.to(() => const SignupScreen()),
                                  child: const Text(BTexts.signUp),
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
