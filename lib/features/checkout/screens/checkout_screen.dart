import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/checkout/screens/paypal_drawer.dart';
import 'package:bytebazaar/features/orders/order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final Map<String, dynamic> userInfo;
  final double shippingFee;
  final double voucherDiscount;
  final String courier;
  final String paymentMethod;

  const CheckoutScreen({
    Key? key,
    required this.selectedItems,
    required this.userInfo,
    this.shippingFee = 50.0,
    this.voucherDiscount = 50.0,
    this.courier = 'Flash Express',
    this.paymentMethod = 'Cash on Delivery',
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController paypalEmailController = TextEditingController();
  bool paypalVerified = false;

  void _openPayPalDrawer(String email) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PayPalDrawer(
        email: email,
        onVerified: () {
          setState(() {
            paypalVerified = true;
          });
        },
      ),
    );
  }

  Map<String, dynamic>? selectedCreditCard;

  final List<String> paymentMethods = [
    'Cash on Delivery',
    'BB Wallet',
    'Paypal',
    'Credit Card',
  ];
  late String selectedPaymentMethod;

  List<Map<String, dynamic>> shippingProviders = [];
  Map<String, dynamic>? selectedProvider;
  double computedShippingFee = 0.0;
  bool isLoadingProviders = true;
  late List<Map<String, dynamic>> selectedItems;

  double get merchandiseSubtotal => selectedItems.fold(0.0, (sum, item) {
        final price = (item['price'] is num) ? item['price'] as num : 0;
        final qty = (item['quantity'] is int) ? item['quantity'] as int : 1;
        return sum + price * qty;
      });

  @override
  void initState() {
    super.initState();
    selectedItems = List<Map<String, dynamic>>.from(widget.selectedItems);
    selectedPaymentMethod = widget.paymentMethod;
    fetchShippingProviders();
  }

  Future<void> fetchShippingProviders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shipping_providers')
          .get();
      final providers =
          snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      setState(() {
        shippingProviders = List<Map<String, dynamic>>.from(providers);
        if (shippingProviders.isNotEmpty) {
          selectedProvider = shippingProviders.first;
          computeShippingFee();
        }
        isLoadingProviders = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProviders = false;
      });
    }
  }

  double getTotalWeight() {
    print("Selected items in checkout: ");
    for (var item in selectedItems) {
      print(item);
    }
    return selectedItems.fold(0.0, (sum, item) {
      num weight = 0;
      if (item['weight'] is num) {
        weight = item['weight'];
      } else if (item['dimensions'] != null &&
          item['dimensions']['weight'] is num) {
        weight = item['dimensions']['weight'];
      } else if (item['productData'] != null &&
          item['productData']['shipping'] != null &&
          item['productData']['shipping']['weight'] is num) {
        weight = item['productData']['shipping']['weight'];
      }
      final qty = (item['quantity'] is int) ? item['quantity'] as int : 1;
      print("Item: $item, weight: $weight, qty: $qty");
      return sum + (weight * qty);
    });
  }

  void computeShippingFee() {
    if (selectedProvider != null) {
      final baseRateRaw = selectedProvider?['base_rate'];
      final baseRate = (baseRateRaw is num)
          ? baseRateRaw
          : double.tryParse(baseRateRaw.toString()) ?? 0;
      final totalWeight = getTotalWeight();
      print("baseRate: $baseRate, totalWeight: $totalWeight");
      setState(() {
        computedShippingFee = baseRate * totalWeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4285F4), Color(0xFFEFF5FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Image.asset(
                    'assets/logos/bytebazaar_splash_logo.png',
                    height: 66,
                    fit: BoxFit.contain,
                  ),
                  const Text('Order Invoice',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 16),
                  // User Info Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.userInfo['fullName'] != null &&
                                  widget.userInfo['fullName']
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                              ? widget.userInfo['fullName']
                              : ((widget.userInfo['firstName'] ?? '') +
                                      (widget.userInfo['middleName'] != null &&
                                              widget.userInfo['middleName']
                                                  .toString()
                                                  .trim()
                                                  .isNotEmpty
                                          ? ' ${widget.userInfo['middleName']}'
                                          : '') +
                                      (widget.userInfo['lastName'] != null
                                          ? ' ${widget.userInfo['lastName']}'
                                          : ''))
                                  .trim(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF003D99)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userInfo['phone'] ?? '-',
                          style: const TextStyle(
                              color: Color(0xFF4285F4), fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                [
                                  widget.userInfo['street'],
                                  widget.userInfo['city'],
                                  widget.userInfo['province'],
                                  widget.userInfo['zip'],
                                  widget.userInfo['country']
                                ]
                                    .where((e) =>
                                        e != null &&
                                        e.toString().trim().isNotEmpty)
                                    .join(', '),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selected Items
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: selectedItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item['imageUrl'] != null
                                    ? Image.network(item['imageUrl'],
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 48,
                                        height: 48,
                                        color: Colors.grey[200]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF003D99)),
                                    ),
                                    Text('Quantity: ${item['quantity'] ?? 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Text(
                                  '+₱${((item['price'] is num ? item['price'] : 0) as num).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF003D99),
                                      fontFamily: 'Roboto')),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  if (selectedItems.length == 1) {
                                    BFeedback.show(
                                      context,
                                      title: 'Cannot Remove',
                                      message:
                                          'At least one item must remain in checkout.',
                                      type: BFeedbackType.error,
                                      position: BFeedbackPosition.top,
                                    );
                                    return;
                                  }
                                  setState(() {
                                    selectedItems.removeAt(idx);
                                  });
                                  computeShippingFee();
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Courier, Voucher, Payment Method
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        // Courier Dropdown (Redesigned)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('COURIER:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            const SizedBox(height: 8),
                            isLoadingProviders
                                ? const LinearProgressIndicator()
                                : Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<
                                            Map<String, dynamic>>(
                                          value: selectedProvider,
                                          isExpanded: true,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF4285F4)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF4285F4)),
                                            ),
                                          ),
                                          icon: const Icon(Icons.local_shipping,
                                              color: Color(0xFF4285F4)),
                                          items:
                                              shippingProviders.map((provider) {
                                            return DropdownMenuItem<
                                                Map<String, dynamic>>(
                                              value: provider,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    provider['name'] ?? '-',
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if ((provider[
                                                              'description'] ??
                                                          '')
                                                      .toString()
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2.0),
                                                      child: Text(
                                                        provider['description'],
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (provider) {
                                            setState(() {
                                              selectedProvider = provider;
                                            });
                                            computeShippingFee();
                                          },
                                          selectedItemBuilder: (context) {
                                            return shippingProviders
                                                .map<Widget>((provider) {
                                              return Center(
                                                child: Text(
                                                  provider['name'] ?? '-',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '+₱${computedShippingFee.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF003D99),
                                            fontFamily: 'Roboto'),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.payment, color: Color(0xFF003D99)),
                              const SizedBox(width: 8),
                              const Flexible(
                                flex: 0,
                                child: Text(
                                  'Payment Method:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003D99),
                                      fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 1,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedPaymentMethod,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(8),
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Color(0xFF003D99)),
                                    style: const TextStyle(
                                        color: Color(0xFF003D99),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                    dropdownColor: Colors.white,
                                    itemHeight: 48,
                                    items: paymentMethods.map((method) {
                                      return DropdownMenuItem<String>(
                                        value: method,
                                        child: Row(
                                          children: [
                                            Icon(
                                              method == 'Cash on Delivery'
                                                  ? Icons.local_shipping
                                                  : method == 'BB Wallet'
                                                      ? Icons
                                                          .account_balance_wallet
                                                      : method == 'Paypal'
                                                          ? Icons
                                                              .account_balance
                                                          : Icons.credit_card,
                                              color: Color(0xFF4080FF),
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                method,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedPaymentMethod = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Payment Details
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PAYMENT DETAILS:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 4),
                        // PayPal Mock Flow
                        if (selectedPaymentMethod == 'Paypal') ...[
                          Builder(
                            builder: (context) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PayPal Email:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: paypalEmailController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your PayPal email',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.email),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (v) { setState(() {}); },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: paypalEmailController.text.isNotEmpty && !paypalVerified
                                            ? () {
                                                _openPayPalDrawer(paypalEmailController.text);
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF003087),
                                        ),
                                        child: const Text('Pay with PayPal'),
                                      ),
                                      const SizedBox(width: 10),
                                      if (paypalVerified)
                                        Row(
                                          children: const [
                                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                                            SizedBox(width: 4),
                                            Text('Verified (Demo)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                    ],
                                  ),
                                  if (!paypalVerified && paypalEmailController.text.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 2.0),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.error_outline, color: Colors.red, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Please enter your PayPal email.',
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  const Text('This is a demo PayPal flow. Any email will be accepted after pressing Pay with PayPal.', style: TextStyle(color: Colors.orange, fontSize: 12)),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ],
                        // Credit Card Picker
                        if (selectedPaymentMethod == 'Credit Card') ...[
                          Builder(
                            builder: (context) {
                              final cards = (widget.userInfo['payment_methods'] as List?)?.where((c) =>
                                  c != null &&
                                  c['number'] != null &&
                                  c['expiry'] != null &&
                                  c['cvv'] != null
                                ).toList() ?? [];
                              if (cards.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'No credit cards available. Please add a card in your account.',
                                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select Credit Card:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<Map<String, dynamic>>(
                                    value: selectedCreditCard,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF4285F4)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF4285F4)),
                                      ),
                                    ),
                                    items: cards.map<DropdownMenuItem<Map<String, dynamic>>>(
                                      (card) {
                                        final masked = card['number'] != null && card['number'].toString().length >= 4
                                          ? '•••• •••• •••• ' + card['number'].toString().substring(card['number'].toString().length - 4)
                                          : card['number'] ?? '-';
                                        return DropdownMenuItem<Map<String, dynamic>>(
                                          value: card,
                                          child: Row(
                                            children: [
                                              Icon(Icons.credit_card, color: Color(0xFF4080FF), size: 18),
                                              const SizedBox(width: 8),
                                              Text('${card['type'] ?? 'Card'} $masked', style: const TextStyle(fontFamily: 'Roboto')),
                                              const SizedBox(width: 12),
                                              Text(card['expiry'] != null ? 'Exp: ${card['expiry']}' : '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (card) {
                                      setState(() {
                                        selectedCreditCard = card;
                                      });
                                    },
                                  ),
                                  if (selectedCreditCard == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 2.0),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.error_outline, color: Colors.red, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Please select a credit card to proceed.',
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ],
                        // Show BB Wallet balance note if selected
                        if (selectedPaymentMethod == 'BB Wallet') ...[
                          Builder(
                            builder: (context) {
                              final walletBalance = widget.userInfo['ewallet_balance'] is num
                                  ? widget.userInfo['ewallet_balance'] as num
                                  : double.tryParse(widget.userInfo['ewallet_balance']?.toString() ?? '') ?? 0.0;
                              final totalAmount = merchandiseSubtotal + computedShippingFee;
                              final hasSufficient = walletBalance >= totalAmount;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet, color: Color(0xFF4285F4), size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'E-Wallet Balance: ₱' + walletBalance.toStringAsFixed(2),
                                        style: const TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
                                      ),
                                    ],
                                  ),
                                  if (!hasSufficient)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 2.0),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.error_outline, color: Colors.red, size: 16),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Insufficient e-wallet balance for this purchase.',
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                        ],
                        Text(
                            'Merchandise Subtotal: ₱${merchandiseSubtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.black87, fontFamily: 'Roboto')),
                        Text(
                            'Shipping Subtotal: ₱${computedShippingFee.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.black87, fontFamily: 'Roboto')),
                        const SizedBox(height: 4),
                        Text(
                            'Total Payment: ₱${(merchandiseSubtotal + computedShippingFee).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003D99),
                                fontFamily: 'Roboto')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bottom Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('TOTAL:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                    fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                                '₱${(merchandiseSubtotal + computedShippingFee).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF003D99),
                                    fontSize: 20,
                                    fontFamily: 'Roboto')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[400],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 12),
                              ),
                              child: const Text('CANCEL'),
                            ),
                            const SizedBox(width: 10),
                            Builder(
                              builder: (context) {
                                final isBBWallet = selectedPaymentMethod == 'BB Wallet';
                                final walletBalance = widget.userInfo['ewallet_balance'] is num
                                    ? widget.userInfo['ewallet_balance'] as num
                                    : double.tryParse(widget.userInfo['ewallet_balance']?.toString() ?? '') ?? 0.0;
                                final totalAmount = merchandiseSubtotal + computedShippingFee;
                                final hasSufficient = walletBalance >= totalAmount;
                                final isCreditCard = selectedPaymentMethod == 'Credit Card';
                                final cards = (widget.userInfo['payment_methods'] as List?)?.where((c) =>
                                  c != null &&
                                  c['number'] != null &&
                                  c['expiry'] != null &&
                                  c['cvv'] != null
                                ).toList() ?? [];
                                final canProceedCreditCard = !isCreditCard || (cards.isNotEmpty && selectedCreditCard != null);
                                final isPaypal = selectedPaymentMethod == 'Paypal';
                                final canProceedPaypal = !isPaypal || (paypalEmailController.text.isNotEmpty && paypalVerified);
                                 return ElevatedButton(
                                   onPressed: (isBBWallet && !hasSufficient) || !canProceedCreditCard || !canProceedPaypal
                                       ? null
                                       : () async {
                                           // 1. Create order in Firestore
                                           final orderRef = await FirebaseFirestore.instance.collection('orders').add({
                                             'buyerId': widget.userInfo['userId'] ?? FirebaseAuth.instance.currentUser?.uid,
                                             'buyerName': widget.userInfo['fullName'] ?? widget.userInfo['firstName'] ?? FirebaseAuth.instance.currentUser?.displayName ?? '',
                                             'items': selectedItems.map((item) => {
                                               ...item,
                                               'shopId': item['shopId'],
                                               'status': 'pending',
                                             }).toList(),
                                             'shipping': {
                                               'address': [
                                                 widget.userInfo['street'],
                                                 widget.userInfo['city'],
                                                 widget.userInfo['province'],
                                                 widget.userInfo['zip'],
                                                 widget.userInfo['country'],
                                               ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                                               'phone': widget.userInfo['phone'],
                                               'courier': selectedProvider?['name'] ?? widget.courier,
                                               'fee': computedShippingFee,
                                             },
                                             'payment': {
                                               'method': selectedPaymentMethod,
                                               'creditCard': selectedPaymentMethod == 'Credit Card' ? selectedCreditCard : null,
                                               'paypalEmail': selectedPaymentMethod == 'Paypal' ? paypalEmailController.text : null,
                                             },
                                             'total': merchandiseSubtotal + computedShippingFee,
                                             'status': 'pending',
                                             'createdAt': FieldValue.serverTimestamp(),
                                           });
                                           final orderId = orderRef.id;
                                           // 2. Show success modal
                                           showDialog(
                                             context: context,
                                             barrierDismissible: false,
                                             builder: (context) => AlertDialog(
                                               title: Row(
                                                 children: [
                                                   const Icon(Icons.check_circle, color: Colors.green),
                                                   SizedBox(width: 8),
                                                   Expanded(
                                                     child: Text(
                                                       'Order #$orderId placed!',
                                                       overflow: TextOverflow.ellipsis,
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               content: const Text('Your order has been successfully placed.'),
                                               actions: [
                                                 TextButton(
                                                   onPressed: () {
                                                     Navigator.of(context).pop();
                                                     Navigator.of(context).pushReplacement(
                                                       MaterialPageRoute(
                                                         builder: (_) => OrderScreen(orderId: orderId),
                                                       ),
                                                     );
                                                   },
                                                   child: const Text('Track Order'),
                                                 ),
                                               ],
                                             ),
                                           );
                                         },
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFF4285F4),
                                     foregroundColor: Colors.white,
                                     shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(8)),
                                     padding: const EdgeInsets.symmetric(
                                         horizontal: 22, vertical: 12),
                                   ),
                                   child: const Text('PLACE ORDER'),
                                 );
                              },
                            ),
                          ],
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
    );
  }

  Widget _checkoutRow(String label, String value, String trailing) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF003D99))),
          const SizedBox(width: 6),
          Expanded(
              child:
                  Text(value, style: const TextStyle(color: Colors.black87))),
          Text(trailing,
              style: TextStyle(
                color: trailing.startsWith('-') ? Colors.green : Colors.blue,
                fontWeight: FontWeight.bold,
                fontFamily: trailing.contains('₱') ? 'Roboto' : null,
              )),
        ],
      ),
    );
  }
}
