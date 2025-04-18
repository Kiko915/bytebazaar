import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  _SellerRegistrationScreenState createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Image files to be uploaded
  File? _birCertificateFile;
  File? _validIdFile;
  
  // Form field controllers
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _businessReasonController = TextEditingController();
  final _idTypeController = TextEditingController();
  
  // Checkbox state
  bool _termsAccepted = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();

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

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _businessReasonController.dispose();
    _idTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'SELLER REGISTRATION',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            // Seller illustration
                            Image.asset(
                              'assets/images/vectors/seller_registration.svg',
                              height: 120,
                              errorBuilder: (context, error, stackTrace) {
                                print('Error loading image: $error');
                                return Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFEAF2FF),
                                    borderRadius: BorderRadius.circular(BSizes.borderRadiusLg),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 60, 
                                    color: Color(0xFF4285F4)
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: 20),
                            
                            // Welcome text
                            Text(
                              'WELCOME, FUTURE SELLER!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Color(0xFF407BFF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            Text(
                              'LET\'S GET YOU STARTED!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Color(0xFF407BFF),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Introduction text
                            Text(
                              'You\'re just a few steps away from joining our awesome community of sellers. To make things smooth and easy, here\'s what you need to do:',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Color(0xFF1A4B8F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Business Name
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Business Name',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _businessNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your business name';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Business Description
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Business Description',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your business description';
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Business reason
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tell us why you want to start this business.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please tell us why you want to start this business';
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
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Color(0xFF1A4B8F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // BIR Certificate
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'BIR Certificate',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.file(
                                          _birCertificateFile!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 100,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text(
                                'Valid ID',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
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
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.file(
                                          _validIdFile!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 100,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                              child: Text(
                                'ID Type',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _idTypeController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your ID type';
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
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Color(0xFF1A4B8F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 16),
                            
                            // Terms and Conditions
                            Text(
                              'I hereby declare that the information provided is true and correct to the best of my knowledge, and I accept the Terms & Conditions and Privacy Policy.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                    ? () {
                                        if (_formKey.currentState!.validate()) {
                                          // Process data and submit
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
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
    );
  }
  
  Widget _buildNavItem(IconData icon, {required bool selected}) {
    return Container(
      decoration: BoxDecoration(
        border: selected
            ? Border(
                top: BorderSide(
                  color: Color(0xFF4285F4),
                  width: 3.0,
                ),
              )
            : null,
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          color: selected ? Color(0xFF4285F4) : Colors.grey,
        ),
      ),
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