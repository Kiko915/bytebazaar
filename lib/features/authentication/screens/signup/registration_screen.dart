import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get for navigation if needed later

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

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
              Color.fromARGB(255, 35, 87, 171), // Match ForgotPasswordScreen gradient
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
              const SizedBox(height: BSizes.spaceBtwSections), // Adjust spacing as needed

              /// Hero Image (Placeholder for now, will add actual image later if needed)
              Image(
                height: 200, // Adjust height as per design
                image: AssetImage(BImages.signUpHero), // Assuming BImages.signUpHero points to 'assets/images/auth/sign-up.png'
              ),
              const SizedBox(height: BSizes.spaceBtwSections / 2),

              /// White Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BSizes.defaultSpace),
                decoration: BoxDecoration(
                  color: dark ? BColors.darkerGrey : BColors.background,
                  borderRadius: BorderRadius.circular(BSizes.cardRadiusLg + 10), // Slightly more rounded corners based on image
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
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                  children: [
                    /// Title & Subtitle
                     Center( // Center the title and subtitle
                      child: Column(
                        children: [
                          Text(
                            BTexts.registrationTitle, // Assuming this exists in BTexts
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: const Color.fromARGB(255, 25, 78, 163)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: BSizes.spaceBtwItems / 6),
                          Text(
                            BTexts.registrationSubTitle, // Assuming this exists in BTexts
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),

                    // --- Form Sections ---

                    /// Personal Details Section
                    Text(
                      BTexts.personalDetails,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BColors.primary),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.firstName),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.lastName),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.middleName),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    // TODO: Implement DropdownButtonFormField for Occupation
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: BTexts.occupation),
                      items: ['Student', 'Employed', 'Self-employed', 'Unemployed'] // Example items
                          .map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // Handle change
                      },
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                     // TODO: Implement Date Picker for Birthday
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: BTexts.birthday,
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true, // Prevent manual text input
                      onTap: () async {
                        // Show date picker
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now());
                        if (pickedDate != null) {
                          // Update the text field or state variable
                          // print(pickedDate); // For now, just print
                        }
                      },
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),


                    /// Contact Details Section
                    Text(
                      BTexts.contactDetails,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BColors.primary),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.phoneNo),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),


                    /// Address Section
                    Text(
                      BTexts.address,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BColors.primary),
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                     // TODO: Implement DropdownButtonFormField for Country
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: BTexts.country),
                      items: ['Philippines', 'USA', 'Canada'] // Example items
                          .map((String country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // Handle change, potentially load regions
                      },
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    // TODO: Implement DropdownButtonFormField for Region
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: BTexts.region),
                      items: [], // Populate based on country selection
                      onChanged: (newValue) {
                         // Handle change, potentially load provinces/cities
                      },
                    ),
                     const SizedBox(height: BSizes.spaceBtwInputFields),
                    // TODO: Implement DropdownButtonFormField for City/Province
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: BTexts.cityProvince),
                      items: [], // Populate based on region selection
                      onChanged: (newValue) {
                         // Handle change, potentially load municipalities
                      },
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                     // TODO: Implement DropdownButtonFormField for Municipality
                    DropdownButtonFormField(
                      decoration: const InputDecoration(labelText: BTexts.municipality),
                       items: [], // Populate based on city/province selection
                      onChanged: (newValue) {
                         // Handle change
                      },
                    ),
                    const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.houseStreetBlock),
                    ),
                     const SizedBox(height: BSizes.spaceBtwInputFields),
                    TextFormField(
                      decoration: const InputDecoration(labelText: BTexts.zipCode),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: BSizes.spaceBtwSections),

                    /// Terms and Conditions Checkbox
                    Row(
                      children: [
                        SizedBox(width: 24, height: 24, child: Checkbox(value: true, onChanged: (value){})), // TODO: Add state management
                        const SizedBox(width: BSizes.spaceBtwItems),
                        Expanded( // Use Expanded to allow text wrapping
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(text: '${BTexts.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
                              TextSpan(text: BTexts.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium!.apply( // Keep Privacy Policy link separate if needed
                                color: BColors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: BColors.primary,
                              )),
                              TextSpan(text: ' ${BTexts.and} ', style: Theme.of(context).textTheme.bodySmall), // Add 'and' if Privacy Policy is separate
                              TextSpan(text: BTexts.termsOfUse, style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: BColors.primary,
                                decoration: TextDecoration.underline,
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
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement registration logic
                        },
                        child: Text(
                          BTexts.register.toUpperCase(), // Match button text from image
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: BColors.background),
                        ),
                      ),
                    ),
                     const SizedBox(height: BSizes.spaceBtwItems),

                     
                  ],
                ),
              ),
               const SizedBox(height: BSizes.spaceBtwSections), // Space between card and link

               /// Sign In Link (Moved outside the card)
               Center(
                 child: TextButton(
                   onPressed: () => Get.back(), // Go back to previous screen (likely signup or login)
                   child: Text.rich(
                     TextSpan(
                       text: '${BTexts.alreadyHaveAccount} ',
                       // Explicit null check for bodySmall style
                       style: Theme.of(context).textTheme.bodySmall == null
                           ? const TextStyle(color: BColors.white) // Default style if bodySmall is null
                           : Theme.of(context).textTheme.bodySmall!.copyWith( // Use ! since null is checked
                               color: BColors.white, // Adjust text color based on theme
                             ),
                       children: [
                         TextSpan(
                           text: BTexts.signIn,
                           // Explicit null check for bodySmall style
                           style: Theme.of(context).textTheme.bodySmall == null
                               ? const TextStyle( // Default style if bodySmall is null
                                   color: Color.fromARGB(255, 192, 203, 255),
                                   decoration: TextDecoration.underline,
                                 )
                               : Theme.of(context).textTheme.bodySmall!.copyWith( // Use ! since null is checked
                                   color: Color.fromARGB(255, 192, 203, 255), // Make 'Sign In' stand out
                                   decoration: TextDecoration.underline,
                                 ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
              const SizedBox(height: BSizes.spaceBtwSections), // Bottom padding
            ],
          ),
        ),
      ), // End SingleChildScrollView
    ), // End Container
   ), // End SizedBox
  ); // End Scaffold
  }
}
