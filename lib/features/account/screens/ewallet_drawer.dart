import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/features/account/screens/cash_in_modal.dart';
import 'package:bytebazaar/features/account/screens/transfer_funds_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EWalletDrawer extends StatelessWidget {
  final double balance;
  final List<Map<String, dynamic>> transactions;
  final String userId;
  const EWalletDrawer({Key? key, required this.userId, this.balance = 0.0, this.transactions = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drawer header with close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, color: BColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'My E-Wallet',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: BColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 18),
              // E-Wallet Card Design
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins', fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(
                      '\u20B1${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
  child: GestureDetector(
    onTap: () async {
  final paymentMethods = [
    {
      'addedAt': '2025-05-25T11:12:08.082257',
      'cvv': '249',
      'expiry': '10/29',
      'name': 'Francis Mistica',
      'number': '4412132411094583',
      'type': 'Visa',
    }
  ];
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return CashInModal(paymentMethods: paymentMethods, userId: userId, currentBalance: balance);
    },
  );
  if (result != null && result.isNotEmpty) {
    // You would update the backend here. For demo, update the UI if possible.
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cash In Successful'),
          content: const Text('Your balance has been updated (demo only).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
},
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4285F4), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            'CASH IN',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.white,
              fontSize: 18,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),
const SizedBox(width: 14),
Expanded(
  child: GestureDetector(
    onTap: balance > 0
        ? () async {
            final paymentMethods = [
              {
                'addedAt': '2025-05-25T11:12:08.082257',
                'cvv': '249',
                'expiry': '10/29',
                'name': 'Francis Mistica',
                'number': '4412132411094583',
                'type': 'Visa',
              }
            ];
            final result = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return TransferFundsModal(paymentMethods: paymentMethods, userId: userId, currentBalance: balance);
              },
            );
            if (result != null && result.isNotEmpty) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Transfer Successful'),
                    content: const Text('Funds have been transferred out of your e-wallet.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        : null,
    child: Opacity(
      opacity: balance > 0 ? 1.0 : 0.45,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4285F4), Color(0xFF6DD5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.swap_horiz, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'TRANSFER FUNDS',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.white,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(1, 1),
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
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Transaction History',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: BColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              transactions.isEmpty
                  ? const Text('No transactions yet.', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, idx) {
                        final t = transactions[idx];
                        return ListTile(
                          leading: Icon(
                            t['type'] == 'cash_in'
                                ? Icons.add_circle_outline
                                : t['type'] == 'transfer_out'
                                    ? Icons.swap_horiz
                                    : Icons.receipt_long,
                            color: t['type'] == 'cash_in'
                                ? Colors.blue
                                : t['type'] == 'transfer_out'
                                    ? Colors.green
                                    : Colors.grey,
                          ),
                          title: Text(t['source'] ?? t['destination'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            t['date'] is String
                                ? t['date']
                                : t['date'] is Timestamp
                                    ? (t['date'] as Timestamp).toDate().toString()
                                    : '-',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),

                          trailing: Text(
                            (t['type'] == 'cash_in' ? '+' : t['type'] == 'transfer_out' ? '-' : '') + '\u20B1' + (t['amount']?.toStringAsFixed(2) ?? '0.00'),
                            style: TextStyle(
                              color: t['type'] == 'cash_in'
                                  ? Colors.blue
                                  : t['type'] == 'transfer_out'
                                      ? Colors.grey  
                                      : Colors.grey,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
