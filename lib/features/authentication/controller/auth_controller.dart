import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rxn<User> firebaseUser = Rxn<User>();
  RxBool isLoading = false.obs;

  // --- Username for greeting ---
  RxString currentUsername = ''.obs;

  // For demo: store OTP in memory (email -> otp)
  final Map<String, String> _otpStore = {};

  Future<void> fetchAndSetUsername() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Prefer username, fallback to firstName, then email
        currentUsername.value = data['username'] ?? data['firstName'] ?? user.email ?? 'User';
      } else {
        currentUsername.value = user.email ?? 'User';
      }
    } catch (e) {
      currentUsername.value = user.email ?? 'User';
    }
  }

  // Check if user exists by email
  Future<bool> userExistsByEmail(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Generate and send OTP (5 digits) and send via backend
  Future<String?> generateAndSendOtp(String email) async {
    final exists = await userExistsByEmail(email);
    if (!exists) return null;
    final otp = (Random().nextInt(90000) + 10000).toString(); // 5 digits
    _otpStore[email] = otp;
    // Send OTP to user's email via backend
    final sendResult = await sendOtpEmail(email, otp);
    if (!sendResult) return null;
    return otp;
  }

  // Mock sending OTP email via backend REST API
  Future<bool> sendOtpEmail(String email, String otp) async {
    // TODO: Replace this with your backend call
    // Example: await http.post(...)
    print('Sending OTP $otp to $email'); // For demo
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Verify OTP (demo: check in memory)
  bool verifyOtp(String email, String otp) {
    return _otpStore[email] == otp;
  }

  // Reset password by email (requires re-auth in real app)
  Future<String?> resetPasswordByEmail(String email, String newPassword) async {
    try {
      isLoading.value = true;
      // For demo: sign in, then update password
      final user = await _auth.signInWithEmailAndPassword(email: email, password: newPassword);
      await user.user?.updatePassword(newPassword);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, (_) => fetchAndSetUsername());
    super.onInit();
  }

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      // Check for existing sign-in methods
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty && !methods.contains('password')) {
        isLoading.value = false;
        return 'This email is already registered using a different provider (e.g. Google). Please sign in with Google instead.';
      } else if (methods.contains('password')) {
        isLoading.value = false;
        return 'This email is already registered. Please sign in instead.';
      }
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    }
  }

  // Sign In
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    }
  }

  // Forgot Password
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    }
  }

  // Update Password
  Future<String?> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _auth.currentUser?.updatePassword(newPassword);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    }
  }

  // Sign Out
  Future<String?> signOut() async {
    try {
      isLoading.value = true;
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      isLoading.value = false;
      return null;
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return 'Google sign in aborted';
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final email = googleUser.email;
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty && !methods.contains('google.com')) {
        isLoading.value = false;
        return 'This email is already registered using a different provider (e.g. Email/Password). Please sign in with email and password instead.';
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      isLoading.value = false;
      return null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      return e.message;
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }
}
