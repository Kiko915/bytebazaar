import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get for navigation if needed later
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

class RegistrationScreen extends StatefulWidget {
  final String email;
  final String? displayName;
  const RegistrationScreen({super.key, required this.email, this.displayName});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Personal Info
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  String? _selectedOccupation;
  DateTime? _selectedBirthday;

  // Contact Details
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Address
  String? _selectedCountry;
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final AuthController _authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    if (widget.displayName != null) {
      final parts = widget.displayName!.split(' ');
      if (parts.isNotEmpty) _firstNameController.text = parts.first;
      if (parts.length > 1)
        _lastNameController.text = parts.sublist(1).join(' ');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    return Scaffold(
      // Set scaffold background to transparent to let the container gradient show
      backgroundColor: Colors.transparent,
      body: SizedBox(
        // Ensure the container covers the full screen height
        height: MediaQuery.of(context).size.height,
        child: Container(
          // Apply the gradient decoration to the container
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BColors.primary,
                Color.fromARGB(
                    255, 35, 87, 171), // Match ForgotPasswordScreen gradient
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
                  const SizedBox(
                      height:
                          BSizes.spaceBtwSections), // Adjust spacing as needed

                  /// Hero Image (Placeholder for now, will add actual image later if needed)
                  Image(
                    height: 200, // Adjust height as per design
                    image: AssetImage(BImages
                        .signUpHero), // Assuming BImages.signUpHero points to 'assets/images/auth/sign-up.png'
                  ),
                  const SizedBox(height: BSizes.spaceBtwSections / 2),

                  /// White Card Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(BSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: dark ? BColors.darkerGrey : BColors.background,
                      borderRadius: BorderRadius.circular(BSizes.cardRadiusLg +
                          10), // Slightly more rounded corners based on image
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to start
                      children: [
                        /// Title & Subtitle
                        Center(
                          // Center the title and subtitle
                          child: Column(
                            children: [
                              Text(
                                BTexts
                                    .registrationTitle, // Assuming this exists in BTexts
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        color: const Color.fromARGB(
                                            255, 25, 78, 163)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: BSizes.spaceBtwItems / 6),
                              Text(
                                BTexts
                                    .registrationSubTitle, // Assuming this exists in BTexts
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: BSizes.spaceBtwSections),

                        // --- Form Sections ---
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ---- Personal Info ----
                              Text('Personal Information',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Username required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                    labelText: 'First Name'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'First name required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Last Name'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Last name required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _middleNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Middle Name (optional)'),
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                    labelText: 'Occupation'),
                                items: [
                                  'Student',
                                  'Employed',
                                  'Self-employed',
                                  'Unemployed'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: _selectedOccupation,
                                onChanged: (value) =>
                                    setState(() => _selectedOccupation = value),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Occupation required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null)
                                    setState(() => _selectedBirthday = picked);
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Birthday',
                                      hintText: 'Select your birthday',
                                    ),
                                    controller: TextEditingController(
                                      text: _selectedBirthday == null
                                          ? ''
                                          : '${_selectedBirthday!.toLocal()}'
                                              .split(' ')[0],
                                    ),
                                    validator: (_) => _selectedBirthday == null
                                        ? 'Birthday required'
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(height: BSizes.spaceBtwSections),
                              // ---- Contact Details ----
                              Text('Contact Details',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _emailController,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                enabled: false,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number'),
                              ),
                              const SizedBox(height: BSizes.spaceBtwSections),
                              // ---- Address ----
                              Text('Address',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              DropdownButtonFormField<String>(
                                decoration:
                                    const InputDecoration(labelText: 'Country'),
                                items: [
                                  'Philippines',
                                  'United States',
                                  'Canada',
                                  'Other'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                value: _selectedCountry,
                                onChanged: (value) =>
                                    setState(() => _selectedCountry = value),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Country required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _regionController,
                                decoration:
                                    const InputDecoration(labelText: 'Region'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Region required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _provinceController,
                                decoration: const InputDecoration(
                                    labelText: 'Province'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Province required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                    labelText: 'Town/City'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Town/City required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _streetController,
                                decoration: const InputDecoration(
                                    labelText: 'Street/Block'),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Street/Block required'
                                        : null,
                              ),
                              const SizedBox(
                                  height: BSizes.spaceBtwInputFields),
                              TextFormField(
                                controller: _zipController,
                                decoration: const InputDecoration(
                                    labelText: 'Zip Code'),
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Zip code required'
                                        : null,
                              ),
                              const SizedBox(height: BSizes.spaceBtwSections),
                            ],
                          ),
                        ),

                        /// Terms and Conditions Checkbox
                        Row(
                          children: [
                            SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                    value: true,
                                    onChanged:
                                        (value) {})), // TODO: Add state management
                            const SizedBox(width: BSizes.spaceBtwItems),
                            Expanded(
                              // Use Expanded to allow text wrapping
                              child: Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                      text: '${BTexts.iAgreeTo} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  TextSpan(
                                      text: BTexts.privacyPolicy,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(
                                            // Keep Privacy Policy link separate if needed
                                            color: BColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: BColors.primary,
                                          )),
                                  TextSpan(
                                      text: ' ${BTexts.and} ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall), // Add 'and' if Privacy Policy is separate
                                  TextSpan(
                                      text: BTexts.termsOfUse,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(
                                            color: BColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: BColors.primary,
                                          )),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: BSizes.spaceBtwSections),

                        /// Register Button
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Save additional info to Firestore
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          final uid = user?.uid ?? '';
                                          if (uid.isNotEmpty) {
                                            // Check username uniqueness
                                            final username =
                                                _usernameController.text.trim();
                                            final usernameQuery =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .where('username',
                                                        isEqualTo: username)
                                                    .get();
                                            if (usernameQuery.docs.isNotEmpty) {
                                              BFeedback.show(context,
                                                  title: 'Username Taken',
                                                  message:
                                                      'Please choose a different username.',
                                                  type: BFeedbackType.error);
                                              return;
                                            }
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(uid)
                                                .set({
                                              'username': username,
                                              'firstName': _firstNameController
                                                  .text
                                                  .trim(),
                                              'lastName': _lastNameController
                                                  .text
                                                  .trim(),
                                              'middleName':
                                                  _middleNameController.text
                                                      .trim(),
                                              'occupation': _selectedOccupation,
                                              'birthday': _selectedBirthday,
                                              'email':
                                                  _emailController.text.trim(),
                                              'phone':
                                                  _phoneController.text.trim(),
                                              'country': _selectedCountry,
                                              'region':
                                                  _regionController.text.trim(),
                                              'province': _provinceController
                                                  .text
                                                  .trim(),
                                              'city':
                                                  _cityController.text.trim(),
                                              'street':
                                                  _streetController.text.trim(),
                                              'zip': _zipController.text.trim(),
                                              'createdAt':
                                                  FieldValue.serverTimestamp(),
                                            });
                                            BFeedback.show(context,
                                                title: 'Success',
                                                message:
                                                    'Registration complete!',
                                                type: BFeedbackType.success);
                                            Get.offAllNamed('/');
                                          }
                                        }
                                      },
                                child: _authController.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        BTexts.register
                                            .toUpperCase(), // Match button text from image
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                color: BColors.background),
                                      ),
                              )),
                        ),
                        const SizedBox(height: BSizes.spaceBtwItems),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: BSizes
                          .spaceBtwSections), // Space between card and link

