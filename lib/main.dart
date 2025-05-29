import 'package:bytebazaar/app.dart';
import 'package:bytebazaar/features/authentication/screens/signup/registration_screen.dart';
import 'package:bytebazaar/utils/user_firestore_helper.dart';
import 'package:bytebazaar/features/authentication/screens/login/login_screen.dart';
import 'package:bytebazaar/features/onboarding/screens/onboarding_screen.dart';// <-- Import HomeScreen
import 'package:bytebazaar/common/widgets/bottom_nav_bar.dart'; // <-- Import BottomNavBar
import 'package:bytebazaar/utils/local_storage/local_storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import FirebaseAuth
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'firebase_options.dart'; // Import generated options
import 'package:get/get.dart';
import 'features/authentication/controller/auth_controller.dart';
import 'package:flutter/services.dart';


void main() async {
  // bindings
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init GetStorage
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure AuthController is available everywhere
  Get.put(AuthController());

  runApp(
    MyAppLauncher(),
  );
}

class MyAppLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }
        return App(initialScreen: snapshot.data ?? const LoginScreen());
      },
    );
  }
}

Future<Widget> getInitialScreen() async {
  final storage = BLocalStorage();
  final isFirstTime = storage.readData<bool>('isFirstTime') ?? true;
  final user = FirebaseAuth.instance.currentUser;

  if (isFirstTime) {
    return const OnboardingScreen();
  } else if (user != null) {
    final registered = await isUserRegistered();
    if (!registered) {
      return RegistrationScreen(email: user.email ?? '', displayName: user.displayName);
    }
    return const BottomNavBar();
  } else {
    return const LoginScreen();
  }
}
