import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'shop_creation_screen.dart';
import 'shop_dashboard_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  User? _firebaseUser;
  bool _isLoading = true;

  // Dashboard summary stats
  int _activeShops = 0;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    _fetchDashboardStats();
  }

  Widget _dashboardInfoCard(
      {required IconData icon, required String label, required String value}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BColors.primary, Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BColors.primary.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'BebasNeue',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchDashboardStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Active shops
    final shopsQuery = await FirebaseFirestore.instance
        .collection('shops')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    setState(() {
      _activeShops = shopsQuery.docs.length;
    });
    // Orders for all shops
    int totalOrders = 0;
    int pendingOrders = 0;
    double totalRevenue = 0.0;
    for (var shopDoc in shopsQuery.docs) {
      final shopId = shopDoc.id;
      final ordersQuery = await FirebaseFirestore.instance
          .collection('orders')
          .where('shopId', isEqualTo: shopId)
          .get();
      totalOrders += ordersQuery.docs.length;
      for (var orderDoc in ordersQuery.docs) {
        final data = orderDoc.data();
        if ((data['status'] ?? '').toLowerCase() == 'pending') {
          pendingOrders++;
        }
        if (data['total'] != null) {
          totalRevenue += (data['total'] as num).toDouble();
        }
      }
    }
    setState(() {
      _totalOrders = totalOrders;
      _pendingOrders = pendingOrders;
      _totalRevenue = totalRevenue;
    });
  }

  Future<void> _fetchStoreData() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    if (_firebaseUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // Query shops collection for this seller
    await FirebaseFirestore.instance
        .collection('shops')
        .where('ownerId', isEqualTo: _firebaseUser!.uid)
        .limit(1)
        .get();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _goToCreateStore() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ShopCreationScreen(),
      ),
    );
    if (created == true) {
      _fetchDashboardStats();
      _fetchStoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SELLER DASHBOARD',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Seller Summary Cards ---
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 8.0),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () async {
                                    final created = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ShopCreationScreen(),
                                      ),
                                    );
                                    if (created == true) {
                                      _fetchDashboardStats();
                                      _fetchStoreData();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          BColors.primary,
                                          Color(0xFF4285F4)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 28, horizontal: 22),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_business,
                                            color: Colors.white, size: 32),
                                        const SizedBox(width: 18),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Text(
                                                'Create New Shop',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Create another shop or expand your business on ByteBazaar!',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_activeShops > 0)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _dashboardInfoCard(
                                      icon: Icons.store,
                                      label: 'Active Shops',
                                      value: _activeShops.toString(),
                                    ),
                                    const SizedBox(width: 12),
                                    _dashboardInfoCard(
                                      icon: Icons.shopping_bag,
                                      label: 'Total Orders',
                                      value: _totalOrders.toString(),
                                    ),
                                    const SizedBox(width: 12),
                                    _dashboardInfoCard(
                                      icon: Icons.hourglass_top,
                                      label: 'Pending',
                                      value: _pendingOrders.toString(),
                                    ),
                                    const SizedBox(width: 12),
                                    _dashboardInfoCard(
                                      icon: Icons.attach_money,
                                      label: 'Revenue',
                                      value:
                                          '\u20B1${_totalRevenue.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 18),
                            // --- Analytics Section ---
                            Text('Analytics',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: BColors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 180,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(
                                          show: true, drawVerticalLine: false),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 32),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final days = [
                                                'Mon',
                                                'Tue',
                                                'Wed',
                                                'Thu',
                                                'Fri',
                                                'Sat',
                                                'Sun'
                                              ];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    days[value.toInt() % 7],
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              );
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          isCurved: true,
                                          spots: const [
                                            FlSpot(0, 3),
                                            FlSpot(1, 4),
                                            FlSpot(2, 2),
                                            FlSpot(3, 5),
                                            FlSpot(4, 3.5),
                                            FlSpot(5, 4.5),
                                            FlSpot(6, 6),
                                          ],
                                          color: BColors.primary,
                                          barWidth: 4,
                                          dotData: FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                              show: true,
                                              color: BColors.primary
                                                  .withOpacity(0.15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 180,
                                  child: BarChart(
                                    BarChartData(
                                      gridData: FlGridData(
                                          show: true, drawVerticalLine: false),
                                      borderData: FlBorderData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 32),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              final months = [
                                                'Jan',
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'May',
                                                'Jun'
                                              ];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                    months[value.toInt() % 6],
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              );
                                            },
                                            interval: 1,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                      ),
                                      barGroups: [
                                        BarChartGroupData(x: 0, barRods: [
                                          BarChartRodData(
                                              toY: 5, color: Colors.green)
                                        ]),
                                        BarChartGroupData(x: 1, barRods: [
                                          BarChartRodData(
                                              toY: 6, color: Colors.green)
                                        ]),
                                        BarChartGroupData(x: 2, barRods: [
                                          BarChartRodData(
                                              toY: 4, color: Colors.green)
                                        ]),
                                        BarChartGroupData(x: 3, barRods: [
                                          BarChartRodData(
                                              toY: 7, color: Colors.green)
                                        ]),
                                        BarChartGroupData(x: 4, barRods: [
                                          BarChartRodData(
                                              toY: 3, color: Colors.green)
                                        ]),
                                        BarChartGroupData(x: 5, barRods: [
                                          BarChartRodData(
                                              toY: 8, color: Colors.green)
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_activeShops == 0)
                              Card(
                                color: BColors.surface,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Welcome to ByteBazaar!',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            color: BColors.primary,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Let's get you started as a seller. To begin, create your first shop.",
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () async {
                                          final created = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ShopCreationScreen(),
                                            ),
                                          );
                                          if (created == true) {
                                            _fetchDashboardStats();
                                            _fetchStoreData();
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          decoration: BoxDecoration(
                                            color: BColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Start your first shop',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // --- Seller's Shops List ---
                            const SizedBox(height: 28),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('shops')
                                  .where('ownerId',
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Column(
                                    children: [
                                      const Center(
                                        child: Text(
                                          'You have not created any shops yet.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final created = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ShopCreationScreen(),
                                            ),
                                          );
                                          if (created == true) {
                                            _fetchDashboardStats();
                                            _fetchStoreData();
                                          }
                                        },
                                        icon: const Icon(Icons.add_business),
                                        label: const Text('Create Shop'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: BColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 28, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                final shops = snapshot.data!.docs;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Your Shops',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: shops.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, idx) {
                                        final shop = shops[idx].data()
                                            as Map<String, dynamic>;
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14)),
                                          elevation: 3,
                                          child: ListTile(
                                            leading: shop['logoUrl'] != null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                        shop['logoUrl'],
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      ),
                                                  )
                                                : const Icon(Icons.store,
                                                    size: 42),
                                            title: Text(
                                              shop['name'] ?? 'Unnamed Shop',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              shop['category'] ?? '',
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 20),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ShopDashboardScreen(
                                                      shopId: shops[idx].id,
                                                      shopData: shop,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            // --- End Seller's Shops List ---
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    ));
  }
}
