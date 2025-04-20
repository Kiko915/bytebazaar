import 'package:bytebazaar/common/widgets/custom_shapes/curved_edges/curved_edges_clipper.dart'; // Import the clipper
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match the header
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: BColors.primary, // Set status bar color to blue
        statusBarIconBrightness: Brightness.light, // Set icons to light
        systemNavigationBarColor: BColors.light, // Keep nav bar light
        systemNavigationBarIconBrightness: Brightness.dark, // Keep nav bar icons dark
      ),
      child: Scaffold(
        body: SafeArea(
          top: false, // Let AnnotatedRegion handle status bar, SafeArea handles bottom
          bottom: true,
          child: Container( // Added Container for background color
          color: BColors.light, // Set background color for the safe area content
          child: SingleChildScrollView(
            child: Column(
            children: [
              // --- Header Section with Custom Curve ---
            _buildHeaderSection(context),

            // --- Body Section ---
            Padding(
              padding: const EdgeInsets.all(BSizes.defaultSpace),
              child: Column(
                children: [
                  // -- Promo Banner --
                  _buildPromoBanner(),
                  const SizedBox(height: BSizes.spaceBtwSections),

                  // -- Categories --
                  _buildCategoriesSection(context),
                  const SizedBox(height: BSizes.spaceBtwSections),

                  // -- Recommended Products --
                  _buildRecommendedSection(context),
                  const SizedBox(height: BSizes.spaceBtwItems / 8),

                  // -- Product Grid --
                  GridView.builder(
                    itemCount: 4, // Example count
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: BSizes.gridViewSpacing,
                      crossAxisSpacing: BSizes.gridViewSpacing,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) => const BProductCardVertical(),
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ), // Close Scaffold
    ))); // Close AnnotatedRegion
  }

  // --- Helper Widgets ---

  // Header Section using ClipPath
  Widget _buildHeaderSection(BuildContext context) {
    return ClipPath(
      clipper: BHeaderClipper(), // Use the custom clipper
      child: Container(
        color: BColors.primary, // Background color
        padding: const EdgeInsets.only(bottom: BSizes.defaultSpace + 30), // Add padding to account for curve height
        child: Column(
          children: [
            // -- Top Section (Greeting & Notification) --
            Padding(
              padding: EdgeInsets.only(
                left: BSizes.defaultSpace,
                right: BSizes.defaultSpace,
                top: kToolbarHeight, // Account for status bar
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left-aligned greeting column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimeBasedGreeting(context),
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: BColors.white),
                      ),
                    ],
                  ),
                  // Right-aligned notification icon
                  _buildAppBarAction(
                    icon: Iconsax.notification, 
                    color: BColors.white,
                    onPressed: () {},
                    showBadge: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BSizes.spaceBtwItems),

            // -- Search Bar Row --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: BSizes.defaultSpace),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(context),
                  ),
                  const SizedBox(width: BSizes.spaceBtwItems),
                  _buildFilterButton(context),
                ],
              ),
            ),
            // No extra SizedBox needed here as padding is handled by Container
          ],
        ),
      ),
    );
  }

  // Helper function for time-based greeting
  Widget _buildTimeBasedGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = 'Good Morning!';
      emoji = ' ☀️'; // Sun emoji
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
      emoji = ' 👋'; // Waving hand emoji
    } else {
      greeting = 'Good Evening!';
      emoji = ' 🌙'; // Moon emoji
    }

    return Text(
      greeting + emoji,
      style: Theme.of(context).textTheme.labelMedium!.apply(color: BColors.lightGrey), // Corrected color back to grey
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    // Updated Search Bar Style
    return Container(
      width: double.infinity, // Take available width
      padding: const EdgeInsets.symmetric(horizontal: BSizes.md, vertical: BSizes.sm + 2), // Adjusted padding
      decoration: BoxDecoration(
        color: BColors.white,
        borderRadius: BorderRadius.circular(BSizes.cardRadiusLg), // Standard radius
        // Removed border to match design
      ),
      child: Row(
        children: [
          const Icon(Iconsax.search_normal, color: BColors.darkerGrey, size: BSizes.iconMd),
          const SizedBox(width: BSizes.spaceBtwItems),
          Text(
            'Search', // Simplified placeholder text
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BColors.darkerGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    // Filter Button specific widget
    return Container(
      decoration: BoxDecoration(
        color: BColors.white.withOpacity(0.1), // Slightly transparent white background
        borderRadius: BorderRadius.circular(BSizes.borderRadiusMd),
      ),
      child: IconButton(
        icon: const Icon(Iconsax.setting_4, color: BColors.white, size: BSizes.iconMd),
        onPressed: () {
          // Handle filter action
        },
        padding: const EdgeInsets.all(BSizes.sm), // Adjust padding as needed
        constraints: const BoxConstraints(), // Remove constraints
      ),
    );
  }


  Widget _buildAppBarAction({required IconData icon, Color? color, VoidCallback? onPressed, bool showBadge = false}) {
    // Updated to accept color and onPressed
    return Stack(
      alignment: Alignment.center,
      children: [
          IconButton(
            icon: Icon(icon, color: color ?? BColors.darkGrey, size: BSizes.iconLg), // Use provided color or default, slightly larger icon
            onPressed: onPressed, // Use provided onPressed
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (showBadge) // Keep badge logic if needed for other icons
            Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(BSizes.xs / 2), // Use BSizes
              decoration: BoxDecoration(
                color: Colors.red, // Use standard red color for the badge
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: BColors.white) // Thicker border
              ),
              constraints: const BoxConstraints(
                minWidth: 18, // Slightly larger badge
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  '2', // Example badge count
                  style: const TextStyle( // Consider defining badge text style in theme
                    color: Colors.white,
                    fontSize: 8, // Make text even smaller for the badge
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    // Placeholder for the banner - Replace with actual implementation
    return Container(
      height: 150, // Keep height or make dynamic
      decoration: BoxDecoration(
        // Use a gradient or image based on the design
        color: Colors.pink.shade100, // Example color
        borderRadius: BorderRadius.circular(BSizes.borderRadiusLg), // Use BSizes
      ),
      child: const Center(child: Text('Promo Banner Placeholder')), // Add actual content
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // Placeholder for categories - Replace with actual implementation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Categories'), // Correctly call _buildSectionHeader here
        const SizedBox(height: BSizes.spaceBtwItems), // Use BSizes
        SizedBox(
          height: 85, // Adjust height based on content + padding
          child: ListView.separated(
            itemCount: 8, // Example count
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: BSizes.spaceBtwItems), // Use BSizes
            itemBuilder: (context, index) => _buildCategoryItem(context, index), // Use actual item builder
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {VoidCallback? onPressed}) { // Ensure this definition is clean
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall, // Use appropriate style
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (onPressed != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              'See more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: BColors.primary), // Style for see more
            ), // Add missing closing parenthesis
          ),
      ],
    );
  }
  Widget _buildCategoryItem(BuildContext context, int index) {
    // Placeholder icons and text - ideally fetch from data source
    final icons = [
      Iconsax.watch, Iconsax.bag, Iconsax.magicpen, Iconsax.tag, // Replaced shirt with tag
      Iconsax.category, Iconsax.category, Iconsax.bezier, Iconsax.menu // Replaced boot with category
    ];
    final labels = [
      'Watches', 'Bags', 'Beauty', 'Clothing',
      'Accessories', 'Shoes', 'Lifestyle', 'More'
    ];

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(BSizes.sm), // Use BSizes
          decoration: BoxDecoration(
            color: BColors.white,
            borderRadius: BorderRadius.circular(100), // Circular background
            border: Border.all(color: BColors.lightGrey.withOpacity(0.5))
          ),
          child: Center(
            child: Icon(icons[index], color: BColors.primary, size: BSizes.iconLg), // Use BSizes
          ),
        ),
        const SizedBox(height: BSizes.spaceBtwItems / 2), // Use BSizes
        SizedBox(
          width: 60, // Ensure text doesn't overflow too much
          child: Text(
            labels[index],
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return _buildSectionHeader(context, 'Recommended', onPressed: () {
      // Handle "See more" action
    });
  }

// Removed _buildProductCardPlaceholder as it's replaced by BProductCardVertical
} // Add missing closing brace for HomeScreen class
