import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/account/screens/shop_creation_checklist_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/features/account/screens/shop_creation_backend.dart';
import 'dart:convert';

class ShopCreationScreen extends StatefulWidget {
  const ShopCreationScreen({Key? key}) : super(key: key);
  @override
  State<ShopCreationScreen> createState() => _ShopCreationScreenState();
}

class _ShopCreationScreenState extends State<ShopCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String? _selectedCountry = 'Philippines';
  String? _selectedProvince;
  String? _selectedCity;
  List<String> _provinces = [];
  List<String> _cities = [];

  // Social media controllers
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to current user's email if available
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _emailController.text = user.email!;
    }
    _loadCpc();
  }

  final TextEditingController _businessRegController = TextEditingController();

  File? _logoFile;
  File? _bannerFile;
  bool _loading = false;
  bool get _allRequiredFieldsFilled {
    return _logoFile != null &&
        _bannerFile != null &&
        _nameController.text.trim().isNotEmpty &&
        _descController.text.trim().isNotEmpty &&
        _descController.text.trim().length >= 10 &&
        _categoryController.text.trim().isNotEmpty &&
        _selectedProvince != null &&
        _selectedCity != null &&
        _addressController.text.trim().isNotEmpty &&
        _contactController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
  }

  Map<String, dynamic>? _cpcData;

  Future<void> _loadCpc() async {
    final String data =
        await DefaultAssetBundle.of(context).loadString('assets/data/cpc.json');
    final Map<String, dynamic> cpc = Map<String, dynamic>.from(
        await Future.value(await Future.sync(() => data)).then((d) =>
            d.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(d)) : {}));
    setState(() {
      _cpcData = cpc;
      _provinces =
          (cpc['states'] as List).map((e) => e['name'] as String).toList();
      if (_provinces.isNotEmpty) {
        _selectedProvince = _provinces.first;
        _updateCities();
      }
    });
  }

  void _updateCities() {
    if (_cpcData == null || _selectedProvince == null) return;
    final province = (_cpcData!['states'] as List)
        .firstWhere((e) => e['name'] == _selectedProvince, orElse: () => null);
    if (province != null && province['cities'] != null) {
      _cities =
          (province['cities'] as List).map((c) => c['name'] as String).toList();
      _selectedCity = _cities.isNotEmpty ? _cities.first : null;
    } else {
      _cities = [];
      _selectedCity = null;
    }
    setState(() {});
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = isLogo
          ? 'shop_logo_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'shop_banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');
      setState(() {
        if (isLogo) {
          _logoFile = savedImage;
        } else {
          _bannerFile = savedImage;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      BFeedback.show(
        context,
        message: 'Please fix the errors in the form before submitting.',
        type: BFeedbackType.error,
      );
      return;
    }
    if (!_allRequiredFieldsFilled) {
      BFeedback.show(
        context,
        message:
            'Please complete all required fields before creating your shop.',
        type: BFeedbackType.error,
      );
      return;
    }
    setState(() => _loading = true);
    final error = await ShopCreationBackend.createShop(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _categoryController.text.trim(),
      country: _selectedCountry ?? '',
      province: _selectedProvince ?? '',
      city: _selectedCity ?? '',
      address: _addressController.text.trim(),
      contact: _contactController.text.trim(),
      email: _emailController.text.trim(),
      facebook: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
      instagram: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
      youtube: _youtubeController.text.trim().isNotEmpty ? _youtubeController.text.trim() : null,
      twitter: _twitterController.text.trim().isNotEmpty ? _twitterController.text.trim() : null,
      businessReg: _businessRegController.text.trim().isNotEmpty ? _businessRegController.text.trim() : null,
      logoFile: _logoFile,
      bannerFile: _bannerFile,
    );
    setState(() => _loading = false);
    if (error == null) {
      BFeedback.show(
        context,
        message: 'Shop created!',
        type: BFeedbackType.success,
      );
      Navigator.of(context).maybePop();
    } else {
      BFeedback.show(
        context,
        message: 'Error: ' + error,
        type: BFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CREATE SHOP',
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Fix: Wrap the form in Expanded to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Basic Info Section ---
                        const Text('Basic Info',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        // --- Shop Logo Section ---
                        const SizedBox(height: 8),
                        const Text('Shop Logo',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      : null,
                                  child: _logoFile == null
                                      ? const Icon(Icons.storefront,
                                          size: 48, color: Colors.grey)
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
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.camera_alt,
                                          size: 20, color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text('Tap the icon to upload your shop logo',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                        ),
                        const SizedBox(height: 18),
                        // --- Shop Banner Section ---
                        const Text('Shop Banner',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: Colors.grey[200],
                                    width: 280,
                                    height: 80,
                                    child: _bannerFile != null
                                        ? Image.file(_bannerFile!,
                                            width: 280,
                                            height: 80,
                                            fit: BoxFit.cover)
                                        : const Icon(Icons.image,
                                            size: 48, color: Colors.grey),
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
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.camera_alt,
                                          size: 20, color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text('Tap the icon to upload your shop banner',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Shop Name *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          maxLines: 2,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Description is required.';
                            if (v.trim().length < 10)
                              return 'Description must be at least 10 characters.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 18),
                        // --- Address Section ---
                        const Text('Address',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          items: [
                            DropdownMenuItem(
                                value: 'Philippines',
                                child: Text('Philippines'))
                          ],
                          onChanged: (_) {},
                          decoration:
                              const InputDecoration(labelText: 'Country'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedProvince,
                          items: _provinces
                              .map((prov) => DropdownMenuItem(
                                  value: prov, child: Text(prov)))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedProvince = v;
                              _updateCities();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Province *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedCity,
                          items: _cities
                              .map((city) => DropdownMenuItem(
                                  value: city, child: Text(city)))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedCity = v);
                          },
                          decoration: const InputDecoration(
                            labelText: 'City *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Street Address *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _contactController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Contact Number *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            labelStyle: TextStyle(color: Colors.black),
                            suffixText: '*',
                            suffixStyle: TextStyle(color: Colors.red),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Required';
                            final emailPattern =
                                r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
                            final regExp = RegExp(emailPattern);
                            if (!regExp.hasMatch(v.trim()))
                              return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // --- Social Media Section ---
                        const Text('Social Media Links',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        const Divider(),
                        TextFormField(
                          controller: _facebookController,
                          decoration: const InputDecoration(
                            labelText: 'Facebook (optional)',
                            prefixIcon:
                                Icon(Icons.facebook, color: Color(0xFF4267B2)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _instagramController,
                          decoration: const InputDecoration(
                            labelText: 'Instagram (optional)',
                            prefixIcon: Icon(Icons.camera_alt,
                                color: Color(0xFFE1306C)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _youtubeController,
                          decoration: const InputDecoration(
                            labelText: 'YouTube (optional)',
                            prefixIcon: Icon(Icons.ondemand_video,
                                color: Color(0xFFFF0000)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _twitterController,
                          decoration: const InputDecoration(
                            labelText: 'X / Twitter (optional)',
                            prefixIcon: Icon(Icons.alternate_email,
                                color: Color(0xFF1DA1F2)),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // --- Checklist Section ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Checklist',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              ChecklistItem(
                                label: 'Shop Logo',
                                isChecked: _logoFile != null,
                              ),
                              ChecklistItem(
                                label: 'Shop Banner',
                                isChecked: _bannerFile != null,
                              ),
                              ChecklistItem(
                                label: 'Shop Name',
                                isChecked:
                                    _nameController.text.trim().isNotEmpty,
                              ),
                              ChecklistItem(
                                label: 'Description (min 10 chars)',
                                isChecked:
                                    _descController.text.trim().length >= 10,
                              ),
                              ChecklistItem(
                                label: 'Category',
                                isChecked:
                                    _categoryController.text.trim().isNotEmpty,
                              ),
                              ChecklistItem(
                                label: 'Province',
                                isChecked: _selectedProvince != null,
                              ),
                              ChecklistItem(
                                label: 'City',
                                isChecked: _selectedCity != null,
                              ),
                              ChecklistItem(
                                label: 'Street Address',
                                isChecked:
                                    _addressController.text.trim().isNotEmpty,
                              ),
                              ChecklistItem(
                                label: 'Contact Number',
                                isChecked:
                                    _contactController.text.trim().isNotEmpty,
                              ),
                              ChecklistItem(
                                label: 'Email',
                                isChecked:
                                    _emailController.text.trim().isNotEmpty,
                              ),
                            ],
                          ),
                        ),
                        // --- Other Info Section ---
                        TextFormField(
                          controller: _businessRegController,
                          decoration: const InputDecoration(
                              labelText:
                                  'Business Registration Number (optional)'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading || !_allRequiredFieldsFilled
                                ? null
                                : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Create Shop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
