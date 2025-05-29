import 'package:bytebazaar/common/widgets/custom_shapes/curved_edges/curved_edges_clipper.dart'; // Import the clipper
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_minimal.dart';
import 'package:bytebazaar/features/products/wishlist_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/products/product_cards/product_card_descriptive.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/features/home/screens/categories_screen.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/features/products/product_details.dart';
import 'package:bytebazaar/features/products/search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  List<String> wishlistIds = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wishlist')
          .get();
      setState(() {
        wishlistIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    }
  }

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
                            final authController = Get.find<AuthController>();
                            final username = authController.currentUsername.value.isNotEmpty
                                ? authController.currentUsername.value
                                : (authController.firebaseUser.value?.email ?? 'User');
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
          if (value.trim().isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchResultsScreen(
                  searchTerm: value.trim(),
                  category: null, // Can be wired to a filter later
                ),
              ),
            );
          }
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
    return SizedBox(
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 16 / 9,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
        ),
        items: [
          Image.asset('assets/images/home/bb_1.png', fit: BoxFit.fill, width: 1920, height: 1080),
          Image.asset('assets/images/home/bb_2.png', fit: BoxFit.fill, width: 1920, height: 1080),
          Image.asset('assets/images/home/bb_3.png', fit: BoxFit.fill, width: 1920, height: 1080),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Categories',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategoriesScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: BSizes.spaceBtwItems),
        SizedBox(
          height: 85,
          child: Stack(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .where('parent', isEqualTo: "")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No categories found'));
                  }
                  final categories = snapshot.data!.docs;
                  return ListView.separated(
                    itemCount: categories.length,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: BSizes.spaceBtwItems),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryItem(context, category);
                    },
                  );
                },
              ),
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

  Widget _buildCategoryItem(BuildContext context, QueryDocumentSnapshot category) {
    final name = category['name'] ?? 'Category';
    final iconData = Iconsax.category; // Optionally map category to icon
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchTerm: '',
              category: name,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(BSizes.sm),
            decoration: BoxDecoration(
              color: BColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: BColors.lightGrey.withAlpha((0.5 * 255).toInt())),
            ),
            child: Center(
              child: Icon(iconData, color: BColors.primary, size: BSizes.iconLg),
            ),
          ),
          const SizedBox(height: BSizes.spaceBtwItems / 2),
          SizedBox(
            width: 60,
            child: Text(
              name,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Recommended', onPressed: () {
          // Handle "See more" action
        }),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').orderBy('updatedAt', descending: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            final products = snapshot.data!.docs;
            int itemCount = products.length;
            int crossAxisCount = 2;
            double cardHeight = 220;
            double mainAxisSpacing = 12;
            int rowCount = (itemCount / crossAxisCount).ceil();
            double gridHeight = (cardHeight * rowCount) + (mainAxisSpacing * (rowCount - 1)) + 12;
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
                final product = products[index];
                final data = product.data() as Map<String, dynamic>;
                final images = data['images'] as List?;
                final imageUrl = (images != null && images.isNotEmpty) ? images[0] : 'assets/images/products/sample-product.png';
                final title = data['name'] ?? '';
                final price = data['variations'] != null && data['variations'] is List && data['variations'].isNotEmpty
                    ? '₱${data['variations'][0]['price']?.toString() ?? ''}'
                    : '';
                final discountedPrice = '';
                final rating = (data['rating'] ?? 0).toDouble();
                return StatefulBuilder(
                  builder: (context, setState) {
                    bool isWishlisted = wishlistIds.contains(product.id);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => ViewProduct(
                              productId: product.id,
                              productData: data,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;
                              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              return SlideTransition(position: animation.drive(tween), child: child);
                            },
                          ),
                        );
                      },
                      child: ProductCardMinimal(
                        imageUrl: imageUrl,
                        title: title,
                        price: price,
                        discountedPrice: discountedPrice,
                        rating: rating,
                        isWishlisted: isWishlisted,
                        onWishlistToggle: () async {
                          if (isWishlisted) {
                            await WishlistService.removeFromWishlist(product.id);
                          } else {
                            await WishlistService.addToWishlist(product.id, data);
                          }
                          await _loadWishlist(); // Refresh wishlistIds for all cards
                          setState(() {
                            isWishlisted = !isWishlisted;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

// Removed _buildProductCardPlaceholder as it's replaced by BProductCardVertical
}
