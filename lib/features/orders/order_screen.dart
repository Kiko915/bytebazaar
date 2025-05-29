import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_orders_screen.dart';

class OrderScreen extends StatefulWidget {
  final String orderId;
  const OrderScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const statusLabels = {
    'pending': 'Pending',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
    'canceled': 'Canceled',
  };

  final List<String> _buyerCancelReasons = [
    'Changed my mind',
    'Found a better price',
    'Ordered by mistake',
    'Other',
  ];
  final List<String> _sellerCancelReasons = [
    'Out of stock',
    'Unable to fulfill',
    'Fraudulent order',
    'Other',
  ];

  String? _selectedReason;
  bool _isCanceling = false;

  Future<void> _showCancelOrderDialog(String orderId, {required bool isSeller}) async {
    _selectedReason = null;
    final reasons = isSeller ? _sellerCancelReasons : _buyerCancelReasons;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Cancel Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please select a reason for cancellation:'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedReason,
                    items: reasons
                        .map((reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedReason = val;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Reason',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
  ),
                  onPressed: (_selectedReason == null || _isCanceling)
                      ? null
                      : () async {
                          setModalState(() {
                            _isCanceling = true;
                          });
                          try {
                            await FirebaseFirestore.instance
                                .collection('orders')
                                .doc(widget.orderId)
                                .update({
                              'status': 'canceled',
                              'cancelReason': _selectedReason,
                              'canceledAt': FieldValue.serverTimestamp(),
                            });
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order canceled successfully.'),
                                ),
                              );
                              setState(() {}); // Refresh order details
                            }
                          } catch (e) {
                            if (mounted) {
                              setModalState(() {
                                _isCanceling = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to cancel order: $e'),
                                ),
                              );
                            }
                          }
                        },
                  child: _isCanceling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {
      _isCanceling = false;
    });
  }

  List<Widget> _buildProductItems(List<dynamic> items) {
    return items.map<Widget>(_buildOrderItem).toList();
  }

  Widget _buildOrderItem(dynamic item) {
    final mapItem = item is Map<String, dynamic> ? item : <String, dynamic>{};
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: mapItem['imageUrl'] != null
                  ? Image.network(mapItem['imageUrl'], width: 64, height: 64, fit: BoxFit.cover)
                  : Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[200],
                      child: const Icon(Icons.shopping_bag, size: 32, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mapItem['name'] ?? 'Product',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number, size: 16, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text('Qty: ${mapItem['quantity'] ?? 1}'),
                      const SizedBox(width: 16),
                      if (mapItem['price'] != null) ...[
                        const Icon(Icons.price_check, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('₱${mapItem['price'] is num ? mapItem['price'].toStringAsFixed(2) : mapItem['price'].toString()}', style: const TextStyle(color: Colors.green, fontFamily: 'Roboto')), 
                      ],
                    ],
                  ),
                  if (mapItem['sellerName'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('Seller: ${mapItem['sellerName']}'),
                        ],
                      ),
                    ),
                  if (mapItem['shopId'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text('Shop ID: ${mapItem['shopId']}'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }
          final order = snapshot.data!.data() as Map<String, dynamic>?;
          if (order == null) {
            return const Center(child: Text('Order data is empty.'));
          }
          final status = order['status'] ?? 'pending';
          final items = (order['items'] as List?) ?? [];

          // Seller detection logic
          final shopId = order['shopId'];
          final currentUser = FirebaseAuth.instance.currentUser;
          bool isSeller = false;
          String? shopOwnerId;
          if (shopId != null && currentUser != null) {
            // This is synchronous for now, but ideally should be async/await with a FutureBuilder for production
            // For debug/testing, we use a placeholder
            // You should refactor this to be async for production
            // BEGIN SYNC HACK
            // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
            FirebaseFirestore.instance.collection('shops').doc(shopId).get().then((shopDoc) {
              shopOwnerId = shopDoc.data()?['ownerId'];
              isSeller = shopOwnerId == currentUser.uid;
              print('[OrderScreen] shopId: '
                  '\x1B[32m\x1B[1m$shopId\x1B[0m, shopOwnerId: '
                  '\x1B[34m\x1B[1m$shopOwnerId\x1B[0m, currentUser.uid: '
                  '\x1B[35m\x1B[1m${currentUser.uid}\x1B[0m, isSeller: '
                  '\x1B[36m\x1B[1m$isSeller\x1B[0m');
            });
            // END SYNC HACK
          } else {
            print('[OrderScreen] shopId or currentUser is null. shopId: $shopId, currentUser: ${currentUser?.uid}');
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.blue[700], size: 28),
                          const SizedBox(width: 10),
                          Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[700])),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1.2),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              statusLabels[status] ?? status,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: status == 'canceled'
                                ? Colors.red
                                : status == 'delivered'
                                    ? Colors.green
                                    : status == 'shipped'
                                        ? Colors.orange
                                        : Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            order['createdAt'] != null && order['createdAt'] is Timestamp
                                ? (order['createdAt'] as Timestamp).toDate().toString().split(' ').first
                                : '-',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order['shipping'] != null && order['shipping']['address'] != null
                                  ? order['shipping']['address']
                                  : '-',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.teal, size: 20),
                          const SizedBox(width: 8),
                          Text('Courier: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
                          Text(order['shipping'] != null && order['shipping']['courier'] != null ? order['shipping']['courier'] : '-', style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Text('Phone: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple[700])),
                          Text(order['shipping'] != null && order['shipping']['phone'] != null ? order['shipping']['phone'] : '-', style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.payment, color: Colors.indigo, size: 20),
                          const SizedBox(width: 8),
                          Text('Payment: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[700])),
                          Text(order['payment'] != null && order['payment']['method'] != null ? order['payment']['method'] : '-', style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      if (order['payment'] != null && order['payment']['creditCard'] != null && order['payment']['creditCard']['number'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 2),
                          child: Text('Credit Card: **** **** **** ${order['payment']['creditCard']['number'].toString().substring(order['payment']['creditCard']['number'].toString().length - 4)}', style: const TextStyle(fontSize: 14)),
                        ),
                      if (order['payment'] != null && order['payment']['paypalEmail'] != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 32, top: 2),
                          child: Text('PayPal: ${order['payment']['paypalEmail']}', style: const TextStyle(fontSize: 14)),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey[800])),
                          const SizedBox(width: 8),
                          Text(
                            '₱${order['total'] != null ? (order['total'] is num ? order['total'].toStringAsFixed(2) : order['total'].toString()) : '-'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green, fontFamily: 'Roboto'),
                          ),
                        ],
                      ),
                      if (isSeller && order['payment'] != null && order['payment']['method'] != null && order['payment']['method'] != 'Cash on Delivery')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Order is Paid', style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      if (status == 'pending' && isSeller)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange),
                              SizedBox(width: 8),
                              Text(
                                'Please fulfill and make this order ready.',
                                style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                _showCancelOrderDialog(widget.orderId, isSeller: isSeller);
                              },
                              child: const Text('Cancel Order'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: Text('Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              ..._buildProductItems(items),
              if (isSeller && status != 'delivered' && status != 'canceled')
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(),
                      Text('Update Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.local_shipping),
                            label: const Text('Mark as Shipped'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            onPressed: status == 'pending' || status == 'shipped'
                                ? () async {
                                    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'status': 'shipped'});
                                    setState(() {});
                                  }
                                : null,
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark as Delivered'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: status == 'shipped'
                                ? () async {
                                    await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'status': 'delivered'});
                                    setState(() {});
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
