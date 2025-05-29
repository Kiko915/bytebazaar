import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShopNameFuture extends StatelessWidget {
  final String shopId;
  final TextStyle? style;
  final Widget? loading;
  final Widget? errorWidget;

  const ShopNameFuture({Key? key, required this.shopId, this.style, this.loading, this.errorWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('shops').doc(shopId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const SizedBox.shrink();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return errorWidget ?? const Text('-', style: TextStyle(color: Colors.red));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        return Text(data?['name'] ?? '-', style: style);
      },
    );
  }
}
