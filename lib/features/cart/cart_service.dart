import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> addToCart({
    required String productId,
    required Map<String, dynamic> productData,
    required int quantity,
    Map<String, dynamic>? selectedVariation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId + (selectedVariation != null ? '_${selectedVariation['sku']}' : ''));

    final cartData = {
      'productId': productId,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
      'productData': productData,
      if (selectedVariation != null) 'variation': selectedVariation,
    };

    await cartRef.set(cartData, SetOptions(merge: true));
  }

  static Future<void> removeFromCart(String productId, {Map<String, dynamic>? selectedVariation}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docId = productId + (selectedVariation != null ? '_${selectedVariation['sku']}' : '');
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(docId)
        .delete();
  }

  static Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