                  /// Sign In Link (Moved outside the card)
                  Center(
                    child: TextButton(
                      onPressed: () => Get
                          .back(), // Go back to previous screen (likely signup or login)
                      child: Text.rich(
                        TextSpan(
                          text: '${BTexts.alreadyHaveAccount} ',
                          // Explicit null check for bodySmall style
                          style: Theme.of(context).textTheme.bodySmall == null
                              ? const TextStyle(
                                  color: BColors
                                      .white) // Default style if bodySmall is null
                              : Theme.of(context).textTheme.bodySmall!.copyWith(
                                    // Use ! since null is checked
                                    color: BColors
                                        .white, // Adjust text color based on theme
                                  ),
                          children: [
                            TextSpan(
                              text: BTexts.signIn,
                              // Explicit null check for bodySmall style
                              style: Theme.of(context).textTheme.bodySmall ==
                                      null
                                  ? const TextStyle(
                                      // Default style if bodySmall is null
                                      color: Color.fromARGB(255, 192, 203, 255),
                                      decoration: TextDecoration.underline,
                                    )
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        // Use ! since null is checked
                                        color: Color.fromARGB(255, 192, 203,
                                            255), // Make 'Sign In' stand out
                                        decoration: TextDecoration.underline,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: BSizes.spaceBtwSections), // Bottom padding
                ],
              ),
            ),
          ), // End SingleChildScrollView
        ), // End Container
      ), // End SizedBox
    ); // End Scaffold
  }
}
