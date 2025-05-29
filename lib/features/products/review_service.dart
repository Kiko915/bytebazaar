import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<bool> userCanReview(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // Check if the user has purchased the product (look for an order with this product and user)
    final orders = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('products', arrayContains: productId)
        .get();
    return orders.docs.isNotEmpty;
  }

  static Future<void> addReview(String productId, String review, double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('products').doc(productId).collection('reviews').add({
      'userId': user.uid,
      'review': review,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> getReviews(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
