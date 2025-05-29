import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bytebazaar/features/products/_modern_product_card.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/features/products/product_details.dart';
import 'package:bytebazaar/features/products/category_filter_dialog.dart';
import 'package:lottie/lottie.dart';
import 'search_results_screen_utils.dart';

class SearchResultsScreen extends StatefulWidget {
  final String searchTerm;
  final String? category;

  const SearchResultsScreen({Key? key, required this.searchTerm, this.category})
      : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String? _selectedCategory;
  String _sortBy = 'Relevance';
  final List<String> _sortOptions = [
    'Relevance',
    'Price: Low to High',
    'Price: High to Low',
    'Rating',
    'Newest',
  ];

  Widget _noProductsWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 180,
            child: Lottie.asset(
              'assets/lottie/no-search.json',
              repeat: true,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _searchProducts() async* {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('products');
    String? categoryToUse = _selectedCategory ?? widget.category;
    if (categoryToUse != null && categoryToUse.isNotEmpty) {
      // Get all relevant category names (parent + subcategories)
      final allCategories = await getAllCategoryNamesForParent(categoryToUse);
      if (allCategories.length > 1) {
        // Parent category with subcategories: use whereIn
        query = query.where('category', whereIn: allCategories);
      } else {
        // Just a single category
        query = query.where('category', isEqualTo: categoryToUse);
      }
    }
    // Optionally: add orderBy for 'Newest'
    if (_sortBy == 'Newest') {
      query = query.orderBy('createdAt', descending: true);
    } else if (_sortBy == 'Best Rated') {
      query = query.orderBy('rating', descending: true);
    }
    yield* query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: BColors.light,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: Container(
            decoration: BoxDecoration(
              color: BColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: BColors.primary.withOpacity(0.16),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding:
                const EdgeInsets.only(top: 36, left: 24, right: 24, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    'Search Results',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Optionally, add a user/profile icon or branding here
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final cat = await showDialog<String>(
                          context: context,
                          builder: (context) =>
                              CategoryFilterDialog(selected: _selectedCategory),
                        );
                        if (cat != null) setState(() => _selectedCategory = cat);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: BColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt_outlined,
                                color: BColors.primary, size: 20),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _selectedCategory == null ||
                                        _selectedCategory!.isEmpty
                                    ? 'Filter'
                                    : _selectedCategory!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: BColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: BColors.primary, fontWeight: FontWeight.w600),
                        icon: Icon(Icons.sort, color: BColors.primary),
                        value: _sortBy,
                        items: _sortOptions
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _sortBy = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _noProductsWidget(context);
                  }
                  // Filter results by search term
                  final filtered = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final desc =
                        (data['description'] ?? '').toString().toLowerCase();
                    final term = widget.searchTerm.toLowerCase();
                    return name.contains(term) || desc.contains(term);
                  }).toList();

                  if (filtered.isEmpty) {
                    return _noProductsWidget(context);
                  }

                  // Sorting (client-side for price)
                  if (_sortBy == 'Price: Low to High') {
                    filtered.sort((a, b) {
                      double getPrice(doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final variations = (data['variations'] as List?) ?? [];
                        if (variations.isNotEmpty && variations[0] is Map) {
                          final varMap = variations[0] as Map<String, dynamic>;
                          return double.tryParse(
                                  varMap['price']?.toString() ?? '0') ??
                              0;
                        }
                        return 0;
                      }

                      final va = getPrice(a);
                      final vb = getPrice(b);
                      return va.compareTo(vb);
                    });
                  } else if (_sortBy == 'Price: High to Low') {
                    filtered.sort((a, b) {
                      double getPrice(doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final variations = (data['variations'] as List?) ?? [];
                        if (variations.isNotEmpty && variations[0] is Map) {
                          final varMap = variations[0] as Map<String, dynamic>;
                          return double.tryParse(
                                  varMap['price']?.toString() ?? '0') ??
                              0;
                        }
                        return 0;
                      }

                      final va = getPrice(a);
                      final vb = getPrice(b);
                      return vb.compareTo(va);
                    });
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                        child: Text('No products match your search.'));
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        final data = doc.data();
                        Map<String, dynamic> safeData = {};
                        if (data is Map<String, dynamic>) {
                          safeData = data;
                        }
                        final images = (safeData['images'] is List)
                            ? safeData['images'] as List
                            : [];
                        final imageUrl = images.isNotEmpty ? images[0] : '';
                        final title = (safeData['name'] != null)
                            ? safeData['name'].toString()
                            : '';
                        String location = 'N/A';
                        if (safeData['shopId'] != null && safeData['shopId'].toString().isNotEmpty) {
                          location = '...'; // Will be asynchronously replaced below
                        } else if (safeData['shipping'] is Map &&
                            (safeData['shipping'] as Map)['location'] != null) {
                          location = (safeData['shipping'] as Map)['location']
                              .toString();
                        }
                        final variations = (safeData['variations'] is List)
                            ? safeData['variations'] as List
                            : [];
                        String price = '0';
                        String discountedPrice = '0';
                        if (variations.isNotEmpty && variations[0] is Map) {
                          final varMap = variations[0] as Map;
                          price = (varMap['price'] ?? '0').toString();
                          discountedPrice = price;
                        }
                        final rating = (safeData['rating'] is num)
                            ? (safeData['rating'] as num).toDouble()
                            : 0.0;
                        final sold = (safeData['sold'] is int)
                            ? safeData['sold'] as int
                            : 0;
                        if (safeData['shopId'] == null || safeData['shopId'].toString().isEmpty) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ViewProduct(
                                    productId: doc.id,
                                    productData: Map<String, dynamic>.from(safeData),
                                  ),
                                ),
                              );
                            },
                            child: ModernProductCard(
                              imageUrl: imageUrl,
                              title: title,
                              location: location,
                              price: price,
                              discountedPrice: discountedPrice,
                              rating: rating,
                              sold: sold,
                            ),
                          );
                        }
                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance.collection('shops').doc(safeData['shopId']).get(),
                          builder: (context, shopSnapshot) {
                            String shopLocation = 'N/A';
                            if (shopSnapshot.connectionState == ConnectionState.done && shopSnapshot.hasData && shopSnapshot.data != null && shopSnapshot.data!.exists) {
                              final shopData = shopSnapshot.data!.data();
                              if (shopData != null) {
                                final city = shopData['city'] ?? '';
                                final province = shopData['province'] ?? '';
                                if (city.toString().isNotEmpty && province.toString().isNotEmpty) {
                                  shopLocation = '$city, $province';
                                } else if (city.toString().isNotEmpty) {
                                  shopLocation = city;
                                } else if (province.toString().isNotEmpty) {
                                  shopLocation = province;
                                }
                              }
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ViewProduct(
                                      productId: doc.id,
                                      productData: Map<String, dynamic>.from(safeData),
                                    ),
                                  ),
                                );
                              },
                              child: ModernProductCard(
                                imageUrl: imageUrl,
                                title: title,
                                location: shopLocation,
                                price: price,
                                discountedPrice: discountedPrice,
                                rating: rating,
                                sold: sold,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }
}
