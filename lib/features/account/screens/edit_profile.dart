import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  _EditProfileModalState createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final TextEditingController _nameController = TextEditingController();
  
  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;
      if (_firebaseUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final doc = await FirebaseFirestore.instance.collection('users').doc(_firebaseUser!.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
          _nameController.text = _userData?['fullName'] ?? _firebaseUser?.displayName ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: ${e.toString()}')),
      );
    }
  }

  // Show options to pick image
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _updateProfile() async {
    try {
      if (_firebaseUser != null) {
        // Update database fields
        final updateData = {
          'fullName': _nameController.text,
        };
        
        // If we have a new profile image, upload it
        if (_profileImageFile != null) {
          // Show loading state
          setState(() {
            _isLoading = true;
          });
          
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${_firebaseUser!.uid}.jpg');
          
          await storageRef.putFile(_profileImageFile!);
          
          // Get download URL
          final imageUrl = await storageRef.getDownloadURL();
          
          // Update photoURL in Firebase Auth
          await _firebaseUser!.updatePhotoURL(imageUrl);
          
          // Add image URL to the update data
          updateData['photoURL'] = imageUrl;
        }
        
        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(_firebaseUser!.uid).update(updateData);
        
        // Update displayName in Firebase Auth
        await _firebaseUser!.updateDisplayName(_nameController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        setState(() {
          _isLoading = false;
        });
        
        Navigator.pop(context, true); // Pop with true to indicate success
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Color(0xFF4080FF)))
        : Column(
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
                      'EDIT YOUR PROFILE',
                      style: TextStyle(
                        color: Color(0xFF4080FF),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Update your profile information to personalize your experience',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Profile image - LARGER SIZE
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 75.0, // INCREASED SIZE
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profileImageFile != null 
                          ? FileImage(_profileImageFile!) 
                          : (_firebaseUser?.photoURL != null 
                              ? NetworkImage(_firebaseUser!.photoURL!) as ImageProvider 
                              : null),
                        child: (_profileImageFile == null && _firebaseUser?.photoURL == null) 
                          ? Icon(
                              Icons.person,
                              size: 75.0, // INCREASED SIZE
                              color: Colors.grey[600],
                            ) 
                          : null,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _showImageSourceOptions,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF4080FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROFILE DETAILS',
                        style: TextStyle(
                          color: Color(0xFF4080FF),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Name field
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        isEditing: _isEditing,
                        onEditPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
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
                  onPressed: _updateProfile,
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
void showEditProfileModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => const EditProfileModal(),
    ),
  );
}
