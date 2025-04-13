import 'package:flutter/material.dart';
import 'package:get/get.dart';
/// A utility class for managing loading dialogs and toasts using GetX
class BLoader {
  static hideLoader() {
    if (Get.isDialogOpen!) Get.back();
  }

  /// Show a loading dialog with custom animation, message and background color
  static showLoader({String? message}) {
    Get.dialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),
                Text(message ?? 'Please wait...',
                    style: Theme.of(Get.context!).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show a custom toast message
  static customToast({required String message}) {
    Get.snackbar(
      'Message',
      message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.white,
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }
}
