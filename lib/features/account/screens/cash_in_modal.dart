import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CashInModal extends StatefulWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final String userId;
  final double currentBalance;
  const CashInModal({Key? key, required this.paymentMethods, required this.userId, required this.currentBalance}) : super(key: key);

  @override
  State<CashInModal> createState() => _CashInModalState();
}

class _CashInModalState extends State<CashInModal> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedSource;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedSource = 'PayPal';
  }

  @override
  Widget build(BuildContext context) {
    final sources = [
      const DropdownMenuItem<String>(
        value: 'PayPal',
        child: Row(
          children: [Icon(Icons.account_balance_wallet, color: Colors.blue), SizedBox(width: 8), Text('PayPal')],
        ),
      ),
      ...widget.paymentMethods.map((card) => DropdownMenuItem<String>(
            value: card['number'],
            child: Row(
              children: [
                Icon(Icons.credit_card, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('${card['type']} ••••${card['number'].toString().substring(card['number'].toString().length - 4)}'),
              ],
            ),
          ))
    ];
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.add_circle_outline, color: Colors.blue, size: 28),
                    SizedBox(width: 10),
                    Text('Cash In', style: TextStyle(fontFamily: 'BebasNeue', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue, letterSpacing: 1.2)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Text('₱', style: TextStyle(fontSize: 20, color: Colors.black87, fontFamily: 'Roboto')), 
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedSource,
              decoration: InputDecoration(
                labelText: 'Source',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: sources,
              onChanged: (val) => setState(() => _selectedSource = val),
            ),
            const SizedBox(height: 26),
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _errorMessage = null;
                  });
                  final amount = double.tryParse(_amountController.text) ?? 0.0;
                  if (amount <= 0) {
                    setState(() {
                      _errorMessage = 'Please enter a valid amount.';
                    });
                    return;
                  }
                  if (_selectedSource == null || _selectedSource!.isEmpty) {
                    setState(() {
                      _errorMessage = 'Please select a source.';
                    });
                    return;
                  }
                  setState(() { _isLoading = true; });
                  try {
                    // Update Firestore balance
                    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
                    await userDoc.update({
                      'ewallet_balance': FieldValue.increment(amount),
                    });
                    // Add to transaction_history subcollection
                    await userDoc.collection('transaction_history').add({
                      'type': 'cash_in',
                      'amount': amount,
                      'source': _selectedSource,
                      'date': DateTime.now(),
                    });
                    // Show demo info dialog
                    await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Demo Cash In'),
                        content: const Text(
                          'This is just a demo so there will be no money involved and it will successfully cash in and add the balance to the e-wallet.',
                          style: TextStyle(fontSize: 16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    Navigator.of(context).pop(_amountController.text);
                  } catch (e) {
                    setState(() {
                      _errorMessage = 'Failed to cash in. Please try again.';
                    });
                  } finally {
                    setState(() { _isLoading = false; });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.1,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
