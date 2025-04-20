import 'package:bytebazaar/common/widgets/appbar/appbar.dart';
import 'package:bytebazaar/common/widgets/icons/cart_counter_icon.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    // Placeholder for wishlist items logic. Assume empty for now.
    final bool isEmpty = true;

    return Scaffold(
      appBar: BAppBar(
        title: Text(
          BTexts.wishlistTitle,
          style: Theme.of(context).textTheme.headlineMedium!.apply(color: BColors.white),
        ),
        actions: [
          // Placeholder for Chat Icon
          IconButton(onPressed: () {}, icon: const Icon(Iconsax.message, color: BColors.white)),
          BCartCounterIcon(onPressed: () {}, iconColor: BColors.white),
        ],
        showBackArrow: false, // No back arrow as requested
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                BColors.primary,
                BColors.primary.withOpacity(0.7), // Adjust gradient as needed
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display Lottie animation when wishlist is empty
                  Lottie.asset(
                    BImages.notFoundAnimation, // Path as positional argument
                    width: BHelperFunctions.screenWidth() * 0.6, // Re-add width as named argument
                  ),
                  const SizedBox(height: BSizes.spaceBtwItems),
                  Text(
                    BTexts.wishlistEmpty,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: BSizes.spaceBtwSections),
                  // Optional: Add a button to browse products
                  // ElevatedButton(
                  //   onPressed: () { /* Navigate to shop */ },
                  //   child: const Text(BTexts.browseProducts),
                  // ),
                ],
              ),
            )
          : const Center(
              child: Text("Wishlist Items Here"), // Placeholder for actual list
            ),
    );
  }
}
