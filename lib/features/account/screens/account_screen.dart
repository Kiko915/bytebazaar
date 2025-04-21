import 'package:bytebazaar/features/account/screens/account_settings.dart';
import 'package:bytebazaar/features/account/screens/seller_registration.dart'; // Added import
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:bytebazaar/features/account/screens/account_settings.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                          child: Column(
                            children: [
                              // Profile image
                              CircleAvatar(
                                radius: 50.0,
                                backgroundColor: Colors.grey[300], // Slightly darker background for better icon visibility
                                child: Icon(
                                  Icons.person,
                                  size: 60.0, // Adjust size as needed
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              
                              // Name and User ID
                              Text(
                                'MARC JUSTIN ALBERTO',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: BColors.primary,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'User ID: 0123456789',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              
                              // User details
                              _buildUserInfoRow('Email:', 'mjg.alberto2@gmail.com'),
                              _buildUserInfoRow('Contact No:', '09675137365'),
                              _buildUserInfoRow('Birthday:', '11/04/2004'),
                              _buildUserInfoRow('Occupation:', 'Student'),
                              _buildUserInfoRow('Address:', 'Santa Cruz, Laguna'),
                              
                              SizedBox(height: 16.0),
                              
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
                                    Text(
                                      'SHOP NI MARC',
                                      style: TextStyle(
                                        fontFamily: 'BebasNeue',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
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
