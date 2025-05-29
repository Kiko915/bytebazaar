import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/features/orders/seller_order_screen.dart';
import 'shop_settings_screen.dart';
import 'package:bytebazaar/features/products/product_creation_screen.dart';
import 'package:bytebazaar/features/products/product_details.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bytebazaar/features/chat/screens/start_chat_screen.dart';

class ShopDashboardScreen extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;
  const ShopDashboardScreen({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}



class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  int _productCount = 0;
  int _orderCount = 0;
  int _pendingOrders = 0;
  double _revenue = 0.0;
  bool _loading = true;

  List<Map<String, dynamic>> _orders = [];
  bool _ordersLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchShopStats();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() { _ordersLoading = true; });
    final ordersQuery = await FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    // Filter orders for this shop
    final filteredOrders = ordersQuery.docs.where((doc) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>? ?? [];
      return items.any((item) =>
        item is Map<String, dynamic> && item['shopId'] == widget.shopId
      );
    }).map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
    setState(() {
      _orders = filteredOrders;
      _ordersLoading = false;
    });
  }



  Future<void> _fetchShopStats() async {
    final productsQuery = await FirebaseFirestore.instance
        .collection('products')
        .where('shopId', isEqualTo: widget.shopId)
        .get();
    final ordersQuery = await FirebaseFirestore.instance
        .collection('orders')
        .where('shopId', isEqualTo: widget.shopId)
        .get();
    int pending = 0;
    double revenue = 0.0;
    for (var doc in ordersQuery.docs) {
      final data = doc.data();
      if ((data['status'] ?? '').toLowerCase() == 'pending') pending++;
      if (data['total'] != null) revenue += (data['total'] as num).toDouble();
    }
    setState(() {
      _productCount = productsQuery.docs.length;
      // _orderCount and _pendingOrders are now derived from _orders, so we don't update them here
      _revenue = revenue;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shopData;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: BColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductCreationScreen(shopId: widget.shopId),
            ),
          );
          if (created == true) {
            // Optionally refresh products list if you have one
            BFeedback.show(context, message: 'Product added!', type: BFeedbackType.success);
          }
        },
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Add Product'),
        backgroundColor: BColors.primary,
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shop['name'] ?? 'Shop Dashboard',
                      style: const TextStyle(
                        fontFamily: 'BebasNeue',
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StartChatScreen(
                            shopId: widget.shopId,
                            shopName: widget.shopData['name'] ?? 'Shop Name',
                            shopLogoUrl: widget.shopData['logoUrl'] ?? '',
                          ),
                        ),
                      );
                    },
                    tooltip: 'Chat',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ShopSettingsScreen(
                            shopId: widget.shopId,
                            shopData: widget.shopData,
                          ),
                        ),
                      );
                      if (result == true || (result is Map && result['deleted'] == true)) {
                        // If shop was updated or deleted, refresh or pop
                        if (result is Map && result['deleted'] == true) {
                          if (mounted) Navigator.of(context).pop({'deleted': true});
                        } else {
                          setState(() {}); // Optionally re-fetch shop data if needed
                        }
                      }
                    },
                    tooltip: 'Shop Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Banner
                  if (shop['bannerUrl'] != null && shop['bannerUrl'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(shop['bannerUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Shop Header
                  Row(
                    children: [
                      shop['logoUrl'] != null && shop['logoUrl'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(shop['logoUrl'], width: 70, height: 70, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: BColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.store, size: 40, color: BColors.primary),
                            ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shop['name'] ?? '-', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: BColors.primary)),
                            const SizedBox(height: 4),
                            Text(shop['category'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                            if (shop['description'] != null && shop['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(shop['description'], style: theme.textTheme.bodySmall),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Shop Location
                  if ([shop['address'], shop['city'], shop['province'], shop['country']].any((v) => v != null && v.toString().isNotEmpty))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: BColors.primary, size: 18),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            [shop['address'], shop['city'], shop['province'], shop['country']]
                                .where((v) => v != null && v.toString().isNotEmpty)
                                .join(', '),
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  // Shop Social Media
                  if ([shop['facebook'], shop['instagram'], shop['twitter'], shop['youtube']].any((v) => v != null && v.toString().isNotEmpty))
                    Row(
                      children: [
                        if (shop['facebook'] != null && shop['facebook'].toString().isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2)),
                            tooltip: 'Facebook',
                            onPressed: () => _launchUrl(shop['facebook']),
                          ),
                        if (shop['instagram'] != null && shop['instagram'].toString().isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Color(0xFFC13584)),
                            tooltip: 'Instagram',
                            onPressed: () => _launchUrl(shop['instagram']),
                          ),
                        if (shop['twitter'] != null && shop['twitter'].toString().isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
                            tooltip: 'Twitter',
                            onPressed: () => _launchUrl(shop['twitter']),
                          ),
                        if (shop['youtube'] != null && shop['youtube'].toString().isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.play_circle_fill, color: Color(0xFFFF0000)),
                            tooltip: 'YouTube',
                            onPressed: () => _launchUrl(shop['youtube']),
                          ),
                      ],
                    ),
                  const SizedBox(height: 22),
                  // Shop Stats Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statCard('Products', _productCount.toString(), Icons.inventory_2),
                      _statCard('Orders', _orders.length.toString(), Icons.shopping_cart),
                      _statCard('Pending',
                        _orders.where((o) => (o['status'] ?? '').toLowerCase() == 'pending').length.toString(),
                        Icons.hourglass_top),
                      _statCard('Revenue', '\u20B1${_revenue.toStringAsFixed(2)}', Icons.attach_money),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Recent Orders Section
                  Text('Recent Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _recentOrdersList(),
                  const SizedBox(height: 32),

                  // --- Orders Management Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Orders', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh Orders',
                        onPressed: _fetchOrders,
                      ),
                    ],
                  ),
                  _ordersLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _orders.isEmpty
                          ? const Text('No orders found.', style: TextStyle(color: Colors.grey))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _orders.length,
                              separatorBuilder: (context, idx) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final order = _orders[idx];
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: const Icon(Icons.receipt_long, color: BColors.primary),
                                    title: Text('₱${(order['total'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${order['status'] ?? '-'}'),
                                        if (order['buyerName'] != null && order['buyerName'].toString().isNotEmpty)
                                          Text('Buyer: ${order['buyerName']}', style: const TextStyle(fontSize: 13)),
                                        if (order['createdAt'] != null)
                                          Text('Created: ${_formatDate(order['createdAt'])}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SellerOrderScreen(orderId: order['id']),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  const SizedBox(height: 32),
                  // Products Section
                  Text('Products', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _productsList(),
                  const SizedBox(height: 80), // Extra space so FAB does not cover edit icon
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: BColors.primary.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: BColors.primary, size: 26),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 21, color: BColors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.black54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _recentOrdersList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('[DEBUG] No orders found (raw query)');
          return const Text('No orders yet.', style: TextStyle(color: Colors.grey));
        }
        // Filter orders for this shop
        final orders = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final items = data['items'] as List<dynamic>? ?? [];
          return items.any((item) =>
            item is Map<String, dynamic> && item['shopId'] == widget.shopId
          );
        }).toList();
        print('[DEBUG] Orders found after filtering: ${orders.length}');
        for (var doc in orders) {
          print('[DEBUG] Order data: ' + doc.data().toString());
        }
        if (orders.isEmpty) {
          return const Text('No orders yet.', style: TextStyle(color: Colors.grey));
        }
        return Column(
          children: orders.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: BColors.primary),
                title: Text('₱${(data['total'] ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Roboto')), 
                subtitle: Text('Status: ${data['status'] ?? '-'}'),
                trailing: Text(
                  data['createdAt'] != null ? _formatDate(data['createdAt']) : '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _productsList() {
    print('DEBUG: Querying products for shopId:  24{widget.shopId}');
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .where('shopId', isEqualTo: widget.shopId)
          .orderBy('createdAt', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('DEBUG: Products found:  24{snapshot.data!.docs.length}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No products yet.', style: TextStyle(color: Colors.grey));
        }
        final products = snapshot.data!.docs;
        if (products.isNotEmpty) {
          print('DEBUG: First product data:  24{products[0].data()}');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            ...products.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 7),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewProduct(
                          productId: doc.id,
                          productData: data,
                        ),
                      ),
                    );
                  },
                  leading: data['images'] != null && (data['images'] as List).isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['images'][0],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.inventory_2, color: BColors.primary, size: 36),
                  title: Text(data['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['category'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['price'] != null ? '₱${(data['price'] as num).toStringAsFixed(2)}' : '',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: BColors.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Product',
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductCreationScreen(
                                shopId: widget.shopId,
                                productId: doc.id,
                                productData: data,
                              ),
                            ),
                          );
                          if (result == true) {
                            setState(() {});
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Product',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await FirebaseFirestore.instance.collection('products').doc(doc.id).delete();
                            if (context.mounted) {
                              BFeedback.show(context, message: 'Product deleted!', type: BFeedbackType.success);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  String _formatDate(Timestamp ts) {
    final date = ts.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }

  void _launchUrl(String url) async {
    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://$url');
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
