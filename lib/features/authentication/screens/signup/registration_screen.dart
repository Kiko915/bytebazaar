import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart'; // Import Get for navigation if needed later
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/common/widgets/bottom_nav_bar.dart';
import 'package:bytebazaar/utils/user_firestore_helper.dart';

class RegistrationScreen extends StatefulWidget {
  final String email;
  final String? displayName;
  const RegistrationScreen({super.key, required this.email, this.displayName});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _agreedToTerms = false;
  // Address data from JSON
  List<dynamic> _countries = [];
  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];

  String? _selectedCountryCode;
  String? _selectedProvinceName;
  String? _selectedCityName;

  @override
  void initState() {
    super.initState();
    _redirectIfRegistered();
    _loadCPCData();
    if (!mounted) return;
    _emailController.text = widget.email;
    if (widget.displayName != null) {
      final parts = widget.displayName!.split(' ');
      if (parts.isNotEmpty) {
        _firstNameController.text = parts.first;
      }
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  void _redirectIfRegistered() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final registered = await isUserRegistered();
    if (registered && mounted) {
      // Redirect to BottomNavBar if already registered
      Get.offAll(() => const BottomNavBar());
    }
  }

  Future<void> _loadCPCData() async {
    final String response =
        await rootBundle.loadString('assets/data/cpc.json');
    final dynamic data = json.decode(response);
    // If the JSON is a Map (single country), wrap it in a List
    List countriesList;
    if (data is List) {
      countriesList = data;
    } else if (data is Map) {
      countriesList = [data];
    } else {
      countriesList = [];
    }
    setState(() {
      _countries = countriesList;
    });
    debugPrint('Loaded countries: ${_countries.length}');
  }

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
  // Address (using country_state_city_picker)
  String? _selectedCountry;
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  final AuthController _authController = Get.put(AuthController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Countries loaded in build: count = [32m${_countries.length}[0m, first = ${_countries.isNotEmpty ? _countries[0]['name'] : 'none'}');
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
                        height: BSizes
                            .spaceBtwSections), // Adjust spacing as needed

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
                        borderRadius: BorderRadius.circular(BSizes
                                .cardRadiusLg +
                            10), // Slightly more rounded corners based on image
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.1 * 255).toInt()),
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
                                const SizedBox(
                                    height: BSizes.spaceBtwItems / 6),
                                Text(
                                  BTexts
                                      .registrationSubTitle, // Assuming this exists in BTexts
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
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
                                      labelText: 'Username *'),
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
                                      labelText: 'First Name *'),
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
                                      labelText: 'Last Name *'),
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
                                      labelText: 'Occupation *'),
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
                                  onChanged: (value) => setState(
                                      () => _selectedOccupation = value),
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
                                      setState(
                                          () => _selectedBirthday = picked);
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Birthday *',
                                        hintText: 'Select your birthday',
                                      ),
                                      controller: TextEditingController(
                                        text: _selectedBirthday == null
                                            ? ''
                                            : '${_selectedBirthday!.toLocal()}'
                                                .split(' ')[0],
                                      ),
                                      validator: (_) =>
                                          _selectedBirthday == null
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
                                // Coverage notice
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.info_outline,
                                          color: Colors.orange, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'At this time we only cover the Philippines, but in the future ByteBazaar will scale to the world.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  color: Colors.orange[900]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Country Dropdown (Rebuilt)
                                _countries.isEmpty
                                    ? const Center(child: CircularProgressIndicator())
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: const InputDecoration(labelText: 'Country *'),
                                            value: _selectedCountryCode,
                                            items: _countries
                                                .map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(
                                                      value: c['iso2'],
                                                      child: Text(c['name']),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              final country = _countries.firstWhere((c) => c['iso2'] == value, orElse: () => null);
                                              setState(() {
                                                _selectedCountryCode = value;
                                                _selectedCountry = country != null ? country['name'] : null;
                                                _provinces = country != null && country['states'] != null ? List<Map<String, dynamic>>.from(country['states']) : [];
                                                _selectedProvinceName = null;
                                                _cities = [];
                                                _selectedCityName = null;
                                              });
                                            },
                                            validator: (value) => value == null || value.isEmpty ? 'Country required' : null,
                                          ),
                                          const SizedBox(height: BSizes.spaceBtwInputFields),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: const InputDecoration(labelText: 'State/Province *'),
                                            value: _selectedProvinceName,
                                            items: _provinces.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
                                                  value: p['name'],
                                                  child: Text(p['name']),
                                                )).toList(),
                                            onChanged: (_selectedCountryCode == null || _provinces.isEmpty)
                                                ? null
                                                : (value) {
                                                    final province = _provinces.firstWhere((p) => p['name'] == value, orElse: () => <String, dynamic>{});
                                                    List<Map<String, dynamic>> citiesList = [];
                                                    if (province.isNotEmpty && province['cities'] != null && province['cities'] is List) {
                                                      try {
                                                        citiesList = List<Map<String, dynamic>>.from((province['cities'] as List<dynamic>).map((c) => Map<String, dynamic>.from(c)));
                                                      } catch (e) {
                                                        debugPrint('Error converting cities: $e');
                                                      }
                                                    }
                                                    setState(() {
                                                      _selectedProvinceName = value;
                                                      _cities = citiesList;
                                                      _selectedCityName = null;
                                                    });
                                                    debugPrint('Selected province: $value, cities:  ${citiesList.map((c) => c['name']).toList()}');
                                                  },
                                            validator: (value) => value == null || value.isEmpty ? 'State/Province required' : null,
                                            disabledHint: const Text('Select country first'),
                                          ),
                                          const SizedBox(height: BSizes.spaceBtwInputFields),
                                          (_selectedProvinceName == null || _cities.isEmpty)
                                              ? DropdownButtonFormField<String>(
                                                  isExpanded: true,
                                                  decoration: const InputDecoration(labelText: 'City *'),
                                                  value: null,
                                                  items: const [],
                                                  onChanged: null,
                                                  validator: (value) => value == null || value.isEmpty ? 'City required' : null,
                                                  disabledHint: const Text('Select province first'),
                                                )
                                              : DropdownButtonFormField<String>(
                                                  isExpanded: true,
                                                  decoration: const InputDecoration(labelText: 'City *'),
                                                  value: _selectedCityName,
                                                  items: _cities.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(
                                                        value: c['name'],
                                                        child: Text(c['name']),
                                                      )).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedCityName = value;
                                                    });
                                                  },
                                                  validator: (value) => value == null || value.isEmpty ? 'City required' : null,
                                                ),
                                        ],
                                      ),
                                const SizedBox(
                                    height: BSizes.spaceBtwInputFields),
                                TextFormField(
                                  controller: _streetController,
                                  decoration: const InputDecoration(
                                      labelText: 'Street/Block *'),
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
                                      labelText: 'Zip Code *'),
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
                                  value: _agreedToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreedToTerms = value ?? false;
                                    });
                                  },
                                ),
                              ),
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
                                  onPressed: _authController.isLoading.value ||
                                          !_agreedToTerms ||
                                          _usernameController.text
                                              .trim()
                                              .isEmpty ||
                                          _firstNameController.text
                                              .trim()
                                              .isEmpty ||
                                          _lastNameController.text
                                              .trim()
                                              .isEmpty ||
                                          _selectedBirthday == null ||
                                          _emailController.text
                                              .trim()
                                              .isEmpty ||
                                          _phoneController.text
                                              .trim()
                                              .isEmpty ||
                                          _selectedCountryCode == null ||
                                          _selectedProvinceName == null ||
                                          _selectedCityName == null ||
                                          _streetController.text
                                              .trim()
                                              .isEmpty ||
                                          _zipController.text.trim().isEmpty
                                      ? null
                                      : () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final user = FirebaseAuth
                                                .instance.currentUser;
                                            final uid = user?.uid ?? '';
                                            if (uid.isNotEmpty) {
                                              final username =
                                                  _usernameController.text
                                                      .trim();
                                              // Check if username is taken
                                              final usernameQuerySnapshot = await FirebaseFirestore
                                                  .instance
                                                  .collection('users')
                                                  .where('username', isEqualTo: username)
                                                  .get();
                                              if (usernameQuerySnapshot.docs.isNotEmpty) {
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
                                                'firstName':
                                                    _firstNameController.text
                                                        .trim(),
                                                'lastName': _lastNameController
                                                    .text
                                                    .trim(),
                                                'middleName':
                                                    _middleNameController.text
                                                        .trim(),
                                                'occupation':
                                                    _selectedOccupation,
                                                'birthday': _selectedBirthday,
                                                'email': _emailController.text
                                                    .trim(),
                                                'phone': _phoneController.text
                                                    .trim(),
                                                'country': _selectedCountry,
                                                'province':
                                                    _selectedProvinceName?.trim(),
                                                'city': _selectedCityName?.trim(),
                                                'street': _streetController.text
                                                    .trim(),
                                                'zip':
                                                    _zipController.text.trim(),
                                                'createdAt': FieldValue
                                                    .serverTimestamp(),
                                              });
                                              BFeedback.show(context,
                                                  title: 'Success',
                                                  message:
                                                      'Registration complete!',
                                                  type: BFeedbackType.success);
                                              Get.offAll(() => const BottomNavBar());
                                            }
                                          }
                                        },
                                  child: _authController.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : Text(
                                          BTexts.register.toUpperCase(),
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
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
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
                                        color:
                                            Color.fromARGB(255, 192, 203, 255),
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
                    const SizedBox(height: BSizes.spaceBtwSections),
                  ],
                ),
              ), // End SingleChildScrollView
            ), // End Container
          ), // End SizedBox
        )); // End Scaffold
  }
}
