import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bytebazaar/features/account/screens/account_management.dart';
import 'package:bytebazaar/features/account/screens/edit_profile.dart';
import 'package:bytebazaar/features/account/screens/change_password.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}


class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool _darkMode = false;

  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

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
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
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
    // Helper to truncate UID
    String shortUid(String? uid) {
      if (uid == null || uid.length < 10) return uid ?? '-';
      return '${uid.substring(0, 6)}...${uid.substring(uid.length - 4)}';
    }
    final name = _userData?['fullName'] ?? _firebaseUser?.displayName ?? 'No Name';
    final uid = shortUid(_firebaseUser?.uid);
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
              backgroundImage: _userData?['photoURL'] != null || _firebaseUser?.photoURL != null
                  ? NetworkImage(_userData?['photoURL'] ?? _firebaseUser!.photoURL!)
                  : null,
              child: _userData?['photoURL'] == null && _firebaseUser?.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: 50.0, // Adjust size as needed
                      color: Colors.grey[600],
                    )
                  : null,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            name,
            style: TextStyle(
              color: Color(0xFF4285F4),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'User ID: $uid',
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
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Animated expanded content
          ClipRect(
            child: AnimatedSize(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: isExpanded ? null : 0,
                child: expandedContent != null
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: expandedContent,
                    )
                  : const SizedBox(),
              ),
            ),
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
          onTap: () {
            showEditProfileModal(context);
          },
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPersonalDetailItem(
          icon: Icons.settings_outlined,
          title: 'Manage account details',
          onTap: () {
            showManageAccountDetailsModal(context);
          },
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
          onTap: () {
            showChangePasswordModal(context);
          },
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
    // Use loading or fallback if user data is not ready
    String paypal = _userData?['paypalAccount'] ?? 'Not linked';
    String stripe = _userData?['stripeAccount'] ?? 'Not linked';
    String razorpay = _userData?['razorpayAccount'] ?? 'Not linked';
    return Column(
      children: [
        Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        _buildPaymentAccountItem(
          logo: 'paypal',
          accountNumber: paypal,
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
          accountNumber: stripe,
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
          accountNumber: razorpay,
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
                ? SvgPicture.asset('assets/images/payment/paypal_logo.svg')
                : logo == 'stripe' 
                    ? SvgPicture.asset('assets/images/payment/stripe_logo.svg')
                    : SvgPicture.asset('assets/images/payment/razorpay_logo.svg'),
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
        onPressed: () async {
          final error = await AuthController.to.signOut();
          if (error == null) {
            BFeedback.show(context, title: 'Logged Out', message: 'You have been logged out.', type: BFeedbackType.success);
            Get.offAll(() => const LoginScreen());
          } else {
            BFeedback.show(context, title: 'Logout Failed', message: error ?? 'Unknown error', type: BFeedbackType.error);
          }
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

  /// Helper function to show the edit profile modal
  void showEditProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => const EditProfileModal(),
      ),
    );
  }

  /// Helper function to show the change password modal
  void showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => const ChangePasswordModal(),
      ),
    );
  }
}
