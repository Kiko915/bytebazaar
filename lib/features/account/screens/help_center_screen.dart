import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: const Color(0xFFEFF8FF),
      ),
      backgroundColor: const Color(0xFFEFF8FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('How do I change my password?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Go to Account Settings > Privacy and Security > Change Password.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How do I update my profile information?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Go to Account Settings > Personal Details > Edit my profile.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How do I link my payment accounts?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'Go to Account Settings > Linked Accounts and connect your PayPal, Stripe, or Razorpay accounts.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If you need further assistance, please contact our support team:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: support@bytebazaar.com',
              style: TextStyle(fontSize: 14),
            ),
            const Text(
              'Phone: +1-555-123-4567',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
