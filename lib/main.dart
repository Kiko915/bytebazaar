import 'package:bytebazaar/app.dart';
import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';
import 'package:bytebazaar/features/onboarding/screens/onboarding_screen.dart';// <-- Import HomeScreen
import 'package:bytebazaar/common/widgets/bottom_nav_bar.dart'; // <-- Import BottomNavBar
import 'package:bytebazaar/utils/local_storage/local_storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import FirebaseAuth
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'firebase_options.dart'; // Import generated options
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'features/authentication/controller/auth_controller.dart';


void main() async {
  // bindings
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  // Init GetStorage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Use Firebase Emulator Suite in debug mode only
  if (kDebugMode) {
    // Firestore Emulator (use your computer's IP address when on a real device)
    FirebaseFirestore.instance.useFirestoreEmulator('192.168.8.127', 8000);
    // Storage Emulator
    FirebaseStorage.instance.useStorageEmulator('192.168.8.127', 9199);
  }

  // Check if it's the first time opening the app
  final storage = BLocalStorage();
  // Default to true if the key doesn't exist (first time)
  final isFirstTime = storage.readData<bool>('isFirstTime') ?? true;

  // Determine the initial screen
  // If it's the first time, show Onboarding, otherwise:
  //   If user is authenticated, show HomeScreen
  //   Else, show LoginScreen
  final user = FirebaseAuth.instance.currentUser;
  final Widget initialScreen;
  if (isFirstTime) {
    initialScreen = const OnboardingScreen();
  } else if (user != null) {
    initialScreen = const BottomNavBar(); // Show the bottom nav bar with HomeScreen as the first tab
  } else {
    initialScreen = const LoginScreen();
  }

  // Ensure AuthController is available everywhere
  Get.put(AuthController());

  // run main app
  runApp(App(initialScreen: initialScreen));
}
