import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/features/checkout/screens/checkout_screen.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/products/product_details.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool editMode = false;
  Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: null,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          BTexts.cartTitle,
                          style: const TextStyle(
                            fontFamily: 'BebasNeue',
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          editMode = !editMode;
                          if (!editMode) selectedItems.clear();
                        });
                        BFeedback.show(
                          context,
                          title: editMode ? 'Edit Mode' : 'View Mode',
                          message: editMode
                              ? 'You can now select and edit cart items.'
                              : 'Exited edit mode.',
                          type: BFeedbackType.info,
                          position: BFeedbackPosition.top,
                        );
                      },
                      child: Icon(editMode ? Icons.close : Icons.edit,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: user == null
                    ? Center(child: Text('Please log in to view your cart.'))
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('cart')
                            .orderBy('addedAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/lottie/empty-cart.json',
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                  ),
                                  const SizedBox(height: BSizes.spaceBtwItems),
                                  Text(
                                    BTexts.cartEmpty,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }
                          final cartDocs = snapshot.data!.docs;
                          return Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  itemCount: cartDocs.length,
                                  separatorBuilder: (context, idx) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, idx) {
                                    final cart = cartDocs[idx].data()
                                        as Map<String, dynamic>;
                                    final product = cart['productData']
                                        as Map<String, dynamic>?;
                                    final variation = cart['variation']
                                        as Map<String, dynamic>?;
                                    final imageUrl = product != null &&
                                            product['images'] != null &&
                                            (product['images'] as List)
                                                .isNotEmpty
                                        ? product['images'][0]
                                        : null;
                                    return GestureDetector(
                                        onTap: () {
                                          if (product != null &&
                                              product['id'] != null) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewProduct(
                                                  productId: product['id'],
                                                  productData: product,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 10),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: imageUrl != null
                                                      ? Image.network(
                                                          imageUrl,
                                                          width: 64,
                                                          height: 64,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Container(
                                                          width: 64,
                                                          height: 64,
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Icon(
                                                              Icons
                                                                  .shopping_bag,
                                                              size: 32,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        product?['name'] ??
                                                            'Product',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      if (variation != null &&
                                                          variation['name'] !=
                                                              null)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 2.0),
                                                          child: Text(
                                                            'Variation: ${variation['name']}',
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors
                                                                    .blueGrey),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4.0),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          7,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .blue[50],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            7),
                                                              ),
                                                              child: Text(
                                                                'Qty: ${cart['quantity'] ?? 1}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black87),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                              product != null
                                                                  ? '₱${variation != null ? variation['price'] : product['price'] ?? '-'}'
                                                                  : '-',
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xFF003D99),
                                                                fontFamily:
                                                                    'Roboto',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: selectedItems.contains(
                                                      cartDocs[idx].id),
                                                  onChanged: (checked) {
                                                    setState(() {
                                                      if (checked == true) {
                                                        selectedItems.add(
                                                            cartDocs[idx].id);
                                                      } else {
                                                        selectedItems.remove(
                                                            cartDocs[idx].id);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                  },
                                ),
                              ),
                              if (editMode && selectedItems.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    label: const Text('Delete Selected'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    onPressed: () async {
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        for (final docId in selectedItems) {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .collection('cart')
                                              .doc(docId)
                                              .delete();
                                        }
                                        setState(() {
                                          selectedItems.clear();
                                        });
                                        BFeedback.show(
                                          context,
                                          title: 'Deleted',
                                          message:
                                              'Selected items removed from cart.',
                                          type: BFeedbackType.success,
                                          position: BFeedbackPosition.top,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total: ₱${(() {
                                          double total = 0.0;
                                          for (final doc in cartDocs) {
                                            if (selectedItems
                                                .contains(doc.id)) {
                                              final cart = doc.data()
                                                  as Map<String, dynamic>;
                                              final product =
                                                  cart['productData']
                                                      as Map<String, dynamic>?;
                                              final variation =
                                                  cart['variation']
                                                      as Map<String, dynamic>?;
                                              final price = variation != null
                                                  ? (variation['price'] is num
                                                      ? variation['price']
                                                          .toDouble()
                                                      : double.tryParse(
                                                              variation['price']
                                                                  .toString()) ??
                                                          0.0)
                                                  : (product != null
                                                      ? (product['price'] is num
                                                          ? product['price']
                                                              .toDouble()
                                                          : double.tryParse(product[
                                                                      'price']
                                                                  .toString()) ??
                                                              0.0)
                                                      : 0.0);
                                              final qty = cart['quantity']
                                                      is int
                                                  ? cart['quantity']
                                                  : int.tryParse(
                                                          cart['quantity']
                                                              .toString()) ??
                                                      1;
                                              total += price * qty;
                                            }
                                          }
                                          return total.toStringAsFixed(2);
                                        })()}',
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF003D99),
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: selectedItems.isNotEmpty
                                          ? () async {
                                              // Gather selected cart items
                                              final selectedCartItems =
                                                  <Map<String, dynamic>>[];
                                              for (final doc in cartDocs) {
                                                if (selectedItems
                                                    .contains(doc.id)) {
                                                  final cart = doc.data()
                                                      as Map<String, dynamic>;
                                                  final product = cart[
                                                          'productData']
                                                      as Map<String, dynamic>?;
                                                  final variation = cart[
                                                          'variation']
                                                      as Map<String, dynamic>?;
                                                  selectedCartItems.add({
                                                    ...cart,
                                                    'id': doc.id,
                                                    'name': product?['name'],
                                                    'imageUrl': (product?[
                                                                    'images'] !=
                                                                null &&
                                                            product?['images']
                                                                is List &&
                                                            (product?['images']
                                                                    as List)
                                                                .isNotEmpty)
                                                        ? (product?['images']
                                                            as List)[0]
                                                        : null,
                                                    'price': (variation !=
                                                                null &&
                                                            variation[
                                                                    'price'] !=
                                                                null)
                                                        ? variation['price']
                                                        : (product?['price'] ??
                                                            0),
                                                    'quantity':
                                                        cart['quantity'] ?? 1,
                                                    'dimensions': product?['dimensions'],
                                                    'weight': product?['dimensions']?['weight'],
                                                  });
                                                }
                                              }
                                              // Fetch user info from Firestore
                                              final userDoc =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(user.uid)
                                                      .get();
                                              final userInfo =
                                                  userDoc.data() ?? {};
                                              // Navigate to CheckoutScreen
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CheckoutScreen(
                                                    selectedItems:
                                                        selectedCartItems,
                                                    userInfo: userInfo,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: BColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 28, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      child: const Text('Checkout',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
