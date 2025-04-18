import 'package:bytebazaar/features/home/screens/home_screen.dart'; // Import the actual HomeScreen
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart'; // Import sizes for padding/height
import '../../utils/helpers/helper_functions.dart';

// Placeholder Screens should be defined in their respective feature directories
// Example: lib/features/wishlist/screens/wishlist_screen.dart

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // List of Widgets to display based on the selected index
  // Replace these placeholders with your actual screen widgets when created
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Use the imported HomeScreen
    const Scaffold(body: Center(child: Text('Wishlist Screen Placeholder'))),
    const Scaffold(body: Center(child: Text('Cart Screen Placeholder'))),
    const Scaffold(body: Center(child: Text('Chat Screen Placeholder'))),
    const Scaffold(body: Center(child: Text('Profile Screen Placeholder'))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = BHelperFunctions.isDarkMode(context);

    return Scaffold(
      // Extend body behind the navbar for seamless look with transparency/rounding
      extendBody: true,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? BColors.dark : BColors.background, // Use background color
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(BSizes.cardRadiusLg), // Use constant size
            topRight: Radius.circular(BSizes.cardRadiusLg), // Use constant size
          ),
          boxShadow: [ // Optional: Add shadow for better visual separation
            BoxShadow(
              color: BColors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect( // Clip the content to match the container's border radius
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(BSizes.cardRadiusLg),
            topRight: Radius.circular(BSizes.cardRadiusLg),
          ),
          child: BottomNavigationBar(
            // Adjust height slightly to give icons more vertical space if needed
            // height: 60, // Example height adjustment
            elevation: 0, // Remove default elevation since Container provides shadow
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: 'Wishlist'),
              BottomNavigationBarItem(icon: Icon(Iconsax.shopping_bag), label: 'Cart'),
              BottomNavigationBarItem(icon: Icon(Iconsax.message), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: BColors.primary,
            unselectedItemColor: BColors.darkerGrey,
            backgroundColor: Colors.transparent, // Crucial for rounded corners effect
            type: BottomNavigationBarType.fixed, // Ensures all items are visible & spaced evenly
            showUnselectedLabels: true, // Shows labels for unselected items
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
