import 'package:flutter/material.dart';
import 'package:bytebazaar/features/products/other_products_utils.dart';
import 'package:bytebazaar/features/products/_modern_product_card.dart';
import 'package:bytebazaar/features/products/product_details.dart';

class OtherProducts extends StatefulWidget {
  final String shopId;

  const OtherProducts({Key? key, required this.shopId}) : super(key: key);

  @override
  State<OtherProducts> createState() => _OtherProductsState();
}

class _OtherProductsState extends State<OtherProducts> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

 Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    final products = await fetchRandomProducts(excludeProductId: widget.shopId);
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Products You Might Like',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProduct(
                              productId: product['id'],
                              productData: product,
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        child: ModernProductCard(
                          imageUrl: product['images'] != null && (product['images'] as List).isNotEmpty ? (product['images'] as List)[0] : '',
                          title: product['name'] ?? '',
                          location: product['shop']?['address'] ?? 'Unknown Location',
                          price: (product['variations'] != null && (product['variations'] as List).isNotEmpty ? (product['variations'] as List)[0]['price'] : 0).toString(),
                          discountedPrice: (product['variations'] != null && (product['variations'] as List).isNotEmpty ? (product['variations'] as List)[0]['price'] : 0).toString(),
                          rating: (product['rating'] ?? 0).toDouble(),
                          sold: product['orders'] ?? 0,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
