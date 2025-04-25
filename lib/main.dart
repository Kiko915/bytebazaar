import 'package:bytebazaar/app.dart';
import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';
import 'package:bytebazaar/features/onboarding/screens/onboarding_screen.dart';
import 'package:bytebazaar/utils/local_storage/local_storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'firebase_options.dart'; // Import generated options
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';


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
    // Auth Emulator
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    // Storage Emulator
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  // Check if it's the first time opening the app
  final storage = BLocalStorage();
  // Default to true if the key doesn't exist (first time)
  final isFirstTime = storage.readData<bool>('isFirstTime') ?? true;

  // Determine the initial screen
  // If it's the first time, show Onboarding, otherwise show the main login screen
  final Widget initialScreen = isFirstTime ? const OnboardingScreen() : const LoginScreen();

  // run main app
  runApp(App(initialScreen: initialScreen));
}
