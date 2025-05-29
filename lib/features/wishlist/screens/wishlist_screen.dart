
import 'package:bytebazaar/utils/constants/image_strings.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/utils/constants/text_strings.dart';
import 'package:bytebazaar/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/wishlist/wishlist_repository.dart';
import 'package:bytebazaar/features/products/wishlist_service.dart';
import 'package:bytebazaar/features/products/product_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = BHelperFunctions.isDarkMode(context);

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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          BTexts.wishlistTitle,
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
                      onTap: () async {
                        await WishlistService.clearWishlist();
                        BFeedback.show(
                          context,
                          title: 'Wishlist Cleared',
                          message: 'All wishlist items removed.',
                          type: BFeedbackType.info,
                        );
                      },
                      child: const Icon(Icons.delete_sweep, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: WishlistRepository.wishlistStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              BImages.notFoundAnimation,
                              width: BHelperFunctions.screenWidth() * 0.6,
                            ),
                            const SizedBox(height: BSizes.spaceBtwItems),
                            Text(
                              BTexts.wishlistEmpty,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: BSizes.spaceBtwSections),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final product = items[i];
                        final shopId = product['shopId'];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewProduct(
                                  productId: product['id'],
                                  productData: product,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Product Image
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: product['images'] != null && (product['images'] as List).isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            (product['images'] as List)[0],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                        ),
                                ),
                                // Product Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                product['name'] ?? '-',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Color(0xFF222B45),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            StatefulBuilder(
                                              builder: (context, setHeartState) {
                                                return IconButton(
                                                  icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
                                                  splashRadius: 20,
                                                  tooltip: 'Remove from wishlist',
                                                  onPressed: () async {
                                                    await WishlistService.removeFromWishlist(product['id']);
                                                    BFeedback.show(
                                                      context,
                                                      title: 'Removed from Wishlist',
                                                      message: 'Product has been removed from your wishlist.',
                                                      type: BFeedbackType.info,
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product['price'] != null ? '₱ ${product['price'].toString()}' : '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF4080FF),
                                          ),
                                        ),
                                        FutureBuilder<DocumentSnapshot>(
                                          future: shopId != null ? FirebaseFirestore.instance.collection('shops').doc(shopId).get() : null,
                                          builder: (context, shopSnap) {
                                            if (shopSnap.connectionState == ConnectionState.waiting) {
                                              return const SizedBox(height: 18, child: LinearProgressIndicator(minHeight: 2));
                                            }
                                            if (!shopSnap.hasData || shopSnap.data == null || !shopSnap.data!.exists) {
                                              return const SizedBox.shrink();
                                            }
                                            final shopData = shopSnap.data!.data() as Map<String, dynamic>?;
                                            if (shopData == null) return const SizedBox.shrink();
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if ((shopData['name'] ?? '').toString().isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.store, size: 15, color: Colors.blueAccent),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            shopData['name'],
                                                            style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if ((shopData['city'] ?? '').toString().isNotEmpty || (shopData['province'] ?? '').toString().isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 3),
                                                        Flexible(
                                                          child: Text(
                                                            ((shopData['city'] ?? '-') + ', ' + (shopData['province'] ?? '-')),
                                                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
