import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:bytebazaar/features/products/shop_info_snippet.dart';
import 'package:bytebazaar/features/products/wishlist_service.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/cart/cart_service.dart';
import 'package:bytebazaar/features/checkout/screens/checkout_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bytebazaar/features/products/other_products_utils.dart';
import 'package:bytebazaar/features/products/widgets/other_products.dart';
import 'package:bytebazaar/features/chat/screens/chat_screen.dart';
import 'package:bytebazaar/features/chat/screens/start_chat_screen.dart';

enum ActionType { buyNow, addToCart }

class ViewProduct extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

   ViewProduct(
      {Key? key, required this.productId, required this.productData})
      : super(key: key);

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  int? _getMaxStock() {
    if (widget.productData['variations'] != null &&
        (widget.productData['variations'] as List).isNotEmpty) {
      final selected = (widget.productData['variations']
          as List)[_selectedVariationIndex] as Map<String, dynamic>;
      return selected['stock'] as int?;
    } else {
      return widget.productData['stock'] as int?;
    }
  }

  int _carouselIndex = 0;
  final SwiperController _swiperController = SwiperController();
  bool _showVariations = false;
  ActionType _actionType = ActionType.buyNow;
  String _selectedColor = 'Grey';
  int _quantity = 1;
  int _selectedVariationIndex = 0; // index of selected variation
  bool _isScrolled = false;
  bool _inWishlist = false;

  bool _isOwner = false;
  bool _ownerCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwner();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final exists = await WishlistService.isInWishlist(widget.productId);
    if (mounted) setState(() => _inWishlist = exists);
  }

  Future<void> _toggleWishlist() async {
    if (_inWishlist) {
      await WishlistService.removeFromWishlist(widget.productId);
      if (mounted) setState(() => _inWishlist = false);
    } else {
      await WishlistService.addToWishlist(widget.productId, widget.productData);
      if (mounted) {
        setState(() => _inWishlist = true);
        BFeedback.show(
          context,
          title: 'Added to Wishlist',
          message: 'Product has been added to your wishlist.',
          type: BFeedbackType.success,
        );
      }
    }
  }

  Future<void> _checkIfOwner() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isOwner = false;
        _ownerCheckComplete = true;
      });
      return;
    }
    final shopId = widget.productData['shopId'];
    if (shopId == null) {
      setState(() {
        _isOwner = false;
        _ownerCheckComplete = true;
      });
      return;
    }
    final shopDoc =
        await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
    final shopData = shopDoc.data();
    setState(() {
      _isOwner = shopData != null && shopData['ownerId'] == user.uid;
      _ownerCheckComplete = true;
    });
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text(
            'Are you sure you want to delete this product? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .delete();
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _editProduct() {
    // Placeholder: Navigate to edit screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit product coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          if (_ownerCheckComplete && _isOwner)
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit Product',
                    onPressed: _editProduct,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete Product',
                    onPressed: _deleteProduct,
                  ),
                ],
              ),
            ),
          // Main product view
          SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels > 0 &&
                          !_isScrolled) {
                        setState(() => _isScrolled = true);
                      } else if (scrollNotification.metrics.pixels <= 0 &&
                          _isScrolled) {
                        setState(() => _isScrolled = false);
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product image and details from Firestore
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('products')
                                .doc(widget.productId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Center(
                                    child: Text('Product not found'));
                              }
                              final product =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image
                                  Container(
                                    height: 400,
                                    width: double.infinity,
                                    color: Colors.transparent,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: (product['images'] != null &&
                                                  (product['images'] as List)
                                                      .isNotEmpty)
                                              ? Stack(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  children: [
                                                    SizedBox(
                                                      height: 400,
                                                      child: Swiper(
                                                        controller:
                                                            _swiperController,
                                                        itemCount:
                                                            (product['images']
                                                                    as List)
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final imgUrl =
                                                              (product['images']
                                                                      as List)[
                                                                  index];
                                                          return Image.network(
                                                            imgUrl,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Container(
                                                                color: Colors
                                                                    .grey[200],
                                                                child: const Center(
                                                                    child: Text(
                                                                        'Image not available')),
                                                              );
                                                            },
                                                          );
                                                        },
                                                        viewportFraction: 1.0,
                                                        loop: false,
                                                        onIndexChanged:
                                                            (index) {
                                                          setState(() {
                                                            _carouselIndex =
                                                                index;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 18,
                                                      left: 0,
                                                      right: 0,
                                                      child:
                                                          AnimatedSmoothIndicator(
                                                        activeIndex:
                                                            _carouselIndex,
                                                        count:
                                                            (product['images']
                                                                    as List)
                                                                .length,
                                                        effect:
                                                            const WormEffect(
                                                          dotHeight: 10,
                                                          dotWidth: 10,
                                                          activeDotColor:
                                                              Colors.blueAccent,
                                                          dotColor:
                                                              Colors.white70,
                                                        ),
                                                        onDotClicked: (index) {
                                                          _swiperController
                                                              .move(index);
                                                        },
                                                      ),
                                                    ),
                                                    // Navigation arrows
                                                    if ((product['images']
                                                                as List)
                                                            .length >
                                                        1) ...[
                                                      Positioned(
                                                        left: 8,
                                                        top: 0,
                                                        bottom: 32,
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .arrow_back_ios,
                                                              color:
                                                                  Colors.white,
                                                              size: 28),
                                                          onPressed: () {
                                                            if (_carouselIndex >
                                                                0) {
                                                              _swiperController
                                                                  .previous();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Positioned(
                                                        right: 8,
                                                        top: 0,
                                                        bottom: 32,
                                                        child: IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              color:
                                                                  Colors.white,
                                                              size: 28),
                                                          onPressed: () {
                                                            if (_carouselIndex <
                                                                (product['images']
                                                                            as List)
                                                                        .length -
                                                                    1) {
                                                              _swiperController
                                                                  .next();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                )
                                              : Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                      child: Text('No Image')),
                                                ),
                                        ),
                                        // White gradient overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.center,
                                              colors: [
                                                Colors.white.withOpacity(0.7),
                                                Colors.white.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Product details
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and price
                                        Text(
                                          product['name'] ?? '-',
                                          style: const TextStyle(
                                            color: Color(0xFF4080FF),
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        ShopInfoSnippet(
                                            shopId: product['shopId']),
                                        const SizedBox(height: 8),
                                        Text(
                                          (() {
                                            num? price;
                                            if (product['price'] != null) {
                                              price = product['price'] as num?;
                                            } else if (product['variations'] !=
                                                    null &&
                                                (product['variations'] as List)
                                                    .isNotEmpty &&
                                                (product['variations'][0]
                                                            as Map<String,
                                                                dynamic>)[
                                                        'price'] !=
                                                    null) {
                                              price = (product['variations'][0]
                                                      as Map<String, dynamic>)[
                                                  'price'] as num?;
                                            }
                                            final formatted = price != null
                                                ? price.toStringAsFixed(2)
                                                : '-';
                                            return (formatted
                                                        .startsWith('\u20B1') ||
                                                    formatted.startsWith('₱'))
                                                ? formatted
                                                : '\u20B1$formatted';
                                          })(),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        // Location and rating
                                        const SizedBox(height: 8),
                                        const SizedBox(height: 12),

                                        // Description
                                        const SizedBox(height: 16),
                                        if (product['description'] != null)
                                          Text(
                                            product['description'],
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        const SizedBox(height: 16),
                                        OtherProducts(shopId: widget.productData['shopId'] ?? ''),
                                        const SizedBox(
                                            height:
                                                80), // Space for bottom buttons
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
                ),
              ],
            ),
          ),

          // Sticky header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _isScrolled ? Colors.white : Colors.transparent,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color:
                                  _isScrolled ? BColors.primary : Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(Icons.share,
                              color:
                                  _isScrolled ? BColors.primary : Colors.black),
                          onPressed: () {
                            Share.share(
                                'Check out this product: ${widget.productData['name']} - ${widget.productData['description']}');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle),
                        child: IconButton(
                          icon: Icon(
                            _inWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _inWishlist
                                ? Colors.red
                                : (_isScrolled
                                    ? BColors.primary
                                    : Colors.black),
                          ),
                          onPressed: _toggleWishlist,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom action buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200], shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(Icons.chat_outlined, color: BColors.primary),
                        onPressed: () async {
                          final shopId = widget.productData['shopId'];
                          final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(shopId).get();
                          final shopData = shopDoc.data() as Map<String, dynamic>?;
                          print('Shop Data: $shopData');

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StartChatScreen(shopId: shopId, shopName: shopData?['name'] ?? 'Shop Name', shopLogoUrl: shopData?['logoUrl'] ?? '',),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Spacer(),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: BColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() => _actionType = ActionType.addToCart);
                          _toggleVariationsPanel();
                        },
                        child: Icon(Icons.add_shopping_cart,
                            color: BColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon:
                            const Icon(Icons.shopping_bag, color: Colors.white),
                        label: const Text('BUY',
                            softWrap: false, overflow: TextOverflow.ellipsis),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() => _actionType = ActionType.buyNow);
                          _toggleVariationsPanel();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Darkened overlay when variations panel is visible
          if (_showVariations)
            AnimatedOpacity(
              opacity: _showVariations ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: _toggleVariationsPanel,
                child: Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),

          // Variations panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showVariations ? 0 : -400,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Close button and image preview
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: (widget.productData['images'] != null &&
                                (widget.productData['images'] as List)
                                    .isNotEmpty)
                            ? Image.network(
                                (widget.productData['images'] as List)[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Text('Image'));
                                },
                              )
                            : const Center(child: Text('No Image')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                num? price;
                                num? originalPrice;
                                if (widget.productData['variations'] != null &&
                                    (widget.productData['variations'] as List)
                                        .isNotEmpty) {
                                  final selected =
                                      (widget.productData['variations']
                                              as List)[_selectedVariationIndex]
                                          as Map<String, dynamic>;
                                  price = selected['price'] as num?;
                                  originalPrice =
                                  originalPrice =
                                      selected['originalPrice'] as num?;
                                } else {
                                  price = widget.productData['price'] as num?;
                                  originalPrice = widget
                                      .productData['originalPrice'] as num?;
                                }
                                final formatted = price != null
                                    ? price.toStringAsFixed(2)
                                    : '-';
                                final formattedOriginal =
                                    (originalPrice != null &&
                                            originalPrice > (price ?? 0))
                                        ? originalPrice!.toStringAsFixed(2)
                                        : null;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (formatted.startsWith('\u20B1') ||
                                              formatted.startsWith('₱'))
                                          ? formatted
                                          : '\u20B1$formatted',
                                      style: const TextStyle(
                                        color: Color(0xFF4080FF),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    if (formattedOriginal != null)
                                      Text(
                                        (formattedOriginal
                                                    .startsWith('\u20B1') ||
                                                formattedOriginal
                                                    .startsWith('₱'))
                                            ? formattedOriginal
                                            : '\u20B1$formattedOriginal',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    Text(
                                      widget.productData["name"],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleVariationsPanel,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Variations or Single Price/Stock
                  if ((widget.productData['variations'] != null &&
                      (widget.productData['variations'] as List)
                          .isNotEmpty)) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Variations',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Variation options (dynamic)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (widget.productData['variations'] as List)
                          .asMap()
                          .entries
                          .map((entry) {
                        final idx = entry.key;
                        final variation = entry.value as Map<String, dynamic>;
                        final name = variation['name'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVariationIndex = idx;
                            });
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedVariationIndex == idx
                                  ? const Color(0xFF4080FF)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: _selectedVariationIndex == idx
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Show price and stock for selected variation
                    Builder(
                      builder: (context) {
                        final variations =
                            (widget.productData['variations'] as List);
                        if (variations.isEmpty) return SizedBox.shrink();
                        final selected = variations[_selectedVariationIndex]
                            as Map<String, dynamic>;
                        final price = selected['price'];
                        final stock = selected['stock'];
                        final formatted =
                            price != null ? price.toStringAsFixed(2) : '-';
                        return Row(
                          children: [
                            Text(
                              (formatted.startsWith('\u20B1') ||
                                      formatted.startsWith('₱'))
                                  ? formatted
                                  : '\u20B1$formatted',
                              style: const TextStyle(
                                  color: Color(0xFF4080FF),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto"),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Stock left: ${stock ?? '-'}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Text(
                          (() {
                            final price = widget.productData['price'];
                            final formatted =
                                price != null ? price.toStringAsFixed(2) : '-';
                            return (formatted.startsWith('\u20B1') ||
                                    formatted.startsWith('₱'))
                                ? formatted
                                : '\u20B1$formatted';
                          })(),
                          style: const TextStyle(
                            color: Color(0xFF4080FF),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Stock left: ${widget.productData['stock'] ?? '-'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Spacer(),

                  // Total and quantity
                  Row(
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (() {
                          num? price;
                          if (widget.productData['variations'] != null &&
                              (widget.productData['variations'] as List)
                                  .isNotEmpty) {
                            final selected = (widget.productData['variations']
                                    as List)[_selectedVariationIndex]
                                as Map<String, dynamic>;
                            price = selected['price'] as num?;
                          } else {
                            price = widget.productData['price'] as num?;
                          }
                          final total = (price ?? 0) * _quantity;
                          final formatted = total.toStringAsFixed(2);
                          return (formatted.startsWith('\u20B1') ||
                                  formatted.startsWith('₱'))
                              ? formatted
                              : '\u20B1$formatted';
                        })(),
                        style: TextStyle(
                          color: Color(0xFF4080FF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: (_getMaxStock() != null &&
                                      _quantity >= _getMaxStock()!)
                                  ? null
                                  : () {
                                      if (_getMaxStock() == null ||
                                          _quantity < _getMaxStock()!) {
                                        setState(() {
                                          _quantity++;
                                        });
                                      }
                                    },
                              disabledColor: Colors.grey,
                              color: (_getMaxStock() != null &&
                                      _quantity >= (_getMaxStock() ?? 9999999))
                                  ? Colors.grey
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Place order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _actionType == ActionType.buyNow
                            ? const Color(0xFF003D99)
                            : const Color(0xFF4080FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        if (_actionType == ActionType.addToCart) {
                          try {
                            final selectedVariation =
                                (widget.productData['variations'] != null &&
                                        (widget.productData['variations']
                                                as List)
                                            .isNotEmpty)
                                    ? (widget.productData['variations']
                                            as List)[_selectedVariationIndex]
                                        as Map<String, dynamic>
                                    : null;
                            await CartService.addToCart(
                              productId: widget.productId,
                              productData: widget.productData,
                              quantity: _quantity,
                              selectedVariation: selectedVariation,
                            );
                            BFeedback.show(
                              context,
                              title: 'Added to Cart',
                              message:
                                  'Added $_quantity ${selectedVariation != null ? (selectedVariation['name'] ?? '') : ''} to cart',
                              type: BFeedbackType.success,
                            );
                          } catch (e) {
                            BFeedback.show(
                              context,
                              title: 'Error',
                              message:
                                  'Failed to add to cart: \\${e.toString()}',
                              type: BFeedbackType.error,
                            );
                          }
                          _toggleVariationsPanel();
                        } else {
                          // Place order logic: Go to checkout with selected product, variation, and quantity
                          final selectedVariation =
                              (widget.productData['variations'] != null &&
                                      (widget.productData['variations'] as List)
                                          .isNotEmpty)
                                  ? (widget.productData['variations']
                                          as List)[_selectedVariationIndex]
                                      as Map<String, dynamic>
                                  : null;
                          final price = selectedVariation != null &&
                                  selectedVariation['price'] != null
                              ? selectedVariation['price']
                              : widget.productData['price'];
                          final imageUrl = selectedVariation != null &&
                                  selectedVariation['image'] != null
                              ? selectedVariation['image']
                              : (widget.productData['images'] != null &&
                                      (widget.productData['images'] as List)
                                          .isNotEmpty
                                  ? (widget.productData['images'] as List)[0]
                                  : null);
                          final variationWeight = selectedVariation != null
                              ? selectedVariation['weight']
                              : null;
                          final shipping = widget.productData['shipping'];
                          final shippingWeight =
                              shipping != null && shipping['weight'] != null
                                  ? shipping['weight']
                                  : null;
                          final shippingDimensions =
                              shipping != null && shipping['dimensions'] != null
                                  ? shipping['dimensions']
                                  : null;
                          final shippingDimensionsWeight =
                              shippingDimensions != null &&
                                      shippingDimensions['weight'] != null
                                  ? shippingDimensions['weight']
                                  : null;
                          final productWeight =
                              widget.productData['weight'] ?? null;
                          final weight = variationWeight ??
                              shippingWeight ??
                              shippingDimensionsWeight ??
                              productWeight;
                          final checkoutItem = {
                            ...widget.productData,
                            'productId': widget.productId,
                            'quantity': _quantity,
                            'price': price,
                            'imageUrl': imageUrl,
                            'weight': weight,
                            if (selectedVariation != null)
                              'selectedVariation': selectedVariation,
                          };
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            BFeedback.show(
                              context,
                              title: 'Not logged in',
                              message: 'Please log in to proceed to checkout.',
                              type: BFeedbackType.error,
                            );
                            return;
                          }
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                          final userInfo = userDoc.data() ?? {};
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreen(
                                selectedItems: [checkoutItem],
                                userInfo: userInfo,
                              ),
                            ),
                          );

                          _toggleVariationsPanel();
                        }
                      },
                      child: Text(
                        _actionType == ActionType.buyNow
                            ? 'PLACE ORDER'
                            : 'ADD TO CART',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  void _toggleVariationsPanel() {
    setState(() {
      _showVariations = !_showVariations;
    });
  }
}
