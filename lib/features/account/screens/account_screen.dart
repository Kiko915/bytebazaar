import 'package:bytebazaar/features/account/screens/account_settings.dart';
import 'package:bytebazaar/features/account/screens/seller_registration.dart';
import 'package:bytebazaar/features/account/screens/seller_status_screen.dart';
import 'package:bytebazaar/features/account/screens/seller_dashboard_screen.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/features/account/screens/add_card_drawer.dart';
import 'package:bytebazaar/features/account/screens/ewallet_drawer.dart';
import 'package:bytebazaar/features/orders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/features/account/widgets/no_internet_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

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

  // Seller application status
  String? _sellerStatus; // 'pending', 'approved', 'rejected', or null
  String? _sellerRejectionReason;
  bool _isLoadingSellerStatus = true;
  bool _dashboardVisited = false; // This can be persisted if needed

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchSellerStatus();
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
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();
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

  Future<void> _fetchSellerStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _sellerStatus = null;
          _isLoadingSellerStatus = false;
        });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('seller_applications')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _sellerStatus = data['status'] ?? 'pending';
          _sellerRejectionReason = data['rejectionReason'];
          _isLoadingSellerStatus = false;
        });
      } else {
        setState(() {
          _sellerStatus = null;
          _isLoadingSellerStatus = false;
        });
      }
    } catch (e) {
      setState(() {
        _sellerStatus = null;
        _isLoadingSellerStatus = false;
      });
    }
  }

  String _shortUid(String? uid) {
    if (uid == null || uid.length < 10) return uid ?? '-';
    return '${uid.substring(0, 6)}...${uid.substring(uid.length - 4)}';
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
        decoration: const BoxDecoration(
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Removed GestureDetector wrapper for back button functionality
                    Row(
                      children: const [
                        // Removed back Icon(Icons.arrow_back_ios, color: Colors.white),
                        // Removed SizedBox(width: 8.0),
                        Text(
                          // Keep the title
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
                    GestureDetector(
                      // Keep the settings button
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AccountSettingsScreen()),
                      ),
                      child: const Icon(Icons.settings, color: Colors.white),
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
                                offset: const Offset(0, 4),
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                                  ? Center(
                                      child: Text(_error!,
                                          style: const TextStyle(
                                              color: Colors.red)))
                                  : Column(
                                      children: [
                                        // Profile image
                                        Obx(() {
                                          final user =
                                              Get.find<AuthController>()
                                                  .firebaseUser
                                                  .value;
                                          final photoUrl =
                                              _userData?['photoURL'] ??
                                                  user?.photoURL;
                                          return CircleAvatar(
                                            radius: 50.0,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: photoUrl != null &&
                                                    photoUrl.isNotEmpty
                                                ? NetworkImage(photoUrl)
                                                : null,
                                            child: (photoUrl == null ||
                                                    photoUrl.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 60.0,
                                                    color: Colors.grey,
                                                  )
                                                : null,
                                          );
                                        }),
                                        const SizedBox(height: 8.0),
                                        // Name and User ID
                                        Obx(() {
                                          final username =
                                              Get.find<AuthController>()
                                                  .currentUsername
                                                  .value;
                                          return Text(
                                            username.isNotEmpty
                                                ? username
                                                : (_userData?['fullName'] ??
                                                    _firebaseUser
                                                        ?.displayName ??
                                                    _firebaseUser?.email ??
                                                    'No Name'),
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: BColors.primary,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }),
                                        Text(
                                          'User ID: ${_shortUid(_firebaseUser?.uid)}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.grey,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        const SizedBox(height: 16.0),
                                        // User details
                                        _buildUserInfoRow(
                                            'Email:',
                                            _userData?['email'] ??
                                                _firebaseUser?.email ??
                                                '-'),
                                        _buildUserInfoRow('Contact No:',
                                            _userData?['phone'] ?? '-'),
                                        _buildUserInfoRow(
                                            'Birthday:',
                                            _formatBirthday(
                                                _userData?['birthday'])),
                                        _buildUserInfoRow('Occupation:',
                                            _userData?['occupation'] ?? '-'),
                                        _buildUserInfoRow('Address:',
                                            "${_userData?['street'] ?? '-'}, ${_userData?['city'] ?? ''}, ${_userData?['province'] ?? ''}, ${_userData?['country'] ?? ''}"),
                                        const SizedBox(height: 16.0),

                                        const SizedBox(height: 8.0),
                                        // Seller application status button logic
                                        _isLoadingSellerStatus
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : _buildSellerButton(context),
                                      ],
                                    ),
                        ),

                        const SizedBox(height: 16.0),

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
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Check Balance', // Use Unicode escape for Peso sign
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        // Transaction history will be fetched from backend
                                        // Stream for user doc
                                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                          stream: FirebaseFirestore.instance.collection('users').doc(_firebaseUser!.uid).snapshots(),
                                          builder: (context, userSnapshot) {
                                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Center(child: CircularProgressIndicator());
                                            }
                                            if (!userSnapshot.hasData || userSnapshot.hasError) {
                                              return const Center(child: Text('Failed to load wallet data.'));
                                            }
                                            final userData = userSnapshot.data!.data();
                                            final balance = (userData?['ewallet_balance'] ?? 0.0) as num;
                                            // Stream for transaction_history
                                            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                              stream: FirebaseFirestore.instance.collection('users').doc(_firebaseUser!.uid).collection('transaction_history').orderBy('date', descending: true).snapshots(),
                                              builder: (context, txSnapshot) {
                                                if (txSnapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                                if (txSnapshot.hasError) {
                                                  return const Center(child: Text('Failed to load transactions.'));
                                                }
                                                final transactions = txSnapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];
                                                // Show balance in My E-Wallet section
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'My E-Wallet',
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.1,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // ...rest of your wallet UI, including the button to open EWalletDrawer
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled: true,
                                                          backgroundColor: Colors.transparent,
                                                          builder: (context) {
                                                            return EWalletDrawer(
                                                              userId: _firebaseUser!.uid,
                                                              balance: balance.toDouble(),
                                                              transactions: transactions,
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: const Text('Open E-Wallet Drawer'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4285F4),
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: const Text(
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

                        const SizedBox(height: 16.0),

                        // Credit Cards section
                        _buildSectionContainer(
  icon: Icons.credit_card,
  title: 'CREDIT CARDS',
  content: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      (_userData != null && _userData!['payment_methods'] != null &&
              (_userData!['payment_methods'] as List).isNotEmpty)
          ? SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (_userData!['payment_methods'] as List).length,
                itemBuilder: (context, idx) {
                  final card = (_userData!['payment_methods'] as List)[idx] as Map<String, dynamic>;
                  final cardNum = card['number'] ?? '';
                  String last4 = cardNum.length >= 4
                      ? cardNum.substring(cardNum.length - 4)
                      : cardNum;
                  final type = (card['type'] ?? '').toString().toUpperCase();
                  final expiry = card['expiry'] ?? '';
                  final name = card['name'] ?? '';
                  // Color and gradient based on card type
                  final Gradient gradient = type == 'AMEX'
                      ? const LinearGradient(colors: [Color(0xFF43CEA2), Color(0xFF185A9D)])
                      : type == 'MASTERCARD'
                          ? const LinearGradient(colors: [Color(0xFFFFAF7B), Color(0xFFd76d77)])
                          : type == 'DISCOVER'
                              ? const LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)])
                              : const LinearGradient(colors: [Color(0xFF4285F4), Color(0xFF373B44)]);
                  return Stack(
  children: [
    Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'BebasNeue',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Icon(Icons.credit_card, color: Colors.white, size: 28),
                ],
              ),
              const SizedBox(height: 18),
              Flexible(
                child: Text(
                  '••••  ••••  ••••  $last4',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('CARD HOLDER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                            )),
                        Text(
                          name.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('EXPIRES',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                            )),
                        Text(
                          expiry,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    Positioned(
      top: 0,
      right: 0,
      child: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 24),
        tooltip: 'Delete Card',
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Card'),
              content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            final user = AuthController.to.firebaseUser.value;
            if (user == null) return;
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'payment_methods': FieldValue.arrayRemove([card])
              });
              if (context.mounted) {
                BFeedback.show(context, message: 'Card deleted', type: BFeedbackType.success);
                if (mounted) setState(() { _fetchUserData(); });
              }
            } catch (e) {
              if (context.mounted) {
                BFeedback.show(context, message: 'Failed to delete card', type: BFeedbackType.error);
              }
            }
          }
        },
      ),
    ),
  ],
);

                },
              ),
            )
          : Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'No cards added',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.0,
                  color: Colors.black54,
                ),
              ),
            ),
      const SizedBox(height: 8.0),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (_, controller) => const AddCardDrawer(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4285F4),
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'ADD CARD',
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

                        const SizedBox(height: 16.0),
