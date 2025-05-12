import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/features/authentication/controller/auth_controller.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mime/mime.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  _EditProfileModalState createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _hasUnsavedChanges = false;
  String? _originalName;
  String? _originalUsername;
  
  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _savingPhoto = false;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_checkForUnsavedChanges);
    _usernameController.addListener(_checkForUnsavedChanges);
    _fetchUserData();
  }

  void _checkForUnsavedChanges() {
    final hasChanges =
        (_originalName != null && _nameController.text != _originalName) ||
        (_originalUsername != null && _usernameController.text != _originalUsername);
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
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
          _usernameController.text = _userData?['username'] ?? '';
          _originalName = _nameController.text;
          _originalUsername = _usernameController.text;
          _isLoading = false;
          _hasUnsavedChanges = false;
          // Optionally force lowercase username for uniqueness
          _usernameController.text = _usernameController.text.toLowerCase();
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
        // Validate file type
        final mimeType = lookupMimeType(pickedFile.path);
        if (mimeType != null && !(mimeType == 'image/jpeg' || mimeType == 'image/png')) {
          BFeedback.show(
            context,
            message: 'Only JPG and PNG images are allowed.',
            type: BFeedbackType.error,
            position: BFeedbackPosition.top,
          );
          return;
        }
        // Validate file size (max 5MB)
        final file = File(pickedFile.path);
        if (await file.length() > 5 * 1024 * 1024) {
          BFeedback.show(
            context,
            message: 'Image size must be less than 5MB.',
            type: BFeedbackType.error,
            position: BFeedbackPosition.top,
          );
          return;
        }
        // Crop image
        final cropped = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Color(0xFF4080FF),
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true,
            ),
          ],
        );
        if (cropped != null) {
          print('Image picked: ' + pickedFile.path);
          print('Image cropped: ' + cropped.path);
          setState(() {
            _profileImageFile = File(cropped.path);
            _hasUnsavedChanges = true;
          });
          BFeedback.show(
            context,
            message: 'Profile photo selected!',
            type: BFeedbackType.success,
            position: BFeedbackPosition.top,
          );
        } else {
          BFeedback.show(
            context,
            message: 'Image cropping cancelled or failed.',
            type: BFeedbackType.error,
            position: BFeedbackPosition.top,
          );
        }
      }
    } catch (e) {
      // Handle error
      print('Error selecting image: ${e.toString()}');
      BFeedback.show(
        context,
        message: 'Error selecting image: ${e.toString()}',
        type: BFeedbackType.error,
        position: BFeedbackPosition.top,
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
        // Check for username uniqueness
        final username = _usernameController.text.trim();
        if (username.isEmpty) {
          BFeedback.show(
            context,
            message: 'Username cannot be empty',
            type: BFeedbackType.error,
          );
          return;
        }
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();
        final duplicate = query.docs.any((doc) => doc.id != _firebaseUser!.uid);
        if (duplicate) {
          BFeedback.show(
            context,
            message: 'Username is already taken. Please choose another.',
            type: BFeedbackType.error,
          );
          return;
        }
        // Update database fields
        final updateData = {
          'fullName': _nameController.text,
          'username': username,
        };
        
        // If we have a new profile image, upload it
        if (_profileImageFile != null) {
          // Show loading state
          setState(() {
            _isLoading = true;
            _savingPhoto = true;
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

        // Refresh username everywhere
        try {
          final authController = Get.isRegistered<AuthController>()
              ? Get.find<AuthController>()
              : null;
          await authController?.fetchAndSetUsername();
        } catch (_) {}

        setState(() {
          _originalName = _nameController.text;
          _originalUsername = _usernameController.text;
          _hasUnsavedChanges = false;
        });

        BFeedback.show(
          context,
          message: 'Profile updated successfully!',
          type: BFeedbackType.success,
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
      
      BFeedback.show(
        context,
        message: 'Error updating profile: ${e.toString()}',
        type: BFeedbackType.error,
      );
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForUnsavedChanges);
    _usernameController.removeListener(_checkForUnsavedChanges);
    _nameController.dispose();
    _usernameController.dispose();
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
                    if (_savingPhoto)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF4080FF)),
                          ),
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
                      
                      // Username field
                      _buildTextField(
                        label: 'Username',
                        controller: _usernameController,
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
                    'You have unsaved changes. Please save all changes before closing.',
                    style: TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Save changes button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasUnsavedChanges ? _updateProfile : null,
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
