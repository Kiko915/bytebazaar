import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';
import 'package:lottie/lottie.dart';
import 'seller_status_screen.dart';
import 'dart:async';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  _SellerRegistrationScreenState createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  bool _isCheckingStatus = true;
  // Helper to show zoomable image dialog
  void _showZoomableImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  // Image files to be uploaded
  File? _birCertificateFile;
  File? _validIdFile;

  // Form field controllers
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessReasonController = TextEditingController();
  //final _idTypeController = TextEditingController();

  // Business type dropdown
  final List<String> _businessTypes = [
    'Sole Proprietorship',
    'Partnership',
    'Corporation',
    'Cooperative',
    'Non-Profit',
    'Others (please specify)',
  ];
  String? _selectedBusinessType;
  final TextEditingController _otherBusinessTypeController =
      TextEditingController();

  // ID type dropdown
  final List<String> _idTypes = [
    'Passport',
    'Driver\'s License',
    'National ID',
    'SSS',
    'UMID',
    'PRC',
    'Postal',
    'Voter\'s ID',
    'PhilHealth',
    'TIN',
    'Others',
  ];
  String? _selectedIdType;

  // Checkbox state
  bool _termsAccepted = false;

  // Loading state
  bool _isSubmitting = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // --- SUBMIT SELLER APPLICATION ---
  Future<void> _submitSellerApplication() async {
    if (_birCertificateFile == null || _validIdFile == null) {
      BFeedback.show(
        context,
        message: 'Please upload both BIR Certificate and Valid ID.',
        type: BFeedbackType.error,
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isSubmitting = false;
        });
        BFeedback.show(
          context,
          message: 'You must be logged in.',
          type: BFeedbackType.error,
        );
        return;
      }
      // Upload images to Firebase Storage
      final storage = FirebaseStorage.instance;
      final birRef = storage
          .ref()
          .child('seller_applications/${user.uid}/bir_certificate.jpg');
      final idRef =
          storage.ref().child('seller_applications/${user.uid}/valid_id.jpg');
      final birUpload = await birRef.putFile(_birCertificateFile!);
      final idUpload = await idRef.putFile(_validIdFile!);
      final birUrl = await birUpload.ref.getDownloadURL();
      final idUrl = await idUpload.ref.getDownloadURL();
      // Prepare application data
      final data = {
        'userId': user.uid,
        'businessName': _businessNameController.text.trim(),
        'businessType': _selectedBusinessType == 'Others (please specify)'
            ? _otherBusinessTypeController.text.trim()
            : (_selectedBusinessType ?? ''),
        'businessDescription': _businessDescriptionController.text.trim(),
        'businessReason': _businessReasonController.text.trim(),
        'idType': _selectedIdType ?? '',
        'birCertificateUrl': birUrl,
        'validIdUrl': idUrl,
        'termsAccepted': _termsAccepted,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      };
      // Store in Firestore
      await FirebaseFirestore.instance
          .collection('seller_applications')
          .doc(user.uid)
          .set(data);
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => SellerStatusScreen(status: 'pending'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        _isSubmitting = false;
      });
      BFeedback.show(
        context,
        message: 'Failed to submit application: ${e.toString()}',
        type: BFeedbackType.error,
      );
    }
  }

  // Pick image from gallery
  Future<void> _pickImage(ImageSource source, bool isBirCertificate) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          if (isBirCertificate) {
            _birCertificateFile = File(pickedFile.path);
          } else {
            _validIdFile = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  // Show options to pick image
  void _showImageSourceOptions(bool isBirCertificate) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isBirCertificate);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isBirCertificate);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  StreamSubscription<DocumentSnapshot>? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _listenToSellerStatus();
  }

  void _listenToSellerStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isCheckingStatus = false);
      return;
    }
    _statusSubscription = FirebaseFirestore.instance
        .collection('seller_applications')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (!doc.exists || doc.data() == null) {
        setState(() => _isCheckingStatus = false);
        return;
      }
      final data = doc.data()!;
      final status = data['status'] ?? 'pending';
      setState(() => _isCheckingStatus = false);
      if (status == 'pending') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SellerStatusScreen(status: 'pending'),
            ),
          );
        });
      } else if (status == 'rejected') {
        final reason = data['rejectionReason'] ?? '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SellerStatusScreen(
                status: 'rejected',
                rejectionReason: reason,
                onReapply: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => SellerRegistrationScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        });
      } else if (status == 'approved') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SellerStatusScreen(
                status: 'approved',
                onGoToDashboard: () {
                  // TODO: navigate to seller dashboard
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _businessReasonController.dispose();
    _otherBusinessTypeController.dispose();
    // _idTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Color(0xFF4285F4), Color(0xFFEEF7FE)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'SELLER REGISTRATION',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Seller animation
                              SizedBox(
                                height: 120,
                                width: 120,
                                child: Builder(
                                  builder: (context) {
                                    try {
                                      return Lottie.asset(
                                        'assets/lottie/seller.json',
                                        fit: BoxFit.contain,
                                        repeat: true,
                                      );
                                    } catch (e) {
                                      print(
                                          'Error loading Lottie animation: $e');
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFEAF2FF),
                                          borderRadius: BorderRadius.circular(
                                              BSizes.borderRadiusLg),
                                        ),
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 60,
                                          color: Color(0xFF4285F4),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),

                              SizedBox(height: 20),

                              // Welcome text
                              Text(
                                'WELCOME, FUTURE SELLER!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Color(0xFF407BFF),
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              Text(
                                'LET\'S GET YOU STARTED!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Color(0xFF407BFF),
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 16),

                              // Introduction text
                              Text(
                                'You\'re just a few steps away from joining our awesome community of sellers. To make things smooth and easy, here\'s what you need to do:',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.justify,
                              ),

                              SizedBox(height: 24),

                              // STEP 1: Fill in your details
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'STEP 1: Fill in your details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Color(0xFF1A4B8F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Business Name
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Business Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _businessNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Business name is required';
                                  }
                                  if (value.trim().length < 5) {
                                    return 'Business name must be at least 5 characters';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Business Type
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Business Type',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedBusinessType,
                                items: _businessTypes
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedBusinessType = val;
                                    if (val != 'Others (please specify)') {
                                      _otherBusinessTypeController.clear();
                                    }
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your business type';
                                  }
                                  return null;
                                },
                              ),
                              if (_selectedBusinessType ==
                                  'Others (please specify)') ...[
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _otherBusinessTypeController,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Please specify your business type',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                  ),
                                  validator: (value) {
                                    if (_selectedBusinessType ==
                                        'Others (please specify)') {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please specify your business type';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'Business type must be at least 3 characters';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              SizedBox(height: 16),
                              // Business Description
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Business Description',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _businessDescriptionController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Business description is required';
                                  }
                                  if (value.trim().length < 50) {
                                    return 'Description must be at least 50 characters';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 16),

                              // Business reason
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        'Tell us why you want to start this business.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _businessReasonController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'This field is required';
                                  }
                                  if (value.trim().length < 100) {
                                    return 'Please provide more detail';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 24),

                              // STEP 2: Upload your documents
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'STEP 2: Upload your documents',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Color(0xFF1A4B8F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // BIR Certificate
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'BIR Certificate',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showImageSourceOptions(true),
                                child: DashedBorder(
                                  color: Colors.blue,
                                  strokeWidth: 1.5,
                                  gap: 4.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: _birCertificateFile != null
                                        ? GestureDetector(
                                            onTap: () =>
                                                _showZoomableImageDialog(
                                                    _birCertificateFile!),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.file(
                                                _birCertificateFile!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 100,
                                              ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.blue,
                                                size: 32,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Insert image here.',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Valid ID
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Valid ID',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showImageSourceOptions(false),
                                child: DashedBorder(
                                  color: Colors.blue,
                                  strokeWidth: 1.5,
                                  gap: 4.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: _validIdFile != null
                                        ? GestureDetector(
                                            onTap: () =>
                                                _showZoomableImageDialog(
                                                    _validIdFile!),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.file(
                                                _validIdFile!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 100,
                                              ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Colors.blue,
                                                size: 32,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Insert image here.',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // ID Type
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'ID Type',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedIdType,
                                items: _idTypes
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                onChanged: (val) =>
                                    setState(() => _selectedIdType = val),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your ID type';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 24),

                              // STEP 3: Confirmation
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'STEP 3: Confirmation',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Color(0xFF1A4B8F),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),

                              SizedBox(height: 16),

                              // Terms and Conditions
                              Text(
                                'I hereby declare that the information provided is true and correct to the best of my knowledge, and I accept the Terms & Conditions and Privacy Policy.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.justify,
                              ),

                              SizedBox(height: 8),

                              // Checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _termsAccepted,
                                    onChanged: (value) {
                                      setState(() {
                                        _termsAccepted = value!;
                                      });
                                    },
                                    activeColor: Color(0xFF4285F4),
                                  ),
                                  Text(
                                    'I confirm.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey[800],
                                          fontSize: 14.0,
                                        ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _termsAccepted
                                      ? () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (_birCertificateFile == null ||
                                                _validIdFile == null) {
                                              BFeedback.show(
                                                context,
                                                message:
                                                    'Please upload both BIR Certificate and Valid ID.',
                                                type: BFeedbackType.error,
                                              );
                                              return;
                                            }
                                            await _submitSellerApplication();
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4285F4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    disabledBackgroundColor: Colors.grey,
                                  ),
                                  child: Text(
                                    'SUBMIT',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double dashWidth = 6.0;
    final double dashSpace = gap;
    double startX = 0;
    double y = 0;

    // Top edge
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Right edge
    startX = size.width;
    y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX, y + dashWidth),
        dashedPaint,
      );
      y += dashWidth + dashSpace;
    }

    // Bottom edge
    startX = size.width;
    y = size.height;
    while (startX > 0) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX - dashWidth, y),
        dashedPaint,
      );
      startX -= dashWidth + dashSpace;
    }

    // Left edge
    startX = 0;
    y = size.height;
    while (y > 0) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX, y - dashWidth),
        dashedPaint,
      );
      y -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double gap;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.color = Colors.blue,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: color,
          strokeWidth: strokeWidth,
          gap: gap,
        ),
        child: child,
      ),
    );
  }
}
