import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ShopCreationBackend {
  static Future<String?> createShop({
    required String name,
    required String description,
    required String category,
    required String country,
    required String province,
    required String city,
    required String address,
    required String contact,
    required String email,
    String? facebook,
    String? instagram,
    String? youtube,
    String? twitter,
    String? businessReg,
    File? logoFile,
    File? bannerFile,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return 'User not logged in';
      }
      // Check for unique shop name (strict: ignore case, spaces, special chars)
      String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      final normalizedNewName = normalize(name);
      final existingShops = await FirebaseFirestore.instance.collection('shops').get();
      for (final doc in existingShops.docs) {
        final existingName = doc['name'] ?? '';
        if (normalize(existingName) == normalizedNewName) {
          return 'Shop name already taken';
        }
      }
      final shopData = {
        'name': name,
'normalizedName': name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
        'description': description,
        'category': category,
        'country': country,
        'province': province,
        'city': city,
        'address': address,
        'contact': contact,
        'email': email,
        'facebook': facebook,
        'instagram': instagram,
        'youtube': youtube,
        'twitter': twitter,
        'businessReg': businessReg,
        'ownerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final shopsRef = FirebaseFirestore.instance.collection('shops');
      final doc = await shopsRef.add(shopData);

      // Upload images to Firebase Storage and update Firestore with URLs
      String? logoUrl;
      String? bannerUrl;
      print('[ShopCreationBackend] logoFile: ' + (logoFile?.path ?? 'null') + ', exists: ${logoFile?.existsSync()}');
      print('[ShopCreationBackend] bannerFile: ' + (bannerFile?.path ?? 'null') + ', exists: ${bannerFile?.existsSync()}');
      if (logoFile != null && logoFile.existsSync()) {
        final ref = FirebaseStorage.instance.ref().child('shop_logos/${doc.id}.jpg');
        await ref.putFile(logoFile);
        logoUrl = await ref.getDownloadURL();
      }
      if (bannerFile != null && bannerFile.existsSync()) {
        final ref = FirebaseStorage.instance.ref().child('shop_banners/${doc.id}.jpg');
        await ref.putFile(bannerFile);
        bannerUrl = await ref.getDownloadURL();
      }
      if (logoUrl != null || bannerUrl != null) {
        await doc.update({
          if (logoUrl != null) 'logoUrl': logoUrl,
          if (bannerUrl != null) 'bannerUrl': bannerUrl,
        });
      }
      return null; // null means success
    } catch (e, stack) {
      print('[ShopCreationBackend] Error: ' + e.toString());
      print(stack);
      return e.toString();
    }
  }
}
