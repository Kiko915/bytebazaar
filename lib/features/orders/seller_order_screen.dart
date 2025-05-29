import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOrderScreen extends StatefulWidget {
  final String orderId;
  const SellerOrderScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details (Seller)'),
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
          // Extract shopId from first item in items array
          final shopId = items.isNotEmpty ? items[0]['shopId'] : null;
          final currentUser = FirebaseAuth.instance.currentUser;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('shops').doc(shopId).get(),
            builder: (context, shopSnap) {
              if (shopSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!shopSnap.hasData || !shopSnap.data!.exists) {
                return const Center(child: Text('Shop not found.'));
              }
              final shopData = shopSnap.data!.data() as Map<String, dynamic>?;
              final shopOwnerId = shopData?['ownerId'];
              final isSeller = shopOwnerId == currentUser?.uid;

              // Seller-specific actions and info
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
                                  status.toUpperCase(),
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
                                  overflow: TextOverflow.ellipsis,
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
                              Expanded(
                                child: Text(
                                  order['shipping'] != null && order['shipping']['courier'] != null ? order['shipping']['courier'] : '-',
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.deepPurple, size: 20),
                              const SizedBox(width: 8),
                              Text('Phone: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple[700])),
                              Expanded(
                                child: Text(
                                  order['shipping'] != null && order['shipping']['phone'] != null ? order['shipping']['phone'] : '-',
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.payment, color: Colors.indigo, size: 20),
                              const SizedBox(width: 8),
                              Text('Payment: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[700])),
                              Expanded(
                                child: Text(
                                  order['payment'] != null && order['payment']['method'] != null ? order['payment']['method'] : '-',
                                  style: const TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
                              Flexible(
                                child: Text(
                                  '₱${order['total'] != null ? (order['total'] is num ? order['total'].toStringAsFixed(2) : order['total'].toString()) : '-'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green, fontFamily: 'Roboto'),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                                  Expanded(
                                    child: Text(
                                      'Please fulfill and make this order ready.',
                                      style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: status == 'pending'
                                    ? () {
                                        _showCancelOrderDialog(widget.orderId, isSeller: isSeller);
                                      }
                                    : null,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: status == 'pending'
                                    ? () async {
                                        // Subtract stock for each item in the order
                                        for (final item in items) {
                                          final productId = item['productId'];
                                          final orderedQty = item['quantity'] ?? 1;
                                          if (productId != null) {
                                            final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
                                            final productSnap = await productRef.get();
                                            if (productSnap.exists) {
                                              final currentStock = (productSnap.data()?['stock'] ?? 0) as int;
                                              final newStock = (currentStock - orderedQty).clamp(0, currentStock);
                                              // Increment orders field
                                              final currentOrders = (productSnap.data()?['orders'] ?? 0) as int;
                                              final newOrders = currentOrders + 1;
                                              await productRef.update({
                                                'stock': newStock,
                                                'orders': newOrders,
                                              });
                                            }
                                          }
                                        }
                                        await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'status': 'shipped'});
                                        setState(() {});
                                      }
                                    : null,
                                child: const Text('Mark as Shipped'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: status == 'shipped'
                                    ? () async {
                                        await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'status': 'delivered'});
                                        setState(() {});
                                      }
                                    : null,
                                child: const Text('Mark as Delivered'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Seller-specific cancel dialog
  Future<void> _showCancelOrderDialog(String orderId, {required bool isSeller}) async {
    String? _selectedReason;
    final sellerCancelReasons = [
      'Out of stock',
      'Unable to fulfill',
      'Buyer requested cancellation',
      'Other',
    ];
    final buyerCancelReasons = [
      'Changed my mind',
      'Ordered by mistake',
      'Found a better price',
      'Other',
    ];
    final reasons = isSeller ? sellerCancelReasons : buyerCancelReasons;
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
                    items: reasons.map((reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        _selectedReason = val;
                      });
                    },
                    isExpanded: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () async {
                          await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                            'status': 'canceled',
                            'cancelReason': _selectedReason,
                            'canceledBy': isSeller ? 'seller' : 'buyer',
                          });
                          Navigator.of(context).pop();
                          setState(() {});
                        },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildProductItems(List items) {
    if (items.isEmpty) {
      return [const Text('No products in this order.')];
    }
    return items.map((item) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: item['imageUrl'] != null
              ? Image.network(item['imageUrl'], width: 48, height: 48, fit: BoxFit.cover)
              : const Icon(Icons.image, size: 48),
          title: Text(item['name'] ?? '-'),
          subtitle: Text('Qty: ${item['quantity']}'),
          trailing: Text('₱${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }).toList();
  }
}
