import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageAccountDetailsModal extends StatefulWidget {
  const ManageAccountDetailsModal({super.key});

  @override
  _ManageAccountDetailsModalState createState() => _ManageAccountDetailsModalState();
}

class _ManageAccountDetailsModalState extends State<ManageAccountDetailsModal> {
  // User data fetched from Firestore
  Map<String, dynamic>? _userData;

  // Text editing controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  
  // Track which field is currently being edited
  String? _editingField;

  @override
  void initState() {
    super.initState();
    _fetchAndSetUserData();
  }

  Future<void> _fetchAndSetUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        _firstNameController.text = _userData?['firstName'] ?? '';
        _middleNameController.text = _userData?['middleName'] ?? '';
        _lastNameController.text = _userData?['lastName'] ?? '';
        _occupationController.text = _userData?['occupation'] ?? '';
        _birthdayController.text = _userData?['birthday'] ?? '';
        _emailController.text = _userData?['email'] ?? '';
        _phoneController.text = _userData?['phone'] ?? '';
        _countryController.text = _userData?['country'] ?? '';
        _regionController.text = _userData?['region'] ?? '';
        _cityController.text = _userData?['province'] ?? '';
        _municipalityController.text = _userData?['city'] ?? '';
        _addressController.text = _userData?['street'] ?? '';
        _zipCodeController.text = _userData?['zip'] ?? '';
        setState(() {});
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
    _regionController.dispose();
    _cityController.dispose();
    _municipalityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                  
                  // Occupation
                  _buildTextField(
                    label: 'Occupation',
                    controller: _occupationController,
                    isEditing: _editingField == 'occupation',
                    onEditPressed: () => _setEditingField('occupation'),
                  ),
                  const SizedBox(height: 8),
                  
                  // Birthday
                  _buildTextField(
                    label: 'Birthday (MM/DD/YYYY)',
                    controller: _birthdayController,
                    isEditing: _editingField == 'birthday',
                    onEditPressed: () => _setEditingField('birthday'),
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
                  
                  // Country
                  _buildTextField(
                    label: 'Country',
                    controller: _countryController,
                    isEditing: _editingField == 'country',
                    onEditPressed: () => _setEditingField('country'),
                  ),
                  const SizedBox(height: 8),
                  
                  // Region
                  _buildTextField(
                    label: 'Region',
                    controller: _regionController,
                    isEditing: _editingField == 'region',
                    onEditPressed: () => _setEditingField('region'),
                  ),
                  const SizedBox(height: 8),
                  
                  // City/Province
                  _buildTextField(
                    label: 'City/Province',
                    controller: _cityController,
                    isEditing: _editingField == 'city',
                    onEditPressed: () => _setEditingField('city'),
                  ),
                  const SizedBox(height: 8),
                  
                  // Municipality
                  _buildTextField(
                    label: 'Municipality',
                    controller: _municipalityController,
                    isEditing: _editingField == 'municipality',
                    onEditPressed: () => _setEditingField('municipality'),
                  ),
                  const SizedBox(height: 8),
                  
                  // House No./Street/Block
                  _buildTextField(
                    label: 'House No./Street/Block',
                    controller: _addressController,
                    isEditing: _editingField == 'address',
                    onEditPressed: () => _setEditingField('address'),
                  ),
                  const SizedBox(height: 8),
                  
                  // Zip Code
                  _buildTextField(
                    label: 'Zip Code',
                    controller: _zipCodeController,
                    isEditing: _editingField == 'zipCode',
                    onEditPressed: () => _setEditingField('zipCode'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Save changes button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Save changes and close modal
                setState(() {
                  _editingField = null; // Exit edit mode for all fields
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Changes saved')),
                );
                Navigator.of(context).pop();
              },
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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