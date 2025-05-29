import 'package:bytebazaar/features/account/screens/account_screen.dart';
import 'package:bytebazaar/features/authentication/screens/signup/registration_screen.dart';
import 'package:bytebazaar/features/cart/screens/cart_screen.dart';
import 'package:bytebazaar/features/chat/screens/chat_screen.dart';
import 'package:bytebazaar/features/home/screens/home_screen.dart';
import 'package:bytebazaar/features/wishlist/screens/wishlist_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bytebazaar/utils/user_firestore_helper.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_functions.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}


class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  void _checkRegistration() async {
    final registered = await isUserRegistered();
    if (!registered && mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RegistrationScreen(email: user.email ?? '', displayName: user.displayName),
          ),
        );
      }
    }
  }
  int _selectedIndex = 0;

  // List of Widgets to display based on the selected index
  // Replace these placeholders with your actual screen widgets when created
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(), // Use the imported HomeScreen
    const WishlistScreen(), // Use the imported WishlistScreen
    const CartScreen(),
    const ChatScreen(),
    const AccountScreen(),
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? BColors.dark : BColors.white, // Use background color
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
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
              const BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: 'Wishlist'),
              BottomNavigationBarItem(
                icon: _CartIconWithBadge(),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(icon: Icon(Iconsax.message), label: 'Chat'),
              const BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Me'),
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

class _CartIconWithBadge extends StatelessWidget {
  const _CartIconWithBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Icon(Iconsax.shopping_bag);
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Iconsax.shopping_bag),
            if (count > 0)
              Positioned(
                right: -6,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

