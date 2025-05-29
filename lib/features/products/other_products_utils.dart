import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchRandomProducts({int count = 4, String? excludeProductId}) async {
  final productsSnap = await FirebaseFirestore.instance.collection('products').get();
  final products = await Future.wait(productsSnap.docs
      .where((doc) => excludeProductId == null || doc.id != excludeProductId)
      .map((doc) async {
    final productData = doc.data();
    final shopId = productData['shopId'];
    DocumentSnapshot shopSnap = await FirebaseFirestore.instance.doc('/shops/$shopId').get();
    Map<String, dynamic>? shopData = {};
    if (shopSnap.exists) {
      shopData = shopSnap.data() as Map<String, dynamic>? ?? {};
    }

    return {...productData, 'id': doc.id, 'shop': shopData};
  }));
  products.shuffle(Random());
  return products.take(count).toList();
}
