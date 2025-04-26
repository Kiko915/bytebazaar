import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:bytebazaar/utils/constants/image_strings.dart';

class NoInternetWidget extends StatelessWidget {
  final String? message;
  const NoInternetWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(BImages.noInternetAnimation, width: 220, repeat: true),
          const SizedBox(height: 24),
          Text(
            message ?? 'No internet connection. Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.blueGrey[700]),
          ),
        ],
      ),
    );
  }
}
