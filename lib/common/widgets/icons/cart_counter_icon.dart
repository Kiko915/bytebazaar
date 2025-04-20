import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BCartCounterIcon extends StatelessWidget {
  const BCartCounterIcon({
    super.key,
    required this.onPressed,
    this.iconColor,
    this.counterBgColor,
    this.counterTextColor,
  });

  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? counterBgColor;
  final Color? counterTextColor;

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);
    // Placeholder count
    final int cartItemCount = 0; // Replace with actual cart item count logic

    return Stack(
      children: [
        IconButton(
            onPressed: onPressed,
            icon: Icon(Iconsax.shopping_bag, color: iconColor ?? (dark ? BColors.white : BColors.black))),
        if (cartItemCount > 0) // Show counter only if items > 0
          Positioned(
            right: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: counterBgColor ?? (dark ? BColors.white : BColors.black),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Text(
                  cartItemCount.toString(),
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                        color: counterTextColor ?? (dark ? BColors.black : BColors.white),
                        fontSizeFactor: 0.8,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
