import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

// Custom input formatter for expiry MM/YY
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 4) text = text.substring(0, 4);
    String formatted = '';
    if (text.length >= 3) {
      formatted = text.substring(0, 2) + '/' + text.substring(2);
    } else if (text.length >= 1) {
      formatted = text;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Custom input formatter for card number grouping
class _CardNumberInputFormatter extends TextInputFormatter {
  final String Function() getType;
  final String Function(String) formatter;
  _CardNumberInputFormatter(this.getType, this.formatter);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = formatter(newValue.text);
    // Calculate new cursor position
    int cursorPos = formatted.length;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}


class AddCardDrawer extends StatefulWidget {
  const AddCardDrawer({Key? key}) : super(key: key);

  @override
  State<AddCardDrawer> createState() => _AddCardDrawerState();
}

class _AddCardDrawerState extends State<AddCardDrawer> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Visa';
  final _cardNumberController = TextEditingController();

  // Formatter for card number grouping
  String _formatCardNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (_selectedType == 'American Express') {
      // 4-6-5
      final buffer = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        if (i == 4 || i == 10) buffer.write(' ');
        buffer.write(digits[i]);
      }
      return buffer.toString();
    } else {
      // 4-4-4-4
      final buffer = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        if (i != 0 && i % 4 == 0) buffer.write(' ');
        buffer.write(digits[i]);
      }
      return buffer.toString();
    }
  }


  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  final List<String> _cardTypes = ['Visa', 'Mastercard', 'American Express', 'Discover'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, color: BColors.primary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Add Credit Card',
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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Type', style: TextStyle(fontWeight: FontWeight.w600, color: BColors.primary)),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(border: InputBorder.none),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _cardTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Row(
                                  children: [
                                    Icon(
                                      type == 'Visa'
                                          ? Icons.credit_card
                                          : type == 'Mastercard'
                                              ? Icons.payment
                                              : Icons.credit_card_outlined,
                                      color: BColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(type),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
  controller: _cardNumberController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'Card Number',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    prefixIcon: Icon(Icons.credit_card, color: BColors.primary),
  ),
  inputFormatters: [
    _CardNumberInputFormatter(() => _selectedType, _formatCardNumber),
  ],
  validator: (val) {
    if (val == null || val.isEmpty) return 'Enter card number';
    final number = val.replaceAll(RegExp(r'\D'), '');
    if (_selectedType == 'Visa') {
      if (number.length != 16 || !number.startsWith('4')) {
        return 'Visa: 16 digits, starts with 4';
      }
    } else if (_selectedType == 'Mastercard') {
      if (number.length != 16 || !number.startsWith('5')) {
        return 'Mastercard: 16 digits, starts with 5';
      }
    } else if (_selectedType == 'American Express') {
      if (number.length != 15 || !(number.startsWith('34') || number.startsWith('37'))) {
        return 'Amex: 15 digits, starts with 34 or 37';
      }
    } else if (_selectedType == 'Discover') {
      if (number.length != 16 || !(number.startsWith('6011') || number.startsWith('65'))) {
        return 'Discover: 16 digits, starts with 6011 or 65';
      }
    }
    if (!RegExp(r'^\d+?$').hasMatch(number)) {
      return 'Card number must be numeric';
    }
    return null;
  },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
  controller: _expiryController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'MM/YY',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    prefixIcon: Icon(Icons.calendar_today, color: BColors.primary, size: 20),
  ),
  inputFormatters: [
    _ExpiryDateInputFormatter(),
  ],
  validator: (val) {
  if (val == null || val.length != 5) return 'MM/YY';
  final parts = val.split('/');
  if (parts.length != 2) return 'MM/YY';
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);
  if (month == null || month < 1 || month > 12) return 'Invalid month';
  if (year == null) return 'Invalid year';
  // Get current month/year
  final now = DateTime.now();
  final currentYear = now.year % 100; // two-digit year
  final currentMonth = now.month;
  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return 'Card expired';
  }
  return null;
},
),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: Icon(Icons.lock, color: BColors.primary, size: 20),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'CVV required';
                            final digits = val.replaceAll(RegExp(r'\D'), '');
                            if (!RegExp(r'^\d+$').hasMatch(digits)) return 'CVV must be numeric';
                            if (digits.replaceAll('0', '').isEmpty) return 'CVV cannot be all zeros';
                            if (_selectedType == 'American Express') {
                              if (digits.length != 4) return 'Amex CVV: 4 digits';
                            } else {
                              if (digits.length != 3) return 'CVV: 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Cardholder Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: Icon(Icons.person, color: BColors.primary),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter cardholder name' : null,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
  if (_formKey.currentState?.validate() ?? false) {
    FocusScope.of(context).unfocus();
    final card = {
      'type': _selectedType,
      'number': _cardNumberController.text.replaceAll(RegExp(r'\D'), ''),
      'expiry': _expiryController.text,
      'cvv': _cvvController.text.replaceAll(RegExp(r'\D'), ''),
      'name': _nameController.text.trim(),
      'addedAt': DateTime.now().toIso8601String(),
    };
    try {
      final user = AuthController.to.firebaseUser.value;
      if (user == null) throw Exception('User not logged in');
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await doc.update({
        'payment_methods': FieldValue.arrayUnion([card])
      });
      Navigator.of(context).pop();
      BFeedback.show(context, message: 'Card added successfully!', type: BFeedbackType.success);
    } catch (e) {
      BFeedback.show(context, message: 'Failed to add card:  {e.toString()}', type: BFeedbackType.error);
    }
  }
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'SAVE CARD',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
