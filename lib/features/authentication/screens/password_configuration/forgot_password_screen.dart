import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/authentication/screens/password_configuration/password_reset_sent_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final AuthController _authController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    // Use Get.find if already initialized globally, else put once
    try {
      _authController = Get.find<AuthController>();
    } catch (_) {
      _authController = Get.put(AuthController());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                          const SizedBox(height: BSizes.spaceBtwSections),
                          /// Submit Button
                          Obx(() => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _authController.isLoading.value
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!.validate()) {
                                            final email = _emailController.text.trim();
                                            final exists = await _authController.userExistsByEmail(email);
                                            if (!exists) {
                                              BFeedback.show(context, title: 'User Not Found', message: 'No account found for this email.', type: BFeedbackType.error);
                                              return;
                                            }
                                            final error = await _authController.sendPasswordResetEmail(email);
                                            if (error == null) {
                                              // Show a confirmation screen
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => PasswordResetSentScreen(),
                                                  settings: RouteSettings(arguments: email),
                                                ),
                                              );
                                            } else {
                                              BFeedback.show(context, title: 'Reset Failed', message: error ?? 'Unknown error', type: BFeedbackType.error);
                                            }
                                          }
                                        },
                                  child: _authController.isLoading.value
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          BTexts.submit,
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
