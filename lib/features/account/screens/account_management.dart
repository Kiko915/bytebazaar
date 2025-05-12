import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:bytebazaar/features/account/widgets/dropdown_address_section.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ManageAccountDetailsModal extends StatefulWidget {
  const ManageAccountDetailsModal({super.key});

  @override
  _ManageAccountDetailsModalState createState() =>
      _ManageAccountDetailsModalState();
}

class _ManageAccountDetailsModalState extends State<ManageAccountDetailsModal> {
  bool _loading = true;

  String? _findCanonical(List<String> list, String? value) {
    if (value == null || value.isEmpty) return null;
    return list.firstWhere(
      (e) => e.trim().toLowerCase() == value.trim().toLowerCase(),
      orElse: () => value,
    );
  }

  String? _normalizeOccupation(String? value) {
    if (value == null) return null;
    switch (value.trim().toLowerCase()) {
      case 'student':
        return 'Student';
      case 'unemployed':
        return 'Unemployed';
      case 'employed':
        return 'Employed';
      case 'self-employed':
      case 'self employed':
      case 'selfemployed':
      case 'self-employed.':
        return 'Self-Employed';
      default:
        return value;
    }
  }

  // Address dropdown data
  List<String> _countryList = [];
  List<String> _provinceList = [];
  List<String> _cityList = [];
  String? _selectedCountry;
  String? _selectedProvince;
  String? _selectedCity;
  List<dynamic> _cpcData = [];

  // User data fetched from Firestore
  Map<String, dynamic>? _userData;

  // Track unsaved changes
  bool _hasUnsavedChanges = false;

  // Text editing controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  // Track which field is currently being edited
  String? _editingField;

  @override
  void initState() {
    super.initState();
    _loadCPCData().then((_) async {
      await _fetchAndSetUserData();
      _setupChangeListeners();
      setState(() {
        _loading = false;
      });
    });
  }

  void _setupChangeListeners() {
    final controllers = [
      _firstNameController,
      _middleNameController,
      _lastNameController,
      _occupationController,
      _birthdayController,
      _emailController,
      _phoneController,
      _countryController,
      _cityController,
      _municipalityController,
      _addressController,
      _zipCodeController,
    ];
    for (final c in controllers) {
      c.addListener(() {
        _checkForUnsavedChanges();
      });
    }
  }

