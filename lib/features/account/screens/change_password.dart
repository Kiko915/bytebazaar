import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  @override
  _ChangePasswordModalState createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showPasswordMismatch = false;
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  double _passwordStrength = 0; // 0: weak, 1: strong
  String _passwordStrengthLabel = '';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_updatePasswordStrength);
    _confirmPasswordController.addListener(_validatePasswordMatch);
    _newPasswordController.addListener(_validatePasswordMatch);
  }

  void _validatePasswordMatch() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    bool mismatch = confirmPassword.isNotEmpty && newPassword != confirmPassword;
    if (_showPasswordMismatch != mismatch) {
      setState(() {
        _showPasswordMismatch = mismatch;
      });
    }
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0;
    String label = '';
    if (password.isEmpty) {
      strength = 0;
      label = '';
    } else if (password.length < 6) {
      strength = 0.2;
      label = 'Too short';
    } else {
      final hasLower = password.contains(RegExp(r'[a-z]'));
      final hasUpper = password.contains(RegExp(r'[A-Z]'));
      final hasDigit = password.contains(RegExp(r'[0-9]'));
      final hasSpecial = password.contains(RegExp(r'[!@#\$&*~%^]'));
      int score = [hasLower, hasUpper, hasDigit, hasSpecial].where((v) => v).length;
      if (score <= 1) {
        strength = 0.3;
        label = 'Weak';
      } else if (score == 2) {
        strength = 0.5;
        label = 'Fair';
      } else if (score == 3) {
        strength = 0.7;
        label = 'Good';
      } else if (score == 4 && password.length >= 8) {
        strength = 1.0;
        label = 'Strong';
      } else {
        strength = 0.7;
        label = 'Good';
      }
    }
    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _changePassword() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });
    // Validation
    if (_currentPasswordController.text.isEmpty || 
        _newPasswordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showErrorMessage('All fields are required');
      setState(() { _loading = false; });
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() { 
        _showPasswordMismatch = true;
        _loading = false; 
      });
      _showErrorMessage('New passwords do not match');
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      _showErrorMessage('Password must be at least 6 characters');
      setState(() { _loading = false; });
      return;
    }
    
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Create a credential
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        
        // Reauthenticate
        await user.reauthenticateWithCredential(credential);
        
        // Change password
        await user.updatePassword(_newPasswordController.text);
        
        _showSuccessMessage('Password updated successfully');
        // Clear the fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() { _loading = false; });
        // Auto-close modal after short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) Navigator.of(context).pop();
        });
        return;
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Current password is incorrect';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        default:
          message = 'An error occurred: ${e.message}';
      }
      _showErrorMessage(message);
    } catch (e) {
      _showErrorMessage('An error occurred: ${e.toString()}');
    }
    setState(() { _loading = false; });
  }
  
  void _showErrorMessage(String message) {
    BFeedback.show(
      context,
      title: 'Error',
      message: message,
      type: BFeedbackType.error,
      position: BFeedbackPosition.top,
    );
  }
  
  void _showSuccessMessage(String message) {
    BFeedback.show(
      context,
      title: 'Success',
      message: message,
      type: BFeedbackType.success,
      position: BFeedbackPosition.top,
    );
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
                  'CHANGE PASSWORD',
                  style: TextStyle(
                    color: Color(0xFF4080FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Update your password to keep your account secure',
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
                    'PASSWORD DETAILS',
                    style: TextStyle(
                      color: Color(0xFF4080FF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Current password field
                  _buildPasswordField(
                    label: 'Current Password',
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    toggleObscureText: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // New password field
                  _buildPasswordField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    toggleObscureText: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(10),
                          value: _passwordStrength,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _passwordStrength < 0.4
                                ? Colors.red
                                : _passwordStrength < 0.7
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _passwordStrengthLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _passwordStrength < 0.4
                                ? Colors.red
                                : _passwordStrength < 0.7
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Confirm password field
                  _buildPasswordField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    toggleObscureText: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  if (_showPasswordMismatch)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 2, bottom: 4),
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
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
              onPressed: _loading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4080FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _loading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
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
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscureText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: label,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              size: 16,
              color: Colors.grey,
            ),
            onPressed: toggleObscureText,
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the modal
void showChangePasswordModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => const ChangePasswordModal(),
    ),
  );
}
