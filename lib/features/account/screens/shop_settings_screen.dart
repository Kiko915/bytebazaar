import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

class ShopSettingsScreen extends StatefulWidget {
  final String shopId;
  final Map<String, dynamic> shopData;
  const ShopSettingsScreen({Key? key, required this.shopId, required this.shopData}) : super(key: key);

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _businessRegController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _youtubeController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _countryController;
  File? _logoFile;
  File? _bannerFile;
  bool _saving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _categoryController = TextEditingController();
    _descController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
    _businessRegController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _youtubeController = TextEditingController();
    _provinceController = TextEditingController();
    _cityController = TextEditingController();
    _countryController = TextEditingController();
    _fetchLatestShopData();
  }

  Future<void> _fetchLatestShopData() async {
    final doc = await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _categoryController.text = data['category'] ?? '';
        _descController.text = data['description'] ?? '';
        _addressController.text = data['address'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _emailController.text = data['email'] ?? '';
        _businessRegController.text = data['businessReg'] ?? '';
        _facebookController.text = data['facebook'] ?? '';
        _instagramController.text = data['instagram'] ?? '';
        _twitterController.text = data['twitter'] ?? '';
        _youtubeController.text = data['youtube'] ?? '';
        _provinceController.text = data['province'] ?? '';
        _cityController.text = data['city'] ?? '';
        _countryController.text = data['country'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _businessRegController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(picked.path);
        } else {
          _bannerFile = File(picked.path);
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() { _saving = true; });
    String? logoUrl = widget.shopData['logoUrl'];
    String? bannerUrl = widget.shopData['bannerUrl'];

    // Upload _logoFile to Firebase Storage if changed
    if (_logoFile != null && _logoFile!.existsSync()) {
      final ref = FirebaseStorage.instance.ref().child('shop_logos/${widget.shopId}.jpg');
      await ref.putFile(_logoFile!);
      logoUrl = await ref.getDownloadURL();
    }
    // Upload _bannerFile to Firebase Storage if changed
    if (_bannerFile != null && _bannerFile!.existsSync()) {
      final ref = FirebaseStorage.instance.ref().child('shop_banners/${widget.shopId}.jpg');
      await ref.putFile(_bannerFile!);
      bannerUrl = await ref.getDownloadURL();
    }
    // Update Firestore fields
    await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).update({
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'bannerUrl': bannerUrl,
      'logoUrl': logoUrl,
      'businessReg': _businessRegController.text.trim(),
      'facebook': _facebookController.text.trim(),
      'instagram': _instagramController.text.trim(),
      'twitter': _twitterController.text.trim(),
      'youtube': _youtubeController.text.trim(),
      'province': _provinceController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
    });
    setState(() { _saving = false; });
    if (mounted) {
      BFeedback.show(
        context,
        message: 'Shop updated successfully!',
        type: BFeedbackType.success,
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteShop() async {
    final TextEditingController confirmController = TextEditingController();
    bool canDelete = false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            canDelete = confirmController.text.trim() == _nameController.text.trim();
            return AlertDialog(
              title: const Text('Delete Shop'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Products that belong to this shop will be deleted.\n\nThis action cannot be undone.',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  Text('To confirm, type the shop name below:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: _nameController.text,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        canDelete = val.trim() == _nameController.text.trim();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      setState(() { _saving = true; });
      // Delete all products belonging to this shop
      final products = await FirebaseFirestore.instance
          .collection('products')
          .where('shopId', isEqualTo: widget.shopId)
          .get();
      for (var doc in products.docs) {
        await doc.reference.delete();
      }
      // Delete the shop itself
      await FirebaseFirestore.instance.collection('shops').doc(widget.shopId).delete();
      setState(() { _saving = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop and all products deleted.')),
        );
        Navigator.of(context).pop({'deleted': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Settings'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Picker
                  const Text('Shop Logo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Card(
                          elevation: 2,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _logoFile != null
                                ? FileImage(_logoFile!)
                                : (widget.shopData['logoUrl'] != null
                                    ? NetworkImage(widget.shopData['logoUrl']) as ImageProvider
                                    : null),
                            child: _logoFile == null && (widget.shopData['logoUrl'] == null || widget.shopData['logoUrl'].toString().isEmpty)
                                ? const Icon(Icons.storefront, size: 48, color: Colors.grey)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _pickImage(true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Banner Picker
                  const Text('Shop Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.grey[200],
                              width: 280,
                              height: 80,
                              child: _bannerFile != null
                                  ? Image.file(_bannerFile!, width: 280, height: 80, fit: BoxFit.cover)
                                  : (widget.shopData['bannerUrl'] != null
                                      ? Image.network(widget.shopData['bannerUrl'], width: 280, height: 80, fit: BoxFit.cover)
                                      : const Icon(Icons.image, size: 48, color: Colors.grey)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 24,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _pickImage(false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Editable fields
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(labelText: 'Contact'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _provinceController,
                    decoration: const InputDecoration(labelText: 'Province'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _businessRegController,
                    decoration: const InputDecoration(labelText: 'Business Registration'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _facebookController,
                    decoration: const InputDecoration(labelText: 'Facebook'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _instagramController,
                    decoration: const InputDecoration(labelText: 'Instagram'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _twitterController,
                    decoration: const InputDecoration(labelText: 'Twitter'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _youtubeController,
                    decoration: const InputDecoration(labelText: 'YouTube'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Save Changes'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _deleteShop,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete Shop'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
