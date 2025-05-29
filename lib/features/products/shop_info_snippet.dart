import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopInfoSnippet extends StatelessWidget {
  final String? shopId;
  const ShopInfoSnippet({Key? key, required this.shopId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (shopId == null) return const SizedBox.shrink();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('shops').doc(shopId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final shopData = snapshot.data!.data() as Map<String, dynamic>?;
        if (shopData == null) return const SizedBox.shrink();
        return Row(
          children: [
            const Icon(Icons.store, size: 18, color: Colors.blueAccent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                shopData['name'] ?? '-',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                (shopData['city'] ?? '-') + ', ' + (shopData['province'] ?? '-'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
