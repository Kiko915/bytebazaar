import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _darkMode = false;
  
  // Track which sections are expanded - all set to false by default
  // Change the value depending on the backend condition
  bool _isPersonalDetailsExpanded = false;
  bool _isDisplayExpanded = false;
  bool _isPrivacySecurityExpanded = false;
  bool _isLinkedAccountsExpanded = false;
  
  // Payment toggle states
  // Change the value depending on the backend condition
  bool _isPaypalConnected = false;
  bool _isStripeConnected = false;
  bool _isWiseConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF8FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and close button
            _buildHeader(),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile card
                      _buildProfileCard(),
                      
                      SizedBox(height: 16),
                      
                      // Settings sections
                      _buildSettingsSection(
                        title: 'Personal Details',
                        icon: Icons.person_outline,
                        isExpanded: _isPersonalDetailsExpanded,
                        onTap: () {
                          setState(() {
                            _isPersonalDetailsExpanded = !_isPersonalDetailsExpanded;
                          });
                        },
                        expandedContent: _buildPersonalDetailsContent(),
                      ),
                      
                      _buildSettingsSection(
                        title: 'Display',
                        icon: Icons.visibility_outlined,
                        isExpanded: _isDisplayExpanded,
                        onTap: () {
                          setState(() {
                            _isDisplayExpanded = !_isDisplayExpanded;
                          });
                        },
                        expandedContent: _buildDisplayContent(),
                      ),
                      
                      _buildSettingsSection(
                        title: 'Privacy and Security',
                        icon: Icons.lock_outline,
                        isExpanded: _isPrivacySecurityExpanded,
                        onTap: () {
                          setState(() {
                            _isPrivacySecurityExpanded = !_isPrivacySecurityExpanded;
                          });
                        },
                        expandedContent: _buildPrivacySecurityContent(),
                      ),
                      
                      _buildSettingsSection(
                        title: 'Linked Accounts',
                        icon: Icons.link,
                        isExpanded: _isLinkedAccountsExpanded,
                        onTap: () {
                          setState(() {
                            _isLinkedAccountsExpanded = !_isLinkedAccountsExpanded;
                          });
                        },
                        expandedContent: _buildLinkedAccountsContent(),
                      ),
                      
                      _buildSettingsSection(
                        title: 'Help Center',
                        icon: Icons.help_outline,
                        isExpanded: false,
                        onTap: () {
                          // Navigate to help center
                        },
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Log out button
                      _buildLogoutButton(),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Color(0xFFEFF8FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'SETTINGS',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile image with white stroke and shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey[300], // Placeholder background
              child: Icon(
                Icons.person,
                size: 50.0, // Adjust size as needed
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            'MARC JUSTIN ALBERTO',
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'User ID: 0123456789',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    Widget? expandedContent,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section header (always visible)
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                    ),
                  ),
                  Spacer(),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content (only visible when expanded)
          if (isExpanded && expandedContent != null)
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: expandedContent,
            ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalDetailsContent() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPersonalDetailItem(
          icon: Icons.edit_outlined,
          title: 'Edit my profile',
          onTap: () {},
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPersonalDetailItem(
          icon: Icons.settings_outlined,
          title: 'Manage account details',
          onTap: () {},
        ),
      ],
    );
  }
  
  Widget _buildDisplayContent() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildIndentedItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.nightlight_round,
                    color: Colors.grey,
                    size: 18.0,
                  ),
                  SizedBox(width: 12.0),
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              CupertinoSwitch(
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
                activeTrackColor: Color(0xFF4285F4),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPrivacySecurityContent() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPersonalDetailItem(
          icon: Icons.vpn_key_outlined,
          title: 'Change Password',
          onTap: () {},
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPersonalDetailItem(
          icon: Icons.history,
          title: 'Transaction history',
          onTap: () {},
        ),
      ],
    );
  }
  
  Widget _buildLinkedAccountsContent() {
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPaymentAccountItem(
          logo: 'paypal',
          accountNumber: 'g*****234',
          isConnected: _isPaypalConnected,
          onToggle: (value) {
            setState(() {
              _isPaypalConnected = value;
            });
          },
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPaymentAccountItem(
          logo: 'stripe',
          accountNumber: 'g*****234',
          isConnected: _isStripeConnected,
          onToggle: (value) {
            setState(() {
              _isStripeConnected = value;
            });
          },
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPaymentAccountItem(
          logo: 'razorpay',
          accountNumber: 'g*****234',
          isConnected: _isWiseConnected,
          onToggle: (value) {
            setState(() {
              _isWiseConnected = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildIndentedItem({required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 24.0), // Indentation
          Expanded(child: child),
        ],
      ),
    );
  }
  
  Widget _buildPersonalDetailItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            SizedBox(width: 24.0), // Indentation
            Icon(
              icon,
              color: Colors.grey,
              size: 18.0,
            ),
            SizedBox(width: 12.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentAccountItem({
    required String logo,
    required String accountNumber,
    required bool isConnected,
    required Function(bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(width: 24.0), // Indentation
          // Load SVG logos from assets
          SizedBox(
            width: 48,
            height: 30,
            child: logo == 'paypal' 
                ? SvgPicture.asset('assets/images/paypal_logo.svg')
                : logo == 'stripe' 
                    ? SvgPicture.asset('assets/images/stripe_logo.svg')
                    : SvgPicture.asset('assets/images/razorpay_logo.svg'),
          ),
          SizedBox(width: 12.0),
          Text(
            accountNumber,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[700],
            ),
          ),
          Spacer(),
          CupertinoSwitch(
            value: isConnected,
            onChanged: onToggle,
            activeTrackColor: Color(0xFF4285F4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.0,
      child: ElevatedButton(
        onPressed: () {
          // Handle logout
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285F4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          'LOG OUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
