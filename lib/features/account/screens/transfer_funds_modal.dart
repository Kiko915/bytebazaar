import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferFundsModal extends StatefulWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final String userId;
  final double currentBalance;
  const TransferFundsModal({Key? key, required this.paymentMethods, required this.userId, required this.currentBalance}) : super(key: key);

  @override
  State<TransferFundsModal> createState() => _TransferFundsModalState();
}

class _TransferFundsModalState extends State<TransferFundsModal> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedDestination;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethods.isNotEmpty) {
      _selectedDestination = widget.paymentMethods.first['number'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = widget.paymentMethods.map((card) => DropdownMenuItem<String>(
      value: card['number'],
      child: Row(
        children: [
          Icon(Icons.credit_card, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text('${card['type']} ••••${card['number'].toString().substring(card['number'].toString().length - 4)}'),
        ],
      ),
    )).toList();
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
                    Icon(Icons.swap_horiz, color: Colors.green, size: 28),
                    SizedBox(width: 10),
                    Text('Transfer Funds', style: TextStyle(fontFamily: 'BebasNeue', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.green, letterSpacing: 1.2)),
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
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.w500),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedDestination,
              decoration: InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: destinations,
              onChanged: (val) => setState(() => _selectedDestination = val),
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
                  if (amount > widget.currentBalance) {
                    setState(() {
                      _errorMessage = 'Amount exceeds available balance.';
                    });
                    return;
                  }
                  if (_selectedDestination == null || _selectedDestination!.isEmpty) {
                    setState(() {
                      _errorMessage = 'Please select a destination.';
                    });
                    return;
                  }
                  setState(() { _isLoading = true; });
                  try {
                    // Update Firestore balance (debit)
                    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
                    await userDoc.update({
                      'ewallet_balance': FieldValue.increment(-amount),
                    });
                    // Add to transaction_history subcollection
                    await userDoc.collection('transaction_history').add({
                      'type': 'transfer_out',
                      'amount': amount,
                      'destination': _selectedDestination,
                      'date': DateTime.now(),
                    });
                    // Show info dialog
                    await showDialog(
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
                    Navigator.of(context).pop(_amountController.text);
                  } catch (e) {
                    setState(() {
                      _errorMessage = 'Failed to transfer funds. Please try again.';
                    });
                  } finally {
                    setState(() { _isLoading = false; });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
