import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';

class PasswordResetSentScreen extends StatefulWidget {
  const PasswordResetSentScreen({super.key});

  @override
  State<PasswordResetSentScreen> createState() => _PasswordResetSentScreenState();
}

class _PasswordResetSentScreenState extends State<PasswordResetSentScreen> {
  static const int _initialSeconds = 60;
  int _secondsLeft = _initialSeconds;
  String? _email;
  late final AuthController _authController;
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController.to;
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      setState(() {
        _email = args;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    if (_email == null || _email!.isEmpty) return;
    final error = await _authController.sendPasswordResetEmail(_email!);
    setState(() => _isResending = false);
    if (error == null) {
      BFeedback.show(context, title: 'Success', message: 'Password reset email resent!', type: BFeedbackType.success);
      _startTimer();
    } else {
      BFeedback.show(context, title: 'Resend Failed', message: error ?? 'Unknown error', type: BFeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
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
                  // ByteBazaar logo at the top (like forgot_password_screen.dart)
                  Image.asset(
                    BImages.splashLogo,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: BSizes.spaceBtwSections),
                  Container(
                    padding: const EdgeInsets.all(BSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: BColors.background,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.email_outlined, color: BColors.primary, size: 64),
                        const SizedBox(height: BSizes.spaceBtwItems),
                        Text(
                          'Check your email',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: BSizes.spaceBtwItems / 2),
                        Text(
                          'A password reset link has been sent to your email address. Please follow the instructions in the email to reset your password.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: BSizes.spaceBtwSections),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back to Login'),
                            onPressed: () => Get.offAll(() => const LoginScreen()),
                          ),
                        ),
                        const SizedBox(height: BSizes.spaceBtwItems),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: _isResending
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(_secondsLeft > 0 ? 'Resend in $_secondsLeft s' : 'Resend Email'),
                            onPressed: (_secondsLeft == 0 && !_isResending && _email != null && _email!.isNotEmpty)
                                ? _resendEmail
                                : null,
                          ),
                        ),
                      ],
                    ), // end card column
                  ), // end card container
                ],
              ), // end main column
            ), // end padding
          ), // end scrollview
        ), // end container
      ), // end sizedbox
    ); // end scaffold
  }
}
