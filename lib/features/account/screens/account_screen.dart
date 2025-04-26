import 'package:bytebazaar/features/account/screens/account_settings.dart';
import 'package:bytebazaar/features/account/screens/seller_registration.dart'; // Added import
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/features/account/widgets/no_internet_widget.dart'; // Import the widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser == null) {
        setState(() {
          _isLoading = false;
          _error = 'User not logged in.';
        });
        return;
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'User data not found.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _shortUid(String? uid) {
    if (uid == null || uid.length < 10) return uid ?? '-';
    return uid.substring(0, 6) + '...' + uid.substring(uid.length - 4);
  }

  String _formatBirthday(dynamic birthday) {
    if (birthday == null) return '-';
    if (birthday is String) return birthday;
    try {
      // Firestore Timestamp
      if (birthday is Timestamp) {
        final dt = birthday.toDate();
        return "${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}";
      }
      // If it's a DateTime
      if (birthday is DateTime) {
        return "${birthday.month.toString().padLeft(2, '0')}/${birthday.day.toString().padLeft(2, '0')}/${birthday.year}";
      }
    } catch (_) {}
    return birthday.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Show Lottie animation if Firestore is unavailable (no internet)
    if (_error != null && _error!.contains('unavailable')) {
      return const Scaffold(
        body: NoInternetWidget(),
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button, title, and settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Removed GestureDetector wrapper for back button functionality
                    Row(
                      children: [
                        // Removed back Icon(Icons.arrow_back_ios, color: Colors.white),
                        // Removed SizedBox(width: 8.0),
                        Text( // Keep the title
                          'MY ACCOUNT',
                          style: TextStyle(
                            fontFamily: 'BebasNeue',
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector( // Keep the settings button
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                      ),
                      child: Icon(Icons.settings, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Profile section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                                  : Column(
                                      children: [
                                        // Profile image
                                        CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            size: 60.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8.0),
                                        // Name and User ID
                                        Text(
                                          _userData?['fullName'] ?? _firebaseUser?.displayName ?? 'No Name',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: BColors.primary,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'User ID: ${_shortUid(_firebaseUser?.uid)}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.grey,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        const SizedBox(height: 16.0),
                                        // User details
                                        _buildUserInfoRow('Email:', _userData?['email'] ?? _firebaseUser?.email ?? '-'),
                                        _buildUserInfoRow('Contact No:', _userData?['phone'] ?? '-'),
                                        _buildUserInfoRow('Birthday:', _formatBirthday(_userData?['birthday'])),
                                        _buildUserInfoRow('Occupation:', _userData?['occupation'] ?? '-'),
                                        _buildUserInfoRow('Address:', "${_userData?['street']}, ${_userData?['city']}, ${_userData?['province']}, ${_userData?['country']}"),
                                        const SizedBox(height: 16.0),
                              
                              // Manage account button
                              ElevatedButton(
                                onPressed: () => Navigator.push( // Navigate to SellerRegistrationScreen
                                  context,
                                  MaterialPageRoute(builder: (context) => const SellerRegistrationScreen()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: BColors.primary,
                                  minimumSize: Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Text(
                                  'BECOME A SELLER',
                                  style: TextStyle(
                                    fontFamily: 'BebasNeue',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // E-Wallet section
                        _buildSectionContainer(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'MY E-WALLET',
                          content: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '\u20B1500.00', // Use Unicode escape for Peso sign
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4285F4),
                                    minimumSize: Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'CASH IN',
                                    style: TextStyle(
                                      fontFamily: 'BebasNeue',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Vouchers section
                        _buildSectionContainer(
                          icon: Icons.local_offer_outlined,
                          title: 'MY VOUCHERS',
                          content: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BColors.primary,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              '64 EXISTING VOUCHERS',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16.0),
                        
                        // Shop section
                        _buildSectionContainer(
                          icon: Icons.store_outlined,
                          title: 'MY SHOP',
                          content: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFF1A4B8F),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                // Replace network image with an icon or local asset if available
                                Container( // Placeholder container for the shop image
                                  width: 48,
                                  height: 48,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.store, color: Colors.grey[600]),
                                ),
                                SizedBox(width: 16.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() {
                                      final user = Get.find<AuthController>().firebaseUser.value;
                                      String username;
                                      if (user != null) {
                                        username = user.displayName ?? (user.email?.split('@')[0] ?? 'User');
                                      } else {
                                        username = 'User';
                                      }
                                      return Text(
                                        username,
                                        style: TextStyle(
                                          fontFamily: 'BebasNeue',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      );
                                    }),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < 4 ? Icons.star : Icons.star_half,
                                          color: Colors.white,
                                          size: 18.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({IconData? icon, required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
        children: [
          Row( // Use Row to place icon and title side-by-side
            children: [
              if (icon != null) ...[ // Conditionally display icon
                Icon(icon, color: BColors.primary, size: 20.0),
                SizedBox(width: 8.0),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  color: BColors.primary,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          content,
        ],
      ),
    );
  }
}