// My Orders section
                        _buildSectionContainer(
                          icon: Icons.receipt_long,
                          title: 'MY ORDERS',
                          content: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.receipt_long, color: Colors.white),
                              label: const Text(
                                'View My Orders',
                                style: TextStyle(
                                  fontFamily: 'BebasNeue',
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MyOrdersScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        // Shop section (conditionally rendered)
                        if (_sellerStatus == 'approved')
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('stores')
                                .where('ownerId', isEqualTo: _firebaseUser?.uid)
                                .limit(1)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return const SizedBox();
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                // No shop found for this seller
                                return const SizedBox();
                              }
                              // Shop exists for this seller
                              final shopData = snapshot.data!.docs.first.data()
                                  as Map<String, dynamic>?;
                              return _buildSectionContainer(
                                icon: Icons.store_outlined,
                                title: 'MY SHOP',
                                content: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A4B8F),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      // Replace network image with an icon or local asset if available
                                      Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.store,
                                            color: Colors.grey[600]),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            shopData?['name'] ?? 'My Shop',
                                            style: const TextStyle(
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
                                                index < 4
                                                    ? Icons.star
                                                    : Icons.star_half,
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
                              );
                            },
                          ),

                        const SizedBox(height: 16.0),
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

  Widget _buildSellerButton(BuildContext context) {
    Color redColor = Colors.red;
    if (_sellerStatus == null) {
      // No application yet
      return ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SellerRegistrationScreen()),
        ).then((_) => _fetchSellerStatus()),
        style: ElevatedButton.styleFrom(
          backgroundColor: BColors.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: const Text(
          'BECOME A SELLER',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    if (_sellerStatus == 'pending') {
      return ElevatedButton.icon(
        icon: const Icon(Icons.hourglass_top, color: Colors.white),
        label: const Text(
          'TRACK APPLICATION',
          style: TextStyle(
            fontFamily: 'BebasNeue',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerStatusScreen(status: 'pending'),
            ),
          );
        },
      );
    }
    if (_sellerStatus == 'approved') {
      if (_dashboardVisited) {
        // Show Seller Dashboard button
        return ElevatedButton.icon(
          icon: const Icon(Icons.dashboard, color: Colors.white),
          label: const Text(
            'SELLER DASHBOARD',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SellerDashboardScreen()),
            );
          },
        );
      } else {
        // Show See Results button
        return ElevatedButton.icon(
          icon: Icon(Icons.check_circle, color: Colors.white),
          label: const Text(
            'SEE RESULTS',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellerStatusScreen(
                  status: 'approved',
                  onGoToDashboard: () {
                    setState(() {
                      _dashboardVisited = true;
                    });
                  },
                ),
              ),
            );
            setState(() {});
          },
        );
      }
    }
    if (_sellerStatus == 'rejected') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.cancel, color: redColor),
            label: const Text(
              'SEE RESULTS',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SellerStatusScreen(
                    status: 'rejected',
                    rejectionReason: _sellerRejectionReason,
                    onReapply: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SellerRegistrationScreen(),
                        ),
                      ).then((_) => _fetchSellerStatus());
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8.0),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellerRegistrationScreen(),
                ),
              ).then((_) => _fetchSellerStatus());
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: redColor),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'RE-APPLY',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
    // Fallback
    return const SizedBox.shrink();
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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

  Widget _buildSectionContainer(
      {IconData? icon, required String title, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
        children: [
          Row(
            // Use Row to place icon and title side-by-side
            children: [
              if (icon != null) ...[
                // Conditionally display icon
                Icon(icon, color: BColors.primary, size: 20.0),
                const SizedBox(width: 8.0),
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
          const SizedBox(height: 16.0),
          content,
        ],
      ),
    );
  }
}
