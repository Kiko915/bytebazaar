import 'package:flutter/material.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'dart:ui';

/// Enum for feedback type
enum BFeedbackType { success, error, info, warning }

/// Brand-aligned feedback snackbar
class BFeedback {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    BFeedbackType type = BFeedbackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final Color bgColor;
    final Color textColor = BColors.white;
    final IconData icon;
    switch (type) {
      case BFeedbackType.success:
        bgColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case BFeedbackType.error:
        bgColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case BFeedbackType.warning:
        bgColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case BFeedbackType.info:
        bgColor = BColors.primary;
        icon = Icons.info_outline;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.zero,
        content: Stack(
          children: [
            // Glassmorphism background
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: bgColor.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(icon, color: textColor, size: 32),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        child: Icon(Icons.close, color: textColor.withOpacity(0.7), size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
