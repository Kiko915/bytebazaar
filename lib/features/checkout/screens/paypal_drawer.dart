import 'package:flutter/material.dart';

class PayPalDrawer extends StatelessWidget {
  final String email;
  final VoidCallback onVerified;

  const PayPalDrawer({Key? key, required this.email, required this.onVerified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.paypalobjects.com/webstatic/icon/pp258.png',
                height: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                'PayPal',
                style: TextStyle(
                  color: Color(0xFF003087),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'PayPal Email',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'This is a demo PayPal verification flow. Any email will be accepted.',
            style: TextStyle(color: Colors.orange, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF003087),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onVerified();
            },
            child: const Text('Continue'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
