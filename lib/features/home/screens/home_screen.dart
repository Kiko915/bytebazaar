import 'package:bytebazaar/common/widgets/custom_shapes/curved_edges/curved_edges_clipper.dart'; // Import the clipper
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_minimal.dart';
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_descriptive.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to match the header
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: BColors.primary, // Set status bar color to blue
          statusBarIconBrightness: Brightness.light, // Set icons to light
          systemNavigationBarColor: BColors.light, // Keep nav bar light
          systemNavigationBarIconBrightness:
              Brightness.dark, // Keep nav bar icons dark
        ),
        child: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              top:
                  false, // Let AnnotatedRegion handle status bar, SafeArea handles bottom
              bottom: true,
              child: Container(
                color: BColors
                    .light, // Set background color for the safe area content
                child: CustomScrollView(
                  slivers: [
                    // --- Header Section with Custom Curve ---
                    SliverToBoxAdapter(child: _buildHeaderSection(context)),

                    // --- Body Section ---
                    SliverPadding(
                      padding: const EdgeInsets.all(BSizes.defaultSpace),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildPromoBanner(),
                          const SizedBox(height: BSizes.spaceBtwSections),
                          _buildCategoriesSection(context),
                          const SizedBox(height: BSizes.spaceBtwSections),
                          _buildRecommendedSection(context),
                          const SizedBox(height: BSizes.spaceBtwItems / 8),
    
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // --- Helper Widgets ---

  // Header Section using ClipPath
  Widget _buildHeaderSection(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: BHeaderClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BColors.primary, // Light blue
                  Color.fromARGB(255, 17, 56, 128), // Slightly deeper blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.only(bottom: BSizes.defaultSpace + 50),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: BSizes.defaultSpace,
                    right: BSizes.defaultSpace,
                    top: kToolbarHeight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTimeBasedGreeting(context),
                          Obx(() {
                            final user =
                                Get.find<AuthController>().firebaseUser.value;
                            String username = user?.displayName ?? 'User';
                            return Text(
                              username,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .apply(color: BColors.white),
                            );
                          }),
                        ],
                      ),
                      _buildAppBarAction(
                        icon: Iconsax.notification,
                        color: BColors.white,
                        onPressed: () {},
                        showBadge: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: BSizes.spaceBtwItems + 10),
                // Search and filter row directly below greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BSizes.defaultSpace),
                  child: _buildSearchFilterRow(
                    context,
                    elevated: false,
                    background: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchFilterRow(BuildContext context,
      {bool elevated = false, Color? background}) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(BSizes.cardRadiusLg),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha((0.07 * 255).toInt()),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Row(
        children: [
          // Make search bar take most of the width
          Expanded(
            flex: 5,
            child: _buildSearchBar(context),
          ),
          const SizedBox(width: 6),
          // Make filter button smaller
          Flexible(
            flex: 1,
            child: _buildFilterButton(context),
          ),
        ],
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
      style: Theme.of(context)
          .textTheme
          .labelMedium!
          .apply(color: BColors.lightGrey), // Corrected color back to grey
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(30),
      color: Colors.transparent,
      child: TextField(
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: BColors.darkerGrey.withOpacity(0.7)),
          prefixIcon: const Icon(Iconsax.search_normal,
              color: BColors.primary, size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded, color: BColors.lightGrey, size: 20),
            onPressed: () {
              // Clear action
            },
          ),
          filled: true,
          fillColor: BColors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: BColors.primary.withOpacity(0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: BColors.primary.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: BColors.primary, width: 1.2),
          ),
        ),
        textInputAction: TextInputAction.search,
        onTap: () {
          _searchFocusNode.requestFocus();
        },
        onSubmitted: (value) {
          // Handle search submit
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Material(
      color: BColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: BColors.primary.withAlpha((0.15 * 255).toInt()),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          // Handle filter action
        },
        child: Padding(
          padding: const EdgeInsets.all(10), // Smaller, rounder button
          child: Icon(
            Iconsax.setting_4,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(
      {required IconData icon,
      Color? color,
      VoidCallback? onPressed,
      bool showBadge = false}) {
    // Updated to accept color and onPressed
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon,
              color: color ?? BColors.darkGrey,
              size: BSizes
                  .iconLg), // Use provided color or default, slightly larger icon
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
                  border: Border.all(
                      width: 2, color: BColors.white) // Thicker border
                  ),
              constraints: const BoxConstraints(
                minWidth: 18, // Slightly larger badge
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  '2', // Example badge count
                  style: const TextStyle(
                    // Consider defining badge text style in theme
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
      height: 200, // Keep height or make dynamic
      decoration: BoxDecoration(
        // Use a gradient or image based on the design
        color: Colors.pink.shade100, // Example color
        borderRadius:
            BorderRadius.circular(BSizes.borderRadiusLg), // Use BSizes
      ),
      child: const Center(
          child: Text('Promo Banner Placeholder')), // Add actual content
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    // Placeholder for categories - Replace with actual implementation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            context, 'Categories'), // Correctly call _buildSectionHeader here
        const SizedBox(height: BSizes.spaceBtwItems), // Use BSizes
        SizedBox(
          height: 85, // Adjust height based on content + padding
          child: Stack(
            children: [
              ListView.separated(
                itemCount: 8, // Example count
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: BSizes.spaceBtwItems), // Use BSizes
                itemBuilder: (context, index) =>
                    _buildCategoryItem(context, index), // Use actual item builder
              ),
              // Right-side gradient overlay
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 36,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color.fromARGB(0, 255, 255, 255),
                          BColors.light,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {VoidCallback? onPressed}) {
    // Ensure this definition is clean
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall, // Use appropriate style
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (onPressed != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              'See more',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: BColors.primary), // Style for see more
            ), // Add missing closing parenthesis
          ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    // Placeholder icons and text - ideally fetch from data source
    final icons = [
      Iconsax.watch, Iconsax.bag, Iconsax.magicpen,
      Iconsax.tag, // Replaced shirt with tag
      Iconsax.category, Iconsax.category, Iconsax.bezier,
      Iconsax.menu // Replaced boot with category
    ];
    final labels = [
      'Watches',
      'Bags',
      'Beauty',
      'Clothing',
      'Accessories',
      'Shoes',
      'Lifestyle',
      'More'
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
              border: Border.all(
                  color: BColors.lightGrey.withAlpha((0.5 * 255).toInt()))),
          child: Center(
            child: Icon(icons[index],
                color: BColors.primary, size: BSizes.iconLg), // Use BSizes
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Recommended', onPressed: () {
          // Handle "See more" action
        }),
        // Calculate dynamic height for the grid
        Builder(
          builder: (context) {
            final products = [
              {
                'title': 'Classic Wrist Watch',
                'price': 'PHP 1,299',
                'discountedPrice': '₱1,499',
                'rating': 4.8,
                'badge': 'Discount',
              },
              {
                'title': 'Leather Handbag',
                'price': 'PHP 799',
                'discountedPrice': '',
                'rating': 4.6,
                'badge': 'New',
              },
              {
                'title': 'Modern Table Lamp',
                'price': 'PHP 2,099',
                'discountedPrice': '₱2,499',
                'rating': 4.9,
                'badge': 'Lowest Price',
              },
              {
                'title': 'Wireless Headphones Marshall',
                'price': 'PHP 1,599',
                'discountedPrice': '',
                'rating': 4.3,
                'badge': 'Free Shipping',
              },
              {
                'title': 'Eco Water Bottle',
                'price': 'PHP 999',
                'discountedPrice': '₱1,099',
                'rating': 4.7,
                'badge': 'Discount',
              },
            ];
            int itemCount = products.length;
            int crossAxisCount = 2;
            double cardHeight = 220;
            double mainAxisSpacing = 12;
            int rowCount = (itemCount / crossAxisCount).ceil();
            double gridHeight = (cardHeight * rowCount) + (mainAxisSpacing * (rowCount - 1)) + 12; // +12 for top padding
            final double gridWidth = MediaQuery.of(context).size.width - 2 * BSizes.defaultSpace;
            final double tileWidth = (gridWidth - (crossAxisCount - 1) * mainAxisSpacing) / crossAxisCount;
            final double childAspectRatio = tileWidth / cardHeight;
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: mainAxisSpacing,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final product = products[index % products.length];
                  return ProductCardMinimal(
                    imageUrl: 'assets/images/products/sample-product.png',
                    title: product['title'] as String,
                    price: product['price'] as String,
                    discountedPrice: product['discountedPrice'] as String,
                    rating: product['rating'] as double,
                    badge: product['badge'] as String,
                    onWishlist: () {},
                  );
                },
              );
          },
        ),
      ],
    );
  }

// Removed _buildProductCardPlaceholder as it's replaced by BProductCardVertical
} // Add missing closing brace for HomeScreen class

// Sticky blue search/filter row widget for sliver
class _StickyBlueSearchFilterDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Color backgroundColor;
  final Widget Function(BuildContext context, bool pinned) builder;
  _StickyBlueSearchFilterDelegate({
    required this.builder,
    required double minExtent,
    required double maxExtent,
    required this.backgroundColor,
  })  : _minExtent = minExtent,
        _maxExtent = maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final bool pinned = shrinkOffset > 0.0;
    return Container(
      color: pinned ? backgroundColor : Colors.transparent,
      padding: EdgeInsets.only(
        top: pinned ? MediaQuery.of(context).padding.top + 8 : 8,
        left: 0,
        right: 0,
        bottom: 8,
      ),
      child: builder(context, pinned),
    );
  }

  @override
  double get minExtent => _minExtent;
  @override
  double get maxExtent => _maxExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
