import 'package:cloud_firestore/cloud_firestore.dart';

/// Given a parent category name, returns a list of all category names (including the parent and all its subcategories).
Future<List<String>> getAllCategoryNamesForParent(String parentCategoryName) async {
  final categoriesSnap = await FirebaseFirestore.instance.collection('categories').get();
  final docs = categoriesSnap.docs;
  // Find the parent category document
  QueryDocumentSnapshot? parentDoc;
  try {
    parentDoc = docs.firstWhere(
      (doc) => (doc['name'] ?? '').toString().trim() == parentCategoryName,
    );
  } catch (e) {
    // Parent not found
    return [parentCategoryName];
  }
  final parentId = parentDoc.id;
  // Collect subcategories
  final subCategories = docs.where((doc) => (doc['parent'] ?? '') == parentId).toList();
  final names = <String>[parentCategoryName];
  names.addAll(subCategories.map((doc) => (doc['name'] ?? '').toString().trim()));
  return names;
}