  void _checkForUnsavedChanges() {
    // Sync dropdown controllers
    if (_selectedCountry != null) _countryController.text = _selectedCountry!;
    if (_selectedProvince != null)
      _municipalityController.text = _selectedProvince!;
    if (_selectedCity != null) _cityController.text = _selectedCity!;

    if (_userData == null) return;
    final updated = {
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text,
      'lastName': _lastNameController.text,
      'occupation': _occupationController.text,
      'birthday': _birthdayController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'country': _countryController.text,
      'city': _cityController.text,
      'province': _municipalityController.text,
      'street': _addressController.text,
      'zip': _zipCodeController.text,
    };
    bool changed = false;
    updated.forEach((k, v) {
      final original = _userData![k]?.toString() ?? '';
      if (v != original) changed = true;
    });
    if (changed != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = changed;
      });
    }
  }

  Future<void> _fetchAndSetUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        _userData = doc.data();
        _firstNameController.text = _userData?['firstName'] ?? '';
        _middleNameController.text = _userData?['middleName'] ?? '';
        _lastNameController.text = _userData?['lastName'] ?? '';
        _occupationController.text = _userData?['occupation'] ?? '';
        _birthdayController.text = _userData?['birthday'] is Timestamp
            ? (_userData?['birthday'] as Timestamp)
                .toDate()
                .toIso8601String()
                .split('T')[0]
            : (_userData?['birthday'] ?? '');
        _emailController.text = _userData?['email'] ?? '';
        _phoneController.text = _userData?['phone'] ?? '';
        _countryController.text = _userData?['country'] ?? '';
        // Assign city and province correctly based on Firestore keys
        _cityController.text = _userData?['city'] ?? '';
        _municipalityController.text = _userData?['province'] ?? '';
        _addressController.text = _userData?['street'] ?? '';
        _zipCodeController.text = _userData?['zip'] ?? '';
        // --- Address Dropdowns: set selected values and update dependent lists ---
        final country = _countryController.text;
        final province = _municipalityController.text;
        final city = _cityController.text;
        setState(() {
          _selectedCountry = country.isNotEmpty ? country : null;
          _provinceList = _getProvincesForCountry(_selectedCountry);
          _selectedProvince = _findCanonical(_provinceList, province);
          _cityList = _getCitiesForProvince(_selectedProvince);
          _selectedCity = _findCanonical(_cityList, city);
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _occupationController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _municipalityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Input validation
    if (_firstNameController.text.trim().isEmpty) {
      BFeedback.show(context,
          message: 'First name is required.',
          type: BFeedbackType.error,
          position: BFeedbackPosition.top);
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      BFeedback.show(context,
          message: 'Last name is required.',
          type: BFeedbackType.error,
          position: BFeedbackPosition.top);
      return;
    }
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      BFeedback.show(context,
          message: 'Please enter a valid email address.',
          type: BFeedbackType.error,
          position: BFeedbackPosition.top);
      return;
    }
    final phone = _phoneController.text.trim();
    final phoneRegex = RegExp(r'^[0-9\-\+\s]{7,15}$');
    if (phone.isEmpty || !phoneRegex.hasMatch(phone)) {
      BFeedback.show(context,
          message: 'Please enter a valid phone number.',
          type: BFeedbackType.error,
          position: BFeedbackPosition.top);
      return;
    }
    final birthdayText = _birthdayController.text.trim();
    DateTime? birthdayDate;
    try {
      birthdayDate = DateTime.parse(birthdayText);
    } catch (_) {}
    if (birthdayDate == null) {
      BFeedback.show(context,
          message: 'Please select a valid birthday.',
          type: BFeedbackType.error,
          position: BFeedbackPosition.top);
      return;
    }

    final updatedData = {
      'firstName': _firstNameController.text,
      'middleName': _middleNameController.text,
      'lastName': _lastNameController.text,
      'occupation': _occupationController.text,
      // Store as Firestore Timestamp
      'birthday': Timestamp.fromDate(birthdayDate),
      'email': _emailController.text,
      'phone': _phoneController.text,
      'country': _countryController.text,
      'city': _cityController.text,
      'province': _municipalityController.text,
      'street': _addressController.text,
      'zip': _zipCodeController.text,
    };
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updatedData);
      setState(() {
        _hasUnsavedChanges = false;
        _editingField = null;
      });
      BFeedback.show(
        context,
        message: 'Account details updated successfully!',
        type: BFeedbackType.success,
        position: BFeedbackPosition.top,
      );
      // Optionally refresh user data
      await _fetchAndSetUserData();
    } catch (e) {
      BFeedback.show(
        context,
        message: 'Failed to update details: ${e.toString()}',
        type: BFeedbackType.error,
        position: BFeedbackPosition.top,
      );
    }
  }

  // Set the editing field
  void _setEditingField(String fieldName) {
    setState(() {
      // If the field is already being edited, turn off edit mode
      if (_editingField == fieldName) {
        _editingField = null;
      } else {
        _editingField = fieldName;

        // Request focus for the field being edited
        Future.delayed(const Duration(milliseconds: 100), () {
          if (fieldName == 'firstName') {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        });
      }
    });
  }

  Future<void> _loadCPCData() async {
    final String response = await rootBundle.loadString('assets/data/cpc.json');
    final dynamic data = json.decode(response);
    List countriesList;
    if (data is List) {
      countriesList = data;
    } else if (data is Map) {
      countriesList = [data];
    } else {
      countriesList = [];
    }
    setState(() {
      _cpcData = countriesList;
      _countryList = _cpcData.map<String>((e) => e['name'] as String).toList();
      // If user already has a country, pre-select and populate provinces/cities
      if (_countryController.text.isNotEmpty) {
        _selectedCountry = _countryController.text;
        _provinceList = _getProvincesForCountry(_selectedCountry);
      }
      if (_municipalityController.text.isNotEmpty) {
        _selectedProvince = _municipalityController.text;
        _cityList = _getCitiesForProvince(_selectedProvince);
      }
      if (_cityController.text.isNotEmpty) {
        _selectedCity = _cityController.text;
      }
    });
  }

  List<String> _getProvincesForCountry(String? countryName) {
    if (countryName == null) return [];
    final country = _cpcData.firstWhere((e) => e['name'] == countryName,
        orElse: () => null);
    if (country == null || country['states'] == null) return [];
    return (country['states'] as List)
        .map<String>((e) => e['name'] as String)
        .toList();
  }

  List<String> _getCitiesForProvince(String? provinceName) {
    if (provinceName == null) return [];
    for (final country in _cpcData) {
      final states = country['states'] as List?;
      if (states != null) {
        final province = states.firstWhere((e) => e['name'] == provinceName,
            orElse: () => null);
        if (province != null && province['cities'] != null) {
          return (province['cities'] as List)
              .map<String>((e) => (e is Map ? e['name'] : e) as String)
              .toList();
        }
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward_sharp, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
                alignment: Alignment.center,
              ),
            ],
          ),

          // Logo and title
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/logos/bb_inverted.png',
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text('BYTE BAZAAR',
                            style: TextStyle(
                              color: Color(0xFF4080FF),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'MANAGE YOUR DETAILS',
                  style: TextStyle(
                    color: Color(0xFF4080FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Edit your personal info to keep your account accurate and secure',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERSONAL DETAILS',
                    style: TextStyle(
                      color: Color(0xFF4080FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // First name
                  _buildTextField(
                    label: 'First Name',
                    controller: _firstNameController,
                    isEditing: _editingField == 'firstName',
                    onEditPressed: () => _setEditingField('firstName'),
                  ),
                  const SizedBox(height: 8),

                  // Middle name
                  _buildTextField(
                    label: 'Middle Name',
                    controller: _middleNameController,
                    isEditing: _editingField == 'middleName',
                    onEditPressed: () => _setEditingField('middleName'),
                  ),
                  const SizedBox(height: 8),

                  // Last name
                  _buildTextField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    isEditing: _editingField == 'lastName',
                    onEditPressed: () => _setEditingField('lastName'),
                  ),
                  const SizedBox(height: 8),

                  // Occupation
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Occupation'),
                    value: _occupationController.text.isNotEmpty
                        ? _normalizeOccupation(_occupationController.text)
                        : null,
                    items: const [
                      DropdownMenuItem(
                          value: 'Student', child: Text('Student')),
                      DropdownMenuItem(
                          value: 'Unemployed', child: Text('Unemployed')),
                      DropdownMenuItem(
                          value: 'Employed', child: Text('Employed')),
                      DropdownMenuItem(
                          value: 'Self-Employed', child: Text('Self-Employed')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _occupationController.text = value ?? '';
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // Birthday (Date Picker via edit icon)
                  _buildTextField(
                    label: 'Birthday (YYYY-MM-DD)',
                    controller: _birthdayController,
                    isEditing: false, // Always read-only for typing
                    onEditPressed: () async {
                      // Always show date picker on edit icon
                      DateTime? initialDate;
                      try {
                        initialDate = DateTime.parse(_birthdayController.text);
                      } catch (_) {
                        initialDate = DateTime(2000, 1, 1);
                      }
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        _birthdayController.text =
                            picked.toIso8601String().split('T')[0];
                        _checkForUnsavedChanges();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'CONTACT DETAILS',
                    style: TextStyle(
                      color: Color(0xFF4080FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  _buildTextField(
                    label: 'Email Address',
                    controller: _emailController,
                    isEditing: _editingField == 'email',
                    onEditPressed: () => _setEditingField('email'),
                  ),
                  const SizedBox(height: 8),

                  // Phone
                  _buildTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    isEditing: _editingField == 'phone',
                    onEditPressed: () => _setEditingField('phone'),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'ADDRESS',
                    style: TextStyle(
                      color: Color(0xFF4080FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownAddressSection(
                    countries: _countryList,
                    selectedCountry: _selectedCountry,
                    onCountryChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        _countryController.text = value ?? '';
                        _provinceList = _getProvincesForCountry(value);
                        _selectedProvince = null;
                        _municipalityController.text = '';
                        _cityList = [];
                        _selectedCity = null;
                        _cityController.text = '';
                        _hasUnsavedChanges = true;
                      });
                    },
                    provinces: _provinceList,
                    selectedProvince: _selectedProvince,
                    onProvinceChanged: (value) {
                      setState(() {
                        _selectedProvince = value;
                        _municipalityController.text = value ?? '';
                        _cityList = _getCitiesForProvince(value);
                        _selectedCity = null;
                        _cityController.text = '';
                        _hasUnsavedChanges = true;
                      });
                    },
                    cities: _cityList,
                    selectedCity: _selectedCity,
                    onCityChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _cityController.text = value ?? '';
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildTextField(
                      label: "House No./Street",
                      controller: _addressController,
                      isEditing: _editingField == 'address',
                      onEditPressed: () => _setEditingField('address')),
                  const SizedBox(height: 8),

                  _buildTextField(
                      label: "Zip Code",
                      controller: _zipCodeController,
                      isEditing: _editingField == 'zipCode',
                      onEditPressed: () => _setEditingField('zipCode')),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Notice for unsaved changes
          if (_hasUnsavedChanges)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: const Text(
                'You have unsaved changes. Please save all changes before leaving.',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),

          // Save changes button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasUnsavedChanges ? _updateUserData : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4080FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAVE CHANGES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isEditing ? const Color(0xFF4080FF) : Colors.grey[300]!,
          width: isEditing ? 2.0 : 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditing,
              decoration: InputDecoration(
                labelText: label,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              size: 16,
              color: isEditing ? const Color(0xFF4080FF) : Colors.grey,
            ),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the modal
void showManageAccountDetailsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => const ManageAccountDetailsModal(),
    ),
  );
}
