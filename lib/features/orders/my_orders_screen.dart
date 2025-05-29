import 'order_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _statuses = ['pending', 'shipped', 'delivered', 'canceled'];
  final Map<String, String> _statusLabels = {
    'pending': 'Pending',
    'shipped': 'Shipped',
    'delivered': 'Delivered',
    'canceled': 'Canceled',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _statuses.map((status) => Tab(text: _statusLabels[status])).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          return _OrdersListTab(status: status);
        }).toList(),
      ),
    );
  }
}

class _OrdersListTab extends StatefulWidget {
  final String status;
  const _OrdersListTab({Key? key, required this.status}) : super(key: key);

  @override
  State<_OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends State<_OrdersListTab> {
  bool _orderReceived = false;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual user ID logic
    final String? buyerId = FirebaseAuth.instance.currentUser?.uid;
    if (buyerId == null) {
      return const Center(child: Text('You must be logged in to view your orders.'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: buyerId)
          .where('status', isEqualTo: widget.status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No ${widget.status[0].toUpperCase()}${widget.status.substring(1)} orders.'));
        }
        final orders = snapshot.data!.docs;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    title: Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ' + (order['createdAt'] != null && order['createdAt'] is Timestamp
                            ? (order['createdAt'] as Timestamp).toDate().toString().split(' ').first
                            : '-')),
                        Text('Total: ₱${order['total'] != null ? (order['total'] is num ? order['total'].toStringAsFixed(2) : order['total'].toString()) : '-'}',
                            style: const TextStyle(fontFamily: 'Roboto', color: Colors.green)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to order details
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderScreen(orderId: orderId),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.status == 'delivered' && !_orderReceived)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _orderReceived = true;
                              });
                              // TODO: Implement order received logic
                            },
                            child: const Text('Order Received'),
                          ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
